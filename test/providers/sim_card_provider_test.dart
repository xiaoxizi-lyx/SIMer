import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simer/models/enums.dart';
import 'package:simer/models/sim_card.dart';
import 'package:simer/models/tag.dart';
import 'package:simer/providers/filter_provider.dart';
import 'package:simer/providers/sim_card_provider.dart';

import '../support/test_db.dart';

final _today = DateTime(2026, 11, 6);

SimCard _card(
  String uuid, {
  String carrier = 'Carrier',
  String country = 'CN',
  ActivationStatus status = ActivationStatus.active,
  ValidityType validity = ValidityType.noExpiration,
  DateTime? expiration,
  List<String> phones = const [],
  DateTime? createdAt,
}) => SimCard(
  uuid: uuid,
  carrierName: carrier,
  countryCode: country,
  cardColor: 0,
  activationStatus: status,
  validityType: validity,
  expirationDate: expiration,
  phoneNumbers: [...phones],
  createdAt: createdAt,
);

void main() {
  final dbs = useTestDatabases();
  late SimCardProvider provider;
  late FilterProvider filter;

  setUp(() {
    provider = SimCardProvider(database: dbs.open('provider'));
    filter = FilterProvider();
  });

  List<String> visible() => provider
      .getFilteredAndSorted(filter, today: _today)
      .map((c) => c.uuid)
      .toList();

  Future<void> seed() async {
    await provider.addSimCard(
      _card(
        'gb-expiring',
        carrier: 'giffgaff',
        country: 'GB',
        validity: ValidityType.fixedDate,
        expiration: DateTime(2026, 11, 10),
        phones: ['+44 7700 900123'],
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
    await provider.addSimCard(
      _card(
        'hk-expired',
        carrier: 'Three',
        country: 'HK',
        validity: ValidityType.fixedDate,
        expiration: DateTime(2026, 11, 1),
        createdAt: DateTime.utc(2026, 2, 1),
      ),
    );
    await provider.addSimCard(
      _card(
        'cn-inactive',
        carrier: '中国移动',
        status: ActivationStatus.inactive,
        createdAt: DateTime.utc(2026, 3, 1),
      ),
    );
  }

  test('状态筛选：激活/未激活看设置，即将到期/已过期按日期实时计算', () async {
    await seed();
    filter.setStatusFilter(StatusFilter.inactive);
    expect(visible(), ['cn-inactive']);
    filter.setStatusFilter(StatusFilter.expiringSoon);
    expect(visible(), ['gb-expiring']);
    filter.setStatusFilter(StatusFilter.expired);
    expect(visible(), ['hk-expired']);
    expect(provider.countFor(StatusFilter.active, today: _today), 2);
  });

  test('搜索匹配国家名、去掉空格的号码与标签名', () async {
    await seed();
    final tagId = await provider.addTag(Tag(name: '保号卡', color: 1));
    final card = provider.getSimCardByUuid('gb-expiring')!..tagIds = [tagId];
    await provider.updateSimCard(card);

    filter.setSearchQuery('英国');
    expect(visible(), ['gb-expiring']);
    filter.setSearchQuery('7700900123');
    expect(visible(), ['gb-expiring']);
    filter.setSearchQuery('保号');
    expect(visible(), ['gb-expiring']);
    filter.setSearchQuery('中国移动');
    expect(visible(), ['cn-inactive']);
  });

  test('按到期日排序时无到期日的卡片排在最后', () async {
    await seed();
    filter
      ..setSortBy(SortBy.expirationDate)
      ..setSortOrder(SortOrder.ascending);
    expect(visible(), ['hk-expired', 'gb-expiring', 'cn-inactive']);
  });

  test('「我已使用」可撤销', () async {
    final id = await provider.addSimCard(
      _card('rolling', validity: ValidityType.rolling)
        ..rollingDays = 30
        ..lastUsedDate = DateTime(2026, 10, 1),
    );
    final previous = provider.getSimCardById(id)!.lastUsedDate;

    await withClock(Clock.fixed(DateTime(2026, 11, 6, 9)), () async {
      await provider.markAsUsed(id);
    });
    expect(provider.getSimCardById(id)!.lastUsedDate, _today);

    await provider.setLastUsedDate(id, previous);
    expect(provider.getSimCardById(id)!.lastUsedDate, DateTime(2026, 10, 1));
  });

  test('归档后从列表移出，恢复后保留激活状态；删除标签时清除引用', () async {
    await seed();
    final tagId = await provider.addTag(Tag(name: 't', color: 1));
    final card = provider.getSimCardByUuid('cn-inactive')!..tagIds = [tagId];
    await provider.updateSimCard(card);

    await provider.archiveSimCard(card.id!);
    expect(visible(), isNot(contains('cn-inactive')));
    expect(provider.archivedCards.single.uuid, 'cn-inactive');

    await provider.deleteTag(tagId);
    expect(provider.archivedCards.single.tagIds, isEmpty);

    await provider.restoreSimCard(card.id!);
    final restored = provider.getSimCardByUuid('cn-inactive')!;
    expect(restored.isArchived, isFalse);
    expect(restored.activationStatus, ActivationStatus.inactive);
  });

  test('重新加载后数据与内存一致，并通知卡片变化', () async {
    await seed();
    var changes = 0;
    provider.onCardsChanged = () => changes++;
    await provider.loadAll();
    expect(provider.simCards, hasLength(3));
    expect(changes, 1);
  });
}
