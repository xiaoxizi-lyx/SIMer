import 'package:flutter_test/flutter_test.dart';
import 'package:sim_keeper/database/database_helper.dart';
import 'package:sim_keeper/models/sim_card.dart';
import 'package:sim_keeper/models/tag.dart';
import 'package:sim_keeper/services/backup_codec.dart';

import '../support/test_db.dart';

SimCard _card(String uuid, {List<int> tagIds = const [], String? notes}) =>
    SimCard(
      uuid: uuid,
      carrierName: 'Three',
      countryCode: 'HK',
      cardColor: 0xFFE5007D,
      phoneNumbers: ['+852 5123 4567', '+852 6123 4567'],
      tagIds: [...tagIds],
      notes: notes,
    );

Future<String> _export(DatabaseHelper db) async {
  final snapshot = await db.exportSnapshot();
  return BackupCodec.encode(
    cards: snapshot.cards,
    tags: snapshot.tags,
    exportedAt: DateTime.utc(2026, 11, 6),
  );
}

Future<Set<String>> _tagNamesOf(DatabaseHelper db, String uuid) async {
  final card = (await db.getSimCards(archived: false))
      .singleWhere((c) => c.uuid == uuid);
  final tags = await db.getAllTags();
  return card.tagIds
      .map((id) => tags.firstWhere((t) => t.id == id).name)
      .toSet();
}

void main() {
  final dbs = useTestDatabases();

  test('导入后按标签名称恢复卡片与标签的关联', () async {
    final source = dbs.open('source');
    final work = await source.insertTag(Tag(name: '工作', color: 1));
    final travel = await source.insertTag(Tag(name: '旅行', color: 2));
    await source.insertSimCard(_card('c1', tagIds: [work, travel]));
    final json = await _export(source);

    final target = dbs.open('target');
    // 目标设备上已有同名（大小写不同）的标签，且 id 与来源不同
    await target.insertTag(Tag(name: '其他', color: 3));
    await target.insertTag(Tag(name: '旅行', color: 4));

    final result = await target.importBackup(
      BackupCodec.decode(json),
      policy: ImportConflictPolicy.skip,
    );

    expect(result.importedCards, 1);
    expect(result.importedTags, 1, reason: '「旅行」应与已有标签合并');
    expect(await _tagNamesOf(target, 'c1'), {'工作', '旅行'});
    final phones = (await target.getSimCards(archived: false))
        .single
        .phoneNumbers;
    expect(phones, ['+852 5123 4567', '+852 6123 4567'], reason: '号码顺序保持不变');
  });

  test('重复卡片按策略跳过或覆盖', () async {
    final source = dbs.open('source');
    await source.insertSimCard(_card('dup', notes: '来自备份'));
    final data = BackupCodec.decode(await _export(source));

    final target = dbs.open('target');
    await target.insertSimCard(_card('dup', notes: '本机数据'));

    final skipped = await target.importBackup(
      data,
      policy: ImportConflictPolicy.skip,
    );
    expect(skipped.skippedCards, 1);
    expect((await target.getSimCards(archived: false)).single.notes, '本机数据');

    final overwritten = await target.importBackup(
      data,
      policy: ImportConflictPolicy.overwrite,
    );
    expect(overwritten.overwrittenCards, 1);
    final cards = await target.getSimCards(archived: false);
    expect(cards, hasLength(1));
    expect(cards.single.notes, '来自备份');
  });

  test('findExistingUuids 只返回本机已存在的 UUID', () async {
    final db = dbs.open('db');
    await db.insertSimCard(_card('a'));
    expect(await db.findExistingUuids(['a', 'b']), {'a'});
  });
}
