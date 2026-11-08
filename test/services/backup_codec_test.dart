import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:simer/l10n/l10n.dart';
import 'package:simer/models/json_utils.dart';
import 'package:simer/models/sim_card.dart';
import 'package:simer/models/tag.dart';
import 'package:simer/services/backup_codec.dart';

import '../support/l10n.dart';

Matcher _throwsBackupError(BackupError error) => throwsA(
  isA<BackupFormatException>().having((e) => e.error, 'error', error),
);

SimCard _card(String uuid, {List<int> tagIds = const []}) => SimCard(
  uuid: uuid,
  carrierName: 'giffgaff',
  countryCode: 'GB',
  cardColor: 0xFF34C759,
  phoneNumbers: ['+44 7700 900000'],
  tagIds: [...tagIds],
);

void main() {
  group('BackupCodec', () {
    test('编码后再解码，卡片、标签与标签引用保持一致', () {
      final json = BackupCodec.encode(
        cards: [
          _card('c1', tagIds: [7]),
        ],
        tags: [Tag(id: 7, name: '保号', color: 1)],
        exportedAt: DateTime.utc(2026, 11, 6, 8),
      );
      final data = BackupCodec.decode(json);

      expect(data.formatVersion, BackupCodec.currentFormatVersion);
      expect(data.exportedAt, DateTime.utc(2026, 11, 6, 8));
      expect(data.errors, isEmpty);
      expect(data.cards.single.uuid, 'c1');
      expect(data.cards.single.tagIds, [7]);
      expect(data.tags.single.sourceId, 7);
      expect(data.tags.single.tag.name, '保号');
      expect((jsonDecode(json) as Map)['app'], 'SIMer');
    });

    test('识别 SIMer 1.0 导出的旧格式', () {
      final data = BackupCodec.decode(
        jsonEncode({'version': 1, 'simCards': <Object>[], 'tags': <Object>[]}),
      );
      expect(data.formatVersion, BackupCodec.legacyFormatVersion);
    });

    test('拒绝更新版本导出的备份', () {
      expect(
        () => BackupCodec.decode(jsonEncode({'formatVersion': 99})),
        _throwsBackupError(BackupError.newerVersion),
      );
    });

    test('拒绝非 JSON 或无版本信息的文件', () {
      expect(
        () => BackupCodec.decode('not json'),
        _throwsBackupError(BackupError.notJson),
      );
      expect(
        () => BackupCodec.decode(jsonEncode({'simCards': <Object>[]})),
        _throwsBackupError(BackupError.missingVersion),
      );
    });

    test('单条记录损坏时跳过该记录并报告，其余记录正常解析', () {
      final valid = _card('ok').toJson();
      final data = BackupCodec.decode(
        jsonEncode({
          'formatVersion': 2,
          'simCards': [
            valid,
            {'uuid': 'broken', 'carrierName': 123},
            'not an object',
          ],
          'tags': [
            {'name': ''},
          ],
        }),
      );

      expect(data.cards.map((c) => c.uuid), ['ok']);
      expect(data.errors, hasLength(3));
      expect(
        data.errors.map((e) => e.kind),
        containsAll([BackupRecordKind.card, BackupRecordKind.tag]),
      );

      final wrongType = data.errors.singleWhere((e) => e.index == 2);
      expect(wrongType.kind, BackupRecordKind.card);
      expect(wrongType.field, 'carrierName');
      expect(wrongType.problem, JsonFieldProblem.notText);
      expect(wrongType.message(zh), '第 2 张卡片：字段 "carrierName" 应为文本');
      expect(wrongType.message(en), 'Card 2: field "carrierName" must be text');

      final notObject = data.errors.singleWhere((e) => e.index == 3);
      expect(notObject.field, isNull);
      expect(notObject.message(zh), '第 3 张卡片：记录格式错误');

      final tag = data.errors.singleWhere(
        (e) => e.kind == BackupRecordKind.tag,
      );
      expect(tag.message(zh), '第 1 个标签：缺少字段 "name"');
    });

    test('缺少可选字段时使用默认值而不是失败', () {
      final data = BackupCodec.decode(
        jsonEncode({
          'formatVersion': 2,
          'simCards': [
            {'uuid': 'x', 'carrierName': 'A'},
          ],
        }),
      );
      expect(data.errors, isEmpty);
      expect(data.cards.single.cardColor, SimCard.defaultCardColor);
    });
  });
}
