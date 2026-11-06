import 'package:flutter_test/flutter_test.dart';
import 'package:sim_keeper/models/enums.dart';
import 'package:sim_keeper/models/feature_set.dart';
import 'package:sim_keeper/models/sim_card.dart';
import 'package:sim_keeper/models/tag.dart';

Map<String, dynamic> _legacyCard(String status) => {
  'uuid': 'legacy-$status',
  'type': 'esim',
  'status': status,
  'carrierName': 'Three',
  'countryCode': 'HK',
  'validityType': 'rolling',
  'rollingDays': 180,
  'lastUsedDate': '2026-09-19T21:15:30.123',
  'cardColor': 0xFFE5007D,
  'photoPath': '/data/user/0/old/photo.jpg',
  'createdAt': '2026-09-01T10:00:00.000',
  'updatedAt': '2026-10-01T10:00:00.000',
};

void main() {
  test('当前格式往返保持一致', () {
    final original = SimCard(
      uuid: 'roundtrip',
      cardColor: 0xFF34C759,
      type: SimType.esim,
      activationStatus: ActivationStatus.inactive,
      archivedAt: DateTime.utc(2026, 11, 1, 8),
      carrierName: 'giffgaff',
      carrierCode: 'giffgaff',
      countryCode: 'GB',
      phoneNumbers: ['+447123456789'],
      validityType: ValidityType.rolling,
      rollingDays: 180,
      lastUsedDate: DateTime(2026, 10, 1),
      features: FeatureSet({
        Feature.wifiCalling: const FeatureItem(supported: true, note: 'EE 网络'),
      }),
      tagIds: [3],
    );

    final restored = SimCard.fromJson(original.toJson());
    expect(restored.uuid, original.uuid);
    expect(restored.activationStatus, ActivationStatus.inactive);
    expect(restored.archivedAt, DateTime.utc(2026, 11, 1, 8));
    expect(restored.lastUsedDate, DateTime(2026, 10, 1));
    expect(restored.phoneNumbers, original.phoneNumbers);
    expect(restored.tagIds, [3]);
    expect(restored.features[Feature.wifiCalling].note, 'EE 网络');
    expect(original.toJson()['lastUsedDate'], '2026-10-01');
  });

  group('SIMer 1.0 旧格式', () {
    test('expired 不再是存储状态：转为激活，过期由日期计算', () {
      final card = SimCard.fromJson(_legacyCard('expired'));
      expect(card.activationStatus, ActivationStatus.active);
      expect(card.isArchived, isFalse);
    });

    test('archived 转为归档时间，激活状态按未激活处理', () {
      final card = SimCard.fromJson(_legacyCard('archived'));
      expect(card.isArchived, isTrue);
      expect(
        card.archivedAt,
        DateTime.parse('2026-10-01T10:00:00.000').toUtc(),
      );
      expect(card.activationStatus, ActivationStatus.inactive);
    });

    test('带时刻的旧日期取其日历日', () {
      final card = SimCard.fromJson(_legacyCard('active'));
      expect(card.lastUsedDate, DateTime(2026, 9, 19));
    });
  });

  test('功能备注可以清除', () {
    const item = FeatureItem(supported: true, note: 'a');
    expect(item.copyWith(note: null).note, isNull);
    expect(item.copyWith(supported: false).note, 'a');
  });

  test('未入库的不同标签不相等', () {
    expect(Tag(name: '工作', color: 1) == Tag(name: '旅行', color: 2), isFalse);
    expect(
      Tag(id: 1, name: 'a', color: 1) == Tag(id: 1, name: 'b', color: 2),
      isTrue,
    );
  });
}
