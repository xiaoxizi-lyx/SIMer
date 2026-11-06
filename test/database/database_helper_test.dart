import 'package:flutter_test/flutter_test.dart';
import 'package:simer/models/enums.dart';
import 'package:simer/models/sim_card.dart';
import 'package:simer/models/tag.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../support/test_db.dart';

SimCard _card(
  String uuid, {
  ActivationStatus status = ActivationStatus.active,
}) => SimCard(
  uuid: uuid,
  carrierName: 'KT',
  countryCode: 'KR',
  cardColor: 0xFFED1C24,
  activationStatus: status,
  validityType: ValidityType.rolling,
  rollingDays: 30,
  phoneNumbers: ['010-1', '010-2', '010-3'],
);

void main() {
  final dbs = useTestDatabases();

  test('归档与恢复保留原来的激活状态', () async {
    final db = dbs.open('db');
    final id = await db.insertSimCard(
      _card('a', status: ActivationStatus.inactive),
    );

    await db.archiveSimCard(id, DateTime.utc(2026, 11, 6));
    expect(await db.getSimCards(archived: false), isEmpty);
    final archived = (await db.getSimCards(archived: true)).single;
    expect(archived.archivedAt, DateTime.utc(2026, 11, 6));
    expect(archived.activationStatus, ActivationStatus.inactive);

    await db.restoreSimCard(id);
    final restored = (await db.getSimCards(archived: false)).single;
    expect(restored.isArchived, isFalse);
    expect(restored.activationStatus, ActivationStatus.inactive);
  });

  test('批量加载保持号码顺序并正确分配到各卡片', () async {
    final db = dbs.open('db');
    final tag = await db.insertTag(Tag(name: '韩国', color: 1));
    for (var i = 0; i < 3; i++) {
      await db.insertSimCard(_card('c$i')..tagIds = [tag]);
    }
    final cards = await db.getSimCards();
    expect(cards, hasLength(3));
    for (final card in cards) {
      expect(card.phoneNumbers, ['010-1', '010-2', '010-3']);
      expect(card.tagIds, [tag]);
    }
  });

  test('上次使用日按日历日保存与清除', () async {
    final db = dbs.open('db');
    final id = await db.insertSimCard(_card('a'));
    await db.setLastUsedDate(id, DateTime(2026, 11, 6, 23, 30));
    expect((await db.getSimCards()).single.lastUsedDate, DateTime(2026, 11, 6));
    await db.setLastUsedDate(id, null);
    expect((await db.getSimCards()).single.lastUsedDate, isNull);
  });

  test('标签名称不区分大小写唯一', () async {
    final db = dbs.open('db');
    await db.insertTag(Tag(name: 'Travel', color: 1));
    expect(
      () => db.insertTag(Tag(name: 'travel', color: 2)),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('永久删除时级联删除号码与标签关联', () async {
    final db = dbs.open('db');
    final tag = await db.insertTag(Tag(name: 't', color: 1));
    final id = await db.insertSimCard(_card('a')..tagIds = [tag]);
    await db.permanentlyDeleteSimCard(id);
    final raw = await db.database;
    expect(await raw.query('phone_numbers'), isEmpty);
    expect(await raw.query('sim_card_tags'), isEmpty);
  });
}
