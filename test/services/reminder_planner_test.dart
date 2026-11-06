import 'package:flutter_test/flutter_test.dart';
import 'package:sim_keeper/models/enums.dart';
import 'package:sim_keeper/models/sim_card.dart';
import 'package:sim_keeper/services/reminder_planner.dart';

final _now = DateTime(2026, 11, 6, 10);

SimCard _card(
  int id, {
  DateTime? expiration,
  ValidityType type = ValidityType.fixedDate,
  int reminderDays = 7,
  int? rollingDays,
  DateTime? lastUsed,
  DateTime? archivedAt,
}) => SimCard(
  id: id,
  uuid: 'card-$id',
  carrierName: 'Card $id',
  countryCode: 'CN',
  cardColor: 0,
  validityType: type,
  expirationDate: expiration,
  rollingDays: rollingDays,
  lastUsedDate: lastUsed,
  reminderDaysBefore: reminderDays,
  archivedAt: archivedAt,
);

List<PlannedReminder> _plan(Iterable<SimCard> cards) =>
    ReminderPlanner.plan(cards, now: _now, hour: 9, minute: 30);

void main() {
  test('每张卡最多三条一次性提醒：提前 N 天、当天、过期次日', () {
    final plan = _plan([_card(1, expiration: DateTime(2026, 12, 1))]);
    expect(plan.map((r) => r.kind), [
      ReminderKind.upcoming,
      ReminderKind.dueToday,
      ReminderKind.expired,
    ]);
    expect(plan.map((r) => r.fireAt), [
      DateTime(2026, 11, 24, 9, 30),
      DateTime(2026, 12, 1, 9, 30),
      DateTime(2026, 12, 2, 9, 30),
    ]);
    expect(plan.every((r) => r.cardUuid == 'card-1'), isTrue);
  });

  test('只预约未来的提醒，已过去的不补发', () {
    // 今天 10:00 已过 9:30：只剩过期次日的提醒
    final plan = _plan([_card(1, expiration: DateTime(2026, 11, 6))]);
    expect(plan.map((r) => r.kind), [ReminderKind.expired]);
    // 已过期多日：没有任何提醒，不会每天重复打扰
    expect(_plan([_card(2, expiration: DateTime(2026, 10, 1))]), isEmpty);
  });

  test('滚动有效期按上次使用日计算，文案提示「使用一次以保号」', () {
    final plan = _plan([
      _card(
        1,
        type: ValidityType.rolling,
        rollingDays: 180,
        lastUsed: DateTime(2026, 6, 1),
        reminderDays: 14,
      ),
    ]);
    expect(plan.first.fireAt, DateTime(2026, 11, 14, 9, 30));
    expect(plan.first.body, contains('使用一次'));
  });

  test('跳过已归档、无到期日、未入库的卡片', () {
    expect(
      _plan([
        _card(1, expiration: DateTime(2026, 12, 1), archivedAt: _now),
        _card(2, type: ValidityType.noExpiration),
        SimCard(
          uuid: 'unsaved',
          carrierName: 'x',
          countryCode: 'CN',
          cardColor: 0,
          validityType: ValidityType.fixedDate,
          expirationDate: DateTime(2026, 12, 1),
        ),
      ]),
      isEmpty,
    );
  });

  test('通知 ID 由卡片与提醒类型唯一确定', () {
    final ids = {
      for (final cardId in [1, 2, 3])
        for (final kind in ReminderKind.values)
          ReminderPlanner.notificationId(cardId, kind),
    };
    expect(ids, hasLength(9));
  });

  test('提醒总数有上限（Android 闹钟数量限制）', () {
    final cards = [
      for (var i = 1; i <= 200; i++) _card(i, expiration: DateTime(2027, 1, 1)),
    ];
    expect(_plan(cards), hasLength(ReminderPlanner.maxReminders));
  });
}
