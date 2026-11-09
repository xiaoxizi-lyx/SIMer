import '../l10n/l10n.dart';
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
/// 通知文字使用 [strings] 的语言（预约时的界面语言；语言变化后会重新预约）。
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
    required AppLocalizations strings,
  }) {
    final l = strings;
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
      final carrier = card.carrierLabel(l);

      final candidates = <(ReminderKind, DateTime, String, String)>[
        if (lead > 0)
          (
            ReminderKind.upcoming,
            at(CalendarDate.addDays(expiration, -lead)),
            l.reminderUpcomingTitle(carrier, lead),
            rolling
                ? l.reminderUpcomingBodyRolling(dateText)
                : l.reminderUpcomingBodyFixed(dateText),
          ),
        (
          ReminderKind.dueToday,
          at(expiration),
          l.reminderDueTodayTitle(carrier),
          rolling ? l.reminderDueTodayBodyRolling : l.reminderDueTodayBodyFixed,
        ),
        (
          ReminderKind.expired,
          at(CalendarDate.addDays(expiration, 1)),
          l.reminderExpiredTitle(carrier),
          rolling
              ? l.reminderExpiredBodyRolling(dateText)
              : l.reminderExpiredBodyFixed(dateText),
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
