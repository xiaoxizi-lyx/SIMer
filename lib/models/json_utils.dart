import 'calendar_date.dart';

/// 备份记录中某个字段的问题；界面层把它转换为当前语言的说明。
enum JsonFieldProblem {
  missing,
  notText,
  notInteger,
  notNumber,
  notBoolean,
  invalidDate,
  notObject,
  notTextList,
  notIntegerList,
}

/// 记录中的某个字段缺失或类型不符。
class JsonFieldException extends FormatException {
  JsonFieldException(this.field, this.problem)
    : super('field "$field": ${problem.name}');

  final String field;
  final JsonFieldProblem problem;
}

/// 读取（备份）JSON 时使用的类型安全读取方法。
///
/// 字段类型不符时抛出 [JsonFieldException] 而不是 `TypeError`，
/// 这样导入时可以逐条记录错误、跳过损坏的记录，而不会中断整个导入。
extension JsonReader on Map<String, dynamic> {
  String? optString(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is String) return value;
    throw JsonFieldException(key, JsonFieldProblem.notText);
  }

  String reqString(String key) {
    final value = optString(key);
    if (value == null || value.trim().isEmpty) {
      throw JsonFieldException(key, JsonFieldProblem.missing);
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
    throw JsonFieldException(key, JsonFieldProblem.notInteger);
  }

  double? optDouble(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    throw JsonFieldException(key, JsonFieldProblem.notNumber);
  }

  bool? optBool(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is bool) return value;
    throw JsonFieldException(key, JsonFieldProblem.notBoolean);
  }

  DateTime? optDateTime(String key) {
    final value = optString(key);
    if (value == null || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw JsonFieldException(key, JsonFieldProblem.invalidDate);
    }
    return parsed;
  }

  /// 日历日期（`yyyy-MM-dd`，兼容旧版的完整时间戳），返回本地日期 00:00。
  DateTime? optCalendarDate(String key) {
    final value = optString(key);
    if (value == null || value.isEmpty) return null;
    final parsed = CalendarDate.tryParse(value);
    if (parsed == null) {
      throw JsonFieldException(key, JsonFieldProblem.invalidDate);
    }
    return parsed;
  }

  Map<String, dynamic>? optMap(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    throw JsonFieldException(key, JsonFieldProblem.notObject);
  }

  List<String> stringList(String key) {
    final value = this[key];
    if (value == null) return <String>[];
    if (value is List && value.every((e) => e is String)) {
      return value.cast<String>().toList();
    }
    throw JsonFieldException(key, JsonFieldProblem.notTextList);
  }

  List<int> intList(String key) {
    final value = this[key];
    if (value == null) return <int>[];
    if (value is List && value.every((e) => e is int)) {
      return value.cast<int>().toList();
    }
    throw JsonFieldException(key, JsonFieldProblem.notIntegerList);
  }
}
