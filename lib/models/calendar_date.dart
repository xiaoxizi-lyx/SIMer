import 'package:clock/clock.dart';

/// 日历日期工具：只关心年、月、日。
///
/// 到期日、激活日、上次使用日都是「日历日」，以本地日期的 00:00 表示，
/// 存储为 `yyyy-MM-dd`；天数差按 UTC 日期计算，不受夏令时影响。
abstract final class CalendarDate {
  /// 取 [time] 所在的本地日期（00:00）。
  static DateTime of(DateTime time) {
    final local = time.isUtc ? time.toLocal() : time;
    return DateTime(local.year, local.month, local.day);
  }

  /// 今天（可通过 `package:clock` 在测试中固定）。
  static DateTime today() => of(clock.now());

  static DateTime addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  /// 从 [from] 到 [to] 相差的日历天数（[to] 在后为正）。
  static int daysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  static String format(DateTime date) {
    final d = of(date);
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-$month-$day';
  }

  /// 解析 `yyyy-MM-dd`，也兼容 SIMer 1.0 存储的完整时间戳（取其本地日期）。
  /// 无法解析时返回 `null`。
  static DateTime? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(value.trim());
    return parsed == null ? null : of(parsed);
  }
}
