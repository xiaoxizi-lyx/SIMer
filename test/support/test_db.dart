import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sim_keeper/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// 为每个测试提供独立的、基于 FFI 的 SQLite 数据库文件。
class TestDatabases {
  late Directory _dir;
  final _opened = <DatabaseHelper>[];

  void setUp() {
    sqfliteFfiInit();
    _dir = Directory.systemTemp.createTempSync('simer_test_');
  }

  Future<void> tearDown() async {
    for (final db in _opened) {
      await db.close();
    }
    _opened.clear();
    _dir.deleteSync(recursive: true);
  }

  DatabaseHelper open(String name) {
    final db = DatabaseHelper.forTesting(
      p.join(_dir.path, '$name.db'),
      factory: databaseFactoryFfi,
    );
    _opened.add(db);
    return db;
  }
}

/// 在测试 main() 中调用，自动完成 setUp/tearDown。
TestDatabases useTestDatabases() {
  final dbs = TestDatabases();
  setUp(dbs.setUp);
  tearDown(dbs.tearDown);
  return dbs;
}
