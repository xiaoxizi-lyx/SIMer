import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/sim_card.dart';
import '../models/tag.dart';
import '../models/enums.dart';
import '../services/backup_codec.dart';

/// SIMer 数据库管理器。
///
/// 应用中通过 [instance] 使用单例；测试可用 [DatabaseHelper.forTesting]
/// 打开独立的（内存）数据库。
class DatabaseHelper {
  DatabaseHelper._(this._path) : _factory = null;

  /// 测试专用：用指定的数据库工厂（如 sqflite FFI）在 [path] 打开独立数据库。
  @visibleForTesting
  DatabaseHelper.forTesting(String this._path, {this._factory});

  static final DatabaseHelper instance = DatabaseHelper._(null);

  static const String _dbName = 'sim_keeper.db';
  static const int _dbVersion = 1;

  /// 为 null 时使用系统数据库目录下的 [_dbName]。
  final String? _path;

  /// 为 null 时使用 sqflite 默认工厂。
  final DatabaseFactory? _factory;
  Future<Database>? _database;

  /// 并发首次访问时只会打开一次数据库。
  Future<Database> get database => _database ??= _initDatabase();

  Future<Database> _initDatabase() async {
    final factory = _factory ?? databaseFactory;
    final path = _path ?? join(await factory.getDatabasesPath(), _dbName);
    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: _onCreate,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // SIM卡主表
    await db.execute('''
      CREATE TABLE sim_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        iccid TEXT,
        carrier_name TEXT NOT NULL,
        carrier_code TEXT,
        country_code TEXT NOT NULL,
        source TEXT,
        notes TEXT,
        validity_type TEXT NOT NULL,
        activation_date TEXT,
        expiration_date TEXT,
        rolling_days INTEGER,
        last_used_date TEXT,
        reminder_days_before INTEGER NOT NULL DEFAULT 7,
        data_balance_mb REAL,
        data_total_mb REAL,
        voice_minutes_remaining REAL,
        voice_minutes_total REAL,
        sms_remaining INTEGER,
        sms_total INTEGER,
        balance REAL,
        balance_currency TEXT,
        features TEXT,
        rsp_server_address TEXT,
        activation_code TEXT,
        confirmation_code TEXT,
        qr_code_raw_data TEXT,
        card_color INTEGER NOT NULL,
        photo_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 标签表
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // SIM卡-标签 关联表
    await db.execute('''
      CREATE TABLE sim_card_tags (
        sim_card_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        PRIMARY KEY (sim_card_id, tag_id),
        FOREIGN KEY (sim_card_id) REFERENCES sim_cards(id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
      )
    ''');

    // 电话号码表
    await db.execute('''
      CREATE TABLE phone_numbers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sim_card_id INTEGER NOT NULL,
        number TEXT NOT NULL,
        FOREIGN KEY (sim_card_id) REFERENCES sim_cards(id) ON DELETE CASCADE
      )
    ''');

    // 创建常用查询索引
    await db.execute('CREATE INDEX idx_sim_cards_status ON sim_cards(status)');
    await db.execute('CREATE INDEX idx_sim_cards_uuid ON sim_cards(uuid)');
    await db.execute(
      'CREATE INDEX idx_phone_numbers_sim_card_id ON phone_numbers(sim_card_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sim_card_tags_sim_card_id ON sim_card_tags(sim_card_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sim_card_tags_tag_id ON sim_card_tags(tag_id)',
    );
  }

  // ══════════════════════════════════════════
  // SIM卡 CRUD
  // ══════════════════════════════════════════

  /// 插入SIM卡（含电话号码和标签，使用事务）
  Future<int> insertSimCard(SimCard card) async {
    final db = await database;
    return db.transaction((txn) async {
      final map = card.toMap()..remove('id');
      final cardId = await txn.insert('sim_cards', map);
      await _replaceRelations(txn, cardId, card.phoneNumbers, card.tagIds);
      return cardId;
    });
  }

  /// 更新SIM卡（重建电话号码和标签关联）
  Future<void> updateSimCard(SimCard card) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'sim_cards',
        card.toMap(),
        where: 'id = ?',
        whereArgs: [card.id],
      );
      await _replaceRelations(txn, card.id!, card.phoneNumbers, card.tagIds);
    });
  }

  /// 以给定列表整体替换一张卡片的电话号码与标签关联。
  Future<void> _replaceRelations(
    DatabaseExecutor txn,
    int cardId,
    List<String> phoneNumbers,
    List<int> tagIds,
  ) async {
    final batch = txn.batch()
      ..delete('phone_numbers', where: 'sim_card_id = ?', whereArgs: [cardId])
      ..delete('sim_card_tags', where: 'sim_card_id = ?', whereArgs: [cardId]);
    for (final number in phoneNumbers) {
      batch.insert('phone_numbers', {'sim_card_id': cardId, 'number': number});
    }
    for (final tagId in tagIds.toSet()) {
      batch.insert('sim_card_tags', {'sim_card_id': cardId, 'tag_id': tagId});
    }
    await batch.commit(noResult: true);
  }

  /// 获取单张SIM卡（含电话号码和标签）
  Future<SimCard?> getSimCard(int id) async {
    final db = await database;
    final maps = await db.query('sim_cards', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;

    final phoneNumbers = await _getPhoneNumbers(db, id);
    final tagIds = await _getTagIds(db, id);

    return SimCard.fromMap(
      maps.first,
      phoneNumbers: phoneNumbers,
      tagIds: tagIds,
    );
  }

  /// 获取所有非归档SIM卡
  Future<List<SimCard>> getAllSimCards() async {
    final db = await database;
    final maps = await db.query(
      'sim_cards',
      where: 'status != ?',
      whereArgs: [SimStatus.archived.name],
      orderBy: 'created_at DESC',
    );

    return _buildSimCardList(db, maps);
  }

  /// 获取已归档SIM卡
  Future<List<SimCard>> getArchivedSimCards() async {
    final db = await database;
    final maps = await db.query(
      'sim_cards',
      where: 'status = ?',
      whereArgs: [SimStatus.archived.name],
      orderBy: 'updated_at DESC',
    );

    return _buildSimCardList(db, maps);
  }

  /// 获取所有SIM卡（含归档，用于导出）
  Future<List<SimCard>> _getAllSimCardsIncludingArchived() async {
    final db = await database;
    final maps = await db.query('sim_cards', orderBy: 'created_at DESC');
    return _buildSimCardList(db, maps);
  }

  /// 归档SIM卡
  Future<void> archiveSimCard(int id) async {
    final db = await database;
    await db.update(
      'sim_cards',
      {
        'status': SimStatus.archived.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 恢复SIM卡（设为激活状态）
  Future<void> restoreSimCard(int id) async {
    final db = await database;
    await db.update(
      'sim_cards',
      {
        'status': SimStatus.active.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 永久删除SIM卡及其所有关联数据
  Future<void> permanentlyDeleteSimCard(int id) async {
    final db = await database;
    // 外键 ON DELETE CASCADE 会自动删除关联表数据
    await db.delete('sim_cards', where: 'id = ?', whereArgs: [id]);
  }

  /// 标记为已使用（滚动有效期）
  Future<void> markAsUsed(int id) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // 先获取当前卡片信息检查有效期类型
    final maps = await db.query(
      'sim_cards',
      columns: ['validity_type', 'status'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return;

    final validityType = ValidityType.fromString(
      maps.first['validity_type'] as String,
    );
    if (validityType != ValidityType.rolling) return;

    final currentStatus = SimStatus.fromString(maps.first['status'] as String);
    final newStatus = currentStatus == SimStatus.expired
        ? SimStatus.active.name
        : currentStatus.name;

    await db.update(
      'sim_cards',
      {'last_used_date': now, 'updated_at': now, 'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ══════════════════════════════════════════
  // 标签 CRUD
  // ══════════════════════════════════════════

  /// 插入标签
  Future<int> insertTag(Tag tag) async {
    final db = await database;
    return await db.insert('tags', tag.toMap());
  }

  /// 更新标签
  Future<void> updateTag(Tag tag) async {
    final db = await database;
    await db.update('tags', tag.toMap(), where: 'id = ?', whereArgs: [tag.id]);
  }

  /// 删除标签（关联表会通过外键级联删除）
  Future<void> deleteTag(int id) async {
    final db = await database;
    await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取所有标签
  Future<List<Tag>> getAllTags() async {
    final db = await database;
    final maps = await db.query('tags', orderBy: 'created_at DESC');
    return maps.map((m) => Tag.fromMap(m)).toList();
  }

  // ══════════════════════════════════════════
  // 提醒查询
  // ══════════════════════════════════════════

  /// 获取需要提醒的SIM卡（在提醒阈值内）
  Future<List<SimCard>> getSimCardsNeedingReminder() async {
    final allCards = await getAllSimCards();
    return allCards.where((card) => card.needsReminder).toList();
  }

  // ══════════════════════════════════════════
  // 导出 / 导入
  // ══════════════════════════════════════════

  /// 导出用的全量快照（含已归档卡片）。
  Future<({List<SimCard> cards, List<Tag> tags})> exportSnapshot() async {
    final cards = await _getAllSimCardsIncludingArchived();
    final tags = await getAllTags();
    return (cards: cards, tags: tags);
  }

  /// 返回 [uuids] 中本机已存在的卡片 UUID。
  Future<Set<String>> findExistingUuids(Iterable<String> uuids) async {
    final wanted = uuids.toSet();
    if (wanted.isEmpty) return <String>{};
    final db = await database;
    final rows = await db.query('sim_cards', columns: ['uuid']);
    return rows.map((r) => r['uuid']! as String).where(wanted.contains).toSet();
  }

  /// 在一个事务中导入备份。
  ///
  /// - 标签按名称（忽略大小写）合并，并据此把卡片引用的「来源标签 id」映射为本机 id；
  /// - UUID 已存在的卡片按 [policy] 跳过或覆盖；
  /// - 解析失败的记录（[BackupData.errors]）不会进入此方法，只计入结果。
  Future<ImportResult> importBackup(
    BackupData data, {
    required ImportConflictPolicy policy,
  }) async {
    final db = await database;
    return db.transaction((txn) async {
      final existingTags = await txn.query('tags', columns: ['id', 'name']);
      final tagIdByName = <String, int>{
        for (final row in existingTags)
          (row['name']! as String).trim().toLowerCase(): row['id']! as int,
      };
      final localTagIdBySourceId = <int, int>{};
      var importedTags = 0;
      for (final backupTag in data.tags) {
        final key = backupTag.tag.name.trim().toLowerCase();
        var localId = tagIdByName[key];
        if (localId == null) {
          final map = backupTag.tag.toMap()..remove('id');
          localId = await txn.insert('tags', map);
          tagIdByName[key] = localId;
          importedTags++;
        }
        final sourceId = backupTag.sourceId;
        if (sourceId != null) localTagIdBySourceId[sourceId] = localId;
      }

      final existingCards = await txn.query(
        'sim_cards',
        columns: ['id', 'uuid'],
      );
      final cardIdByUuid = <String, int>{
        for (final row in existingCards)
          row['uuid']! as String: row['id']! as int,
      };
      var importedCards = 0;
      var overwrittenCards = 0;
      var skippedCards = 0;
      for (final card in data.cards) {
        final tagIds = card.tagIds
            .map((sourceId) => localTagIdBySourceId[sourceId])
            .whereType<int>()
            .toList();
        final map = card.toMap()..remove('id');
        final existingId = cardIdByUuid[card.uuid];
        if (existingId != null) {
          if (policy == ImportConflictPolicy.skip) {
            skippedCards++;
            continue;
          }
          await txn.update(
            'sim_cards',
            map,
            where: 'id = ?',
            whereArgs: [existingId],
          );
          await _replaceRelations(txn, existingId, card.phoneNumbers, tagIds);
          overwrittenCards++;
        } else {
          final newId = await txn.insert('sim_cards', map);
          await _replaceRelations(txn, newId, card.phoneNumbers, tagIds);
          cardIdByUuid[card.uuid] = newId;
          importedCards++;
        }
      }

      return ImportResult(
        importedCards: importedCards,
        overwrittenCards: overwrittenCards,
        skippedCards: skippedCards,
        importedTags: importedTags,
        failedRecords: data.errors,
      );
    });
  }

  // ══════════════════════════════════════════
  // 私有辅助方法
  // ══════════════════════════════════════════

  /// 获取SIM卡的电话号码列表
  Future<List<String>> _getPhoneNumbers(Database db, int simCardId) async {
    final maps = await db.query(
      'phone_numbers',
      where: 'sim_card_id = ?',
      whereArgs: [simCardId],
    );
    return maps.map((m) => m['number'] as String).toList();
  }

  /// 获取SIM卡的标签 ID 列表
  Future<List<int>> _getTagIds(Database db, int simCardId) async {
    final maps = await db.query(
      'sim_card_tags',
      columns: ['tag_id'],
      where: 'sim_card_id = ?',
      whereArgs: [simCardId],
    );
    return maps.map((m) => m['tag_id'] as int).toList();
  }

  /// 从查询结果构建 SimCard 列表
  Future<List<SimCard>> _buildSimCardList(
    Database db,
    List<Map<String, dynamic>> maps,
  ) async {
    final cards = <SimCard>[];
    for (final map in maps) {
      final id = map['id'] as int;
      final phoneNumbers = await _getPhoneNumbers(db, id);
      final tagIds = await _getTagIds(db, id);
      cards.add(
        SimCard.fromMap(map, phoneNumbers: phoneNumbers, tagIds: tagIds),
      );
    }
    return cards;
  }

  /// 关闭数据库
  Future<void> close() async {
    final pending = _database;
    if (pending == null) return;
    _database = null;
    await (await pending).close();
  }
}

/// 导入操作的结果
class ImportResult {
  const ImportResult({
    required this.importedCards,
    required this.overwrittenCards,
    required this.skippedCards,
    required this.importedTags,
    this.failedRecords = const [],
  });

  final int importedCards;
  final int overwrittenCards;
  final int skippedCards;
  final int importedTags;

  /// 备份中无法解析而被跳过的记录。
  final List<BackupRecordError> failedRecords;

  String get summary {
    final parts = <String>[
      '新增 $importedCards 张卡片',
      if (overwrittenCards > 0) '覆盖 $overwrittenCards 张',
      if (skippedCards > 0) '跳过 $skippedCards 张重复卡片',
      if (importedTags > 0) '新增 $importedTags 个标签',
      if (failedRecords.isNotEmpty) '${failedRecords.length} 条记录无法解析',
    ];
    return '导入完成：${parts.join('，')}';
  }
}
