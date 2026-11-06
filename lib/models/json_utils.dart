import 'calendar_date.dart';

/// 读取（备份）JSON 时使用的类型安全读取方法。
///
/// 字段类型不符时抛出 [FormatException] 而不是 `TypeError`，
/// 这样导入时可以逐条记录错误、跳过损坏的记录，而不会中断整个导入。
extension JsonReader on Map<String, dynamic> {
  String? optString(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is String) return value;
    throw FormatException('字段 "$key" 应为文本');
  }

  String reqString(String key) {
    final value = optString(key);
    if (value == null || value.trim().isEmpty) {
      throw FormatException('缺少字段 "$key"');
    }
    return value;
  }

  int? optInt(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is double && value == value.truncateToDouble()) {
      return value.toInt();
    }
    throw FormatException('字段 "$key" 应为整数');
  }

  double? optDouble(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    throw FormatException('字段 "$key" 应为数字');
  }

  bool? optBool(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is bool) return value;
    throw FormatException('字段 "$key" 应为布尔值');
  }

  DateTime? optDateTime(String key) {
    final value = optString(key);
    if (value == null || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) throw FormatException('字段 "$key" 不是有效的日期');
    return parsed;
  }

  /// 日历日期（`yyyy-MM-dd`，兼容旧版的完整时间戳），返回本地日期 00:00。
  DateTime? optCalendarDate(String key) {
    final value = optString(key);
    if (value == null || value.isEmpty) return null;
    final parsed = CalendarDate.tryParse(value);
    if (parsed == null) throw FormatException('字段 "$key" 不是有效的日期');
    return parsed;
  }

  Map<String, dynamic>? optMap(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    throw FormatException('字段 "$key" 应为对象');
  }

  List<String> stringList(String key) {
    final value = this[key];
    if (value == null) return <String>[];
    if (value is List && value.every((e) => e is String)) {
      return value.cast<String>().toList();
    }
    throw FormatException('字段 "$key" 应为文本列表');
  }

  List<int> intList(String key) {
    final value = this[key];
    if (value == null) return <int>[];
    if (value is List && value.every((e) => e is int)) {
      return value.cast<int>().toList();
    }
    throw FormatException('字段 "$key" 应为整数列表');
  }
}
