import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sim_card.dart';
import '../models/tag.dart';
import '../models/enums.dart';

/// SIMer 数据库管理器（单例）
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;
  static const String _dbName = 'sim_keeper.db';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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
    await db.execute(
        'CREATE INDEX idx_sim_cards_status ON sim_cards(status)');
    await db.execute(
        'CREATE INDEX idx_sim_cards_uuid ON sim_cards(uuid)');
    await db.execute(
        'CREATE INDEX idx_phone_numbers_sim_card_id ON phone_numbers(sim_card_id)');
    await db.execute(
        'CREATE INDEX idx_sim_card_tags_sim_card_id ON sim_card_tags(sim_card_id)');
    await db.execute(
        'CREATE INDEX idx_sim_card_tags_tag_id ON sim_card_tags(tag_id)');
  }

  // ══════════════════════════════════════════
  // SIM卡 CRUD
  // ══════════════════════════════════════════

  /// 插入SIM卡（含电话号码和标签，使用事务）
  Future<int> insertSimCard(SimCard card) async {
    final db = await database;
    late int cardId;

    await db.transaction((txn) async {
      cardId = await txn.insert('sim_cards', card.toMap());

      // 插入电话号码
      for (final number in card.phoneNumbers) {
        await txn.insert('phone_numbers', {
          'sim_card_id': cardId,
          'number': number,
        });
      }

      // 插入标签关联
      for (final tagId in card.tagIds) {
        await txn.insert('sim_card_tags', {
          'sim_card_id': cardId,
          'tag_id': tagId,
        });
      }
    });

    return cardId;
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

      // 删除旧电话号码，重新插入
      await txn.delete(
        'phone_numbers',
        where: 'sim_card_id = ?',
        whereArgs: [card.id],
      );
      for (final number in card.phoneNumbers) {
        await txn.insert('phone_numbers', {
          'sim_card_id': card.id,
          'number': number,
        });
      }

      // 删除旧标签关联，重新插入
      await txn.delete(
        'sim_card_tags',
        where: 'sim_card_id = ?',
        whereArgs: [card.id],
      );
      for (final tagId in card.tagIds) {
        await txn.insert('sim_card_tags', {
          'sim_card_id': card.id,
          'tag_id': tagId,
        });
      }
    });
  }

  /// 获取单张SIM卡（含电话号码和标签）
  Future<SimCard?> getSimCard(int id) async {
    final db = await database;
    final maps = await db.query(
      'sim_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;

    final phoneNumbers = await _getPhoneNumbers(db, id);
    final tagIds = await _getTagIds(db, id);

    return SimCard.fromMap(maps.first, phoneNumbers: phoneNumbers, tagIds: tagIds);
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
    await db.delete(
      'sim_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
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

    final validityType = ValidityType.fromString(maps.first['validity_type'] as String);
    if (validityType != ValidityType.rolling) return;

    final currentStatus = SimStatus.fromString(maps.first['status'] as String);
    final newStatus = currentStatus == SimStatus.expired
        ? SimStatus.active.name
        : currentStatus.name;

    await db.update(
      'sim_cards',
      {
        'last_used_date': now,
        'updated_at': now,
        'status': newStatus,
      },
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
    await db.update(
      'tags',
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  /// 删除标签（关联表会通过外键级联删除）
  Future<void> deleteTag(int id) async {
    final db = await database;
    await db.delete(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
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

  /// 将所有数据导出为 JSON 字符串
  Future<String> exportToJson() async {
    final simCards = await _getAllSimCardsIncludingArchived();
    final tags = await getAllTags();

    final data = {
      'version': _dbVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'simCards': simCards.map((c) => c.toJson()).toList(),
      'tags': tags.map((t) => t.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// 从 JSON 字符串导入数据（使用 UUID 去重）
  Future<ImportResult> importFromJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final db = await database;

    int importedCards = 0;
    int skippedCards = 0;
    int importedTags = 0;

    await db.transaction((txn) async {
      // 导入标签
      if (data['tags'] != null) {
        final tagList = (data['tags'] as List)
            .map((t) => Tag.fromJson(t as Map<String, dynamic>))
            .toList();

        final existingTags = await txn.query('tags');
        final existingTagNames =
            existingTags.map((t) => t['name'] as String).toSet();

        for (final tag in tagList) {
          if (!existingTagNames.contains(tag.name)) {
            final tagMap = tag.toMap();
            tagMap.remove('id'); // 让数据库自动分配 ID
            await txn.insert('tags', tagMap);
            importedTags++;
          }
        }
      }

      // 导入 SIM 卡
      if (data['simCards'] != null) {
        final cardList = (data['simCards'] as List)
            .map((c) => SimCard.fromJson(c as Map<String, dynamic>))
            .toList();

        // 获取所有已有的 UUID
        final existingCards = await txn.query('sim_cards', columns: ['uuid']);
        final existingUuids =
            existingCards.map((c) => c['uuid'] as String).toSet();

        for (final card in cardList) {
          if (existingUuids.contains(card.uuid)) {
            skippedCards++;
            continue;
          }

          // 插入卡片
          final cardMap = card.toMap();
          cardMap.remove('id');
          final cardId = await txn.insert('sim_cards', cardMap);

          // 插入电话号码
          for (final number in card.phoneNumbers) {
            await txn.insert('phone_numbers', {
              'sim_card_id': cardId,
              'number': number,
            });
          }

          // 标签关联：根据名称查找新的 tag ID
          // 导入时 tagIds 引用的是原始数据库的 ID，需要重新映射
          // 由于我们无法可靠映射旧 ID，这里跳过标签关联
          // 用户可以在导入后手动重新分配标签

          importedCards++;
        }
      }
    });

    return ImportResult(
      importedCards: importedCards,
      skippedCards: skippedCards,
      importedTags: importedTags,
    );
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
      Database db, List<Map<String, dynamic>> maps) async {
    final cards = <SimCard>[];
    for (final map in maps) {
      final id = map['id'] as int;
      final phoneNumbers = await _getPhoneNumbers(db, id);
      final tagIds = await _getTagIds(db, id);
      cards.add(SimCard.fromMap(map, phoneNumbers: phoneNumbers, tagIds: tagIds));
    }
    return cards;
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

/// 导入操作的结果
class ImportResult {
  final int importedCards;
  final int skippedCards;
  final int importedTags;

  const ImportResult({
    required this.importedCards,
    required this.skippedCards,
    required this.importedTags,
  });

  String get summary =>
      '导入完成：新增 $importedCards 张卡片，跳过 $skippedCards 张重复卡片，新增 $importedTags 个标签';
}
