import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/calendar_date.dart';
import '../models/sim_card.dart';
import '../models/tag.dart';
import '../services/backup_codec.dart';

/// SIMer 数据库管理器。
///
/// 应用中通过 [instance] 使用单例；测试可用 [DatabaseHelper.forTesting]
/// 打开独立的数据库。
class DatabaseHelper {
  DatabaseHelper._(this._path) : _factory = null;

  /// 测试专用：用指定的数据库工厂（如 sqflite FFI）在 [path] 打开独立数据库。
  @visibleForTesting
  DatabaseHelper.forTesting(String this._path, {this._factory});

  static final DatabaseHelper instance = DatabaseHelper._(null);

  static const String _dbName = 'simer.db';

  /// 当前 schema 版本。修改表结构时递增，并在 [_migrations] 中补充迁移。
  static const int _dbVersion = 1;

  /// 从版本 n 升级到 n+1 的迁移。
  static final Map<int, Future<void> Function(DatabaseExecutor db)>
  _migrations = {};

  /// SQLite 单条语句可绑定的参数数量有限，批量查询按此大小分块。
  static const int _chunkSize = 500;

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
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: (db, oldVersion, newVersion) => throw StateError(
          '数据库版本 $oldVersion 高于当前应用支持的 $newVersion，请升级 SIMer',
        ),
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch()
      // SIM卡主表。到期类日期为 yyyy-MM-dd，时间戳为 UTC ISO 8601。
      ..execute('''
        CREATE TABLE sim_cards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          type TEXT NOT NULL,
          activation_status TEXT NOT NULL,
          archived_at TEXT,
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
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''')
      ..execute(
        'CREATE INDEX idx_sim_cards_archived_at ON sim_cards(archived_at)',
      )
      // 标签名不区分大小写唯一
      ..execute('''
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL COLLATE NOCASE UNIQUE,
          color INTEGER NOT NULL,
          created_at TEXT NOT NULL
        )
      ''')
      ..execute('''
        CREATE TABLE sim_card_tags (
          sim_card_id INTEGER NOT NULL
            REFERENCES sim_cards(id) ON DELETE CASCADE,
          tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
          PRIMARY KEY (sim_card_id, tag_id)
        )
      ''')
      ..execute(
        'CREATE INDEX idx_sim_card_tags_tag_id ON sim_card_tags(tag_id)',
      )
      ..execute('''
        CREATE TABLE phone_numbers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sim_card_id INTEGER NOT NULL
            REFERENCES sim_cards(id) ON DELETE CASCADE,
          number TEXT NOT NULL
        )
      ''')
      ..execute(
        'CREATE INDEX idx_phone_numbers_sim_card_id '
        'ON phone_numbers(sim_card_id)',
      );
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (var version = oldVersion; version < newVersion; version++) {
      final migrate = _migrations[version];
      if (migrate == null) {
        throw StateError('缺少数据库从 v$version 升级到 v${version + 1} 的迁移');
      }
      await migrate(db);
    }
  }

  // ══════════════════════════════════════════
  // SIM卡
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

  /// 读取卡片。[archived] 为 null 时返回全部，否则只返回已归档/未归档的卡片。
  Future<List<SimCard>> getSimCards({bool? archived}) => _queryCards(
    where: switch (archived) {
      null => null,
      true => 'archived_at IS NOT NULL',
      false => 'archived_at IS NULL',
    },
    orderBy: archived == true ? 'archived_at DESC' : 'created_at DESC',
  );

  /// 归档：保留激活状态，只记录归档时间。
  Future<void> archiveSimCard(int id, DateTime archivedAt) =>
      _updateCard(id, {'archived_at': archivedAt.toUtc().toIso8601String()});

  /// 取消归档：激活状态保持归档前的值。
  Future<void> restoreSimCard(int id) => _updateCard(id, {'archived_at': null});

  /// 设置滚动有效期的上次使用日（[date] 为 null 表示清除）。
  Future<void> setLastUsedDate(int id, DateTime? date) => _updateCard(id, {
    'last_used_date': date == null ? null : CalendarDate.format(date),
  });

  /// 永久删除SIM卡；号码与标签关联由外键级联删除。
  Future<void> permanentlyDeleteSimCard(int id) async {
    final db = await database;
    await db.delete('sim_cards', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _updateCard(int id, Map<String, Object?> values) async {
    final db = await database;
    await db.update(
      'sim_cards',
      {...values, 'updated_at': clock.now().toUtc().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ══════════════════════════════════════════
  // 标签
  // ══════════════════════════════════════════

  /// 插入标签。名称（不区分大小写）重复时抛出 [DatabaseException]。
  Future<int> insertTag(Tag tag) async {
    final db = await database;
    return db.insert('tags', tag.toMap()..remove('id'));
  }

  Future<void> updateTag(Tag tag) async {
    final db = await database;
    await db.update('tags', tag.toMap(), where: 'id = ?', whereArgs: [tag.id]);
  }

  /// 删除标签（关联表会通过外键级联删除）
  Future<void> deleteTag(int id) async {
    final db = await database;
    await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Tag>> getAllTags() async {
    final db = await database;
    final rows = await db.query('tags', orderBy: 'created_at DESC, id DESC');
    return rows.map(Tag.fromMap).toList();
  }

  // ══════════════════════════════════════════
  // 导出 / 导入
  // ══════════════════════════════════════════

  /// 导出用的全量快照（含已归档卡片）。
  Future<({List<SimCard> cards, List<Tag> tags})> exportSnapshot() async {
    final cards = await getSimCards();
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
          localId = await txn.insert(
            'tags',
            backupTag.tag.toMap()..remove('id'),
          );
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

  /// 查询卡片，并用两次批量查询补全号码与标签（避免每张卡单独查询）。
  Future<List<SimCard>> _queryCards({String? where, String? orderBy}) async {
    final db = await database;
    final rows = await db.query('sim_cards', where: where, orderBy: orderBy);
    if (rows.isEmpty) return [];

    final ids = [for (final row in rows) row['id']! as int];
    final phones = <int, List<String>>{};
    final tags = <int, List<int>>{};
    for (var start = 0; start < ids.length; start += _chunkSize) {
      final chunk = ids.sublist(
        start,
        (start + _chunkSize).clamp(0, ids.length),
      );
      final placeholders = List.filled(chunk.length, '?').join(',');
      final phoneRows = await db.query(
        'phone_numbers',
        columns: ['sim_card_id', 'number'],
        where: 'sim_card_id IN ($placeholders)',
        whereArgs: chunk,
        orderBy: 'id',
      );
      for (final row in phoneRows) {
        (phones[row['sim_card_id']! as int] ??= []).add(
          row['number']! as String,
        );
      }
      final tagRows = await db.query(
        'sim_card_tags',
        columns: ['sim_card_id', 'tag_id'],
        where: 'sim_card_id IN ($placeholders)',
        whereArgs: chunk,
        orderBy: 'rowid',
      );
      for (final row in tagRows) {
        (tags[row['sim_card_id']! as int] ??= []).add(row['tag_id']! as int);
      }
    }

    return [
      for (final row in rows)
        SimCard.fromMap(
          row,
          phoneNumbers: phones[row['id']] ?? [],
          tagIds: tags[row['id']] ?? [],
        ),
    ];
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
}
