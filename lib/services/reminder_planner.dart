import '../models/calendar_date.dart';
import '../models/enums.dart';
import '../models/sim_card.dart';

/// 提醒类型。每张卡片每种类型最多一条，均为一次性提醒。
enum ReminderKind { upcoming, dueToday, expired }

/// 一条计划中的提醒。
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.cardUuid,
    required this.kind,
    required this.fireAt,
    required this.title,
    required this.body,
  });

  /// 通知 ID：由卡片 ID 与提醒类型确定，重排时保持不变。
  final int id;
  final String cardUuid;
  final ReminderKind kind;

  /// 本地时间。
  final DateTime fireAt;
  final String title;
  final String body;

  @override
  String toString() => 'PlannedReminder($kind, $cardUuid, $fireAt)';
}

/// 根据卡片的有效期计算需要预约的提醒（纯函数，便于测试）。
///
/// 每张有到期日、未归档的卡片最多三条：提前 N 天（N 为卡片的提前提醒天数）、
/// 到期当天、过期次日。只安排未来的提醒，不会每天重复提醒同一件事。
abstract final class ReminderPlanner {
  /// Android 限制每个应用约 500 个待触发闹钟，留出余量。
  static const int maxReminders = 400;

  static int notificationId(int cardId, ReminderKind kind) =>
      cardId * ReminderKind.values.length + kind.index;

  static List<PlannedReminder> plan(
    Iterable<SimCard> cards, {
    required DateTime now,
    required int hour,
    required int minute,
  }) {
    // 留一分钟余量，避免预约一个瞬间就过去的时间点
    final earliest = now.add(const Duration(minutes: 1));
    final reminders = <PlannedReminder>[];

    for (final card in cards) {
      final cardId = card.id;
      final expiration = card.effectiveExpirationDate;
      if (cardId == null || card.isArchived || expiration == null) continue;

      DateTime at(DateTime day) =>
          DateTime(day.year, day.month, day.day, hour, minute);
      final rolling = card.validityType == ValidityType.rolling;
      final dateText = CalendarDate.format(expiration);
      final lead = card.reminderDaysBefore.clamp(0, 365);

      final candidates = <(ReminderKind, DateTime, String, String)>[
        if (lead > 0)
          (
            ReminderKind.upcoming,
            at(CalendarDate.addDays(expiration, -lead)),
            '📅 ${card.carrierName} 将在 $lead 天后到期',
            rolling ? '请在 $dateText 前使用一次以保号' : '到期日：$dateText',
          ),
        (
          ReminderKind.dueToday,
          at(expiration),
          '⏰ ${card.carrierName} 今天到期',
          rolling ? '今天是最后期限，请使用一次以续期' : '请及时续费或处理',
        ),
        (
          ReminderKind.expired,
          at(CalendarDate.addDays(expiration, 1)),
          '⚠️ ${card.carrierName} 已过期',
          rolling ? '已超过保号期限 $dateText，请尽快确认号码状态' : '已于 $dateText 到期',
        ),
      ];

      for (final (kind, fireAt, title, body) in candidates) {
        if (!fireAt.isAfter(earliest)) continue;
        reminders.add(
          PlannedReminder(
            id: notificationId(cardId, kind),
            cardUuid: card.uuid,
            kind: kind,
            fireAt: fireAt,
            title: title,
            body: body,
          ),
        );
      }
    }

    reminders.sort((a, b) => a.fireAt.compareTo(b.fireAt));
    return reminders.length > maxReminders
        ? reminders.sublist(0, maxReminders)
        : reminders;
  }
}
