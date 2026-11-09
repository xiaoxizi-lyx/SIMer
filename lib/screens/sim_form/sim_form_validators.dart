/// 表单字段的校验错误；界面层转换为当前语言的文字。
enum FieldError {
  invalidIccid,
  notANumber,
  negative,
  notAnInteger,
  daysRequired,
  daysNotInteger,

  /// 滚动周期超出 1-[SimFormValidators.maxRollingDays]。
  rollingDaysOutOfRange,

  /// 提前提醒天数超出 0-[SimFormValidators.maxReminderDays]。
  reminderDaysOutOfRange,
  dateInFuture,
  expirationRequired,
}

/// 添加/编辑表单的字段解析与校验（纯函数，便于单元测试）。
///
/// 校验函数返回 [FieldError]，合法时返回 null。
abstract final class SimFormValidators {
  static const int maxRollingDays = 3650;
  static const int maxReminderDays = 365;

  static final RegExp _iccid = RegExp(r'^\d{18,22}$');
  static final RegExp _numberNoise = RegExp(r'[,，\s]');

  /// 去除空白：用户常从卡托或网页复制带空格的 ICCID。
  static String normalizeIccid(String raw) => raw.replaceAll(RegExp(r'\s'), '');

  static FieldError? iccid(String? raw) {
    final value = normalizeIccid(raw ?? '');
    if (value.isEmpty) return null;
    if (!_iccid.hasMatch(value)) return FieldError.invalidIccid;
    return null;
  }

  /// 解析数字，允许千分位逗号与空格；空字符串或无法解析时返回 null。
  static double? parseDecimal(String raw) {
    final value = raw.replaceAll(_numberNoise, '');
    if (value.isEmpty) return null;
    final parsed = double.tryParse(value);
    return parsed == null || !parsed.isFinite ? null : parsed;
  }

  static int? parseInt(String raw) {
    final value = raw.replaceAll(_numberNoise, '');
    return value.isEmpty ? null : int.tryParse(value);
  }

  /// 可选的非负数字。
  static FieldError? decimal(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return null;
    final value = parseDecimal(text);
    if (value == null) return FieldError.notANumber;
    if (value < 0) return FieldError.negative;
    return null;
  }

  /// 可选的非负整数。
  static FieldError? integer(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return null;
    final value = parseInt(text);
    if (value == null) return FieldError.notAnInteger;
    if (value < 0) return FieldError.negative;
    return null;
  }

  static FieldError? rollingDays(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return FieldError.daysRequired;
    final value = parseInt(text);
    if (value == null) return FieldError.daysNotInteger;
    if (value < 1 || value > maxRollingDays) {
      return FieldError.rollingDaysOutOfRange;
    }
    return null;
  }

  static FieldError? reminderDays(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return FieldError.daysRequired;
    final value = parseInt(text);
    if (value == null) return FieldError.daysNotInteger;
    if (value < 0 || value > maxReminderDays) {
      return FieldError.reminderDaysOutOfRange;
    }
    return null;
  }

  static FieldError? lastUsedDate(DateTime? date, DateTime today) =>
      date != null && date.isAfter(today) ? FieldError.dateInFuture : null;
}
