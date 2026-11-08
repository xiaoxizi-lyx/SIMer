/// 敏感信息的打码显示。只影响显示：复制与保存的仍是完整内容。
abstract final class SensitiveMask {
  static const String _dot = '•';

  /// ICCID：每 4 位一组，只显示第一组与最后一组，中间各组打码。
  ///
  /// 例如 `89860012345678901234` → `8986 •••• •••• •••• 1234`；
  /// 不超过两组（8 位）时全部打码。
  static String iccid(String iccid) {
    final digits = iccid.replaceAll(RegExp(r'\s'), '');
    final groups = [
      for (var i = 0; i < digits.length; i += 4)
        digits.substring(i, i + 4 > digits.length ? digits.length : i + 4),
    ];
    if (groups.length <= 2) {
      return groups.map((g) => _dot * g.length).join(' ');
    }
    return [
      groups.first,
      for (final g in groups.sublist(1, groups.length - 1)) _dot * g.length,
      groups.last,
    ].join(' ');
  }

  /// 激活码（匹配 ID）等：保留首尾各 4 个字符，中间固定显示 4 个点，不暴露长度；
  /// 不超过 8 个字符时全部打码。
  static String code(String value) {
    if (value.length <= 8) return full(value);
    return '${value.substring(0, 4)}${_dot * 4}'
        '${value.substring(value.length - 4)}';
  }

  /// 全部打码（例如确认码），不暴露长度。
  static String full(String value) => _dot * 6;
}
