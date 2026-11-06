/// 添加/编辑表单的字段解析与校验（纯函数，便于单元测试）。
///
/// 校验函数返回错误文案，合法时返回 null。
abstract final class SimFormValidators {
  static const int maxRollingDays = 3650;
  static const int maxReminderDays = 365;

  static final RegExp _iccid = RegExp(r'^\d{18,22}$');
  static final RegExp _numberNoise = RegExp(r'[,，\s]');

  /// 去除空白：用户常从卡托或网页复制带空格的 ICCID。
  static String normalizeIccid(String raw) => raw.replaceAll(RegExp(r'\s'), '');

  static String? iccid(String? raw) {
    final value = normalizeIccid(raw ?? '');
    if (value.isEmpty) return null;
    if (!_iccid.hasMatch(value)) return 'ICCID 应为 18-22 位数字';
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
  static String? decimal(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return null;
    final value = parseDecimal(text);
    if (value == null) return '请输入有效的数字';
    if (value < 0) return '不能为负数';
    return null;
  }

  /// 可选的非负整数。
  static String? integer(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return null;
    final value = parseInt(text);
    if (value == null) return '请输入整数';
    if (value < 0) return '不能为负数';
    return null;
  }

  static String? rollingDays(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return '请输入天数';
    final value = parseInt(text);
    if (value == null) return '请输入整数天数';
    if (value < 1 || value > maxRollingDays) {
      return '天数应在 1-$maxRollingDays 之间';
    }
    return null;
  }

  static String? reminderDays(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return '请输入天数';
    final value = parseInt(text);
    if (value == null) return '请输入整数天数';
    if (value < 0 || value > maxReminderDays) {
      return '天数应在 0-$maxReminderDays 之间';
    }
    return null;
  }

  static String? lastUsedDate(DateTime? date, DateTime today) =>
      date != null && date.isAfter(today) ? '不能晚于今天' : null;
}
