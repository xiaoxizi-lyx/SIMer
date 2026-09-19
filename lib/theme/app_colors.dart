import 'package:flutter/material.dart';

/// App 颜色常量定义
class AppColors {
  AppColors._();

  // ── 亮色主题 ──
  static const Color lightBackground = Color(0xFFFAF8F5); // 米白
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);
  static const Color lightDivider = Color(0xFFE8E6E3);

  // ── 暗色主题 ──
  static const Color darkBackground = Color(0xFF1C1C1E); // 深灰（非纯黑）
  static const Color darkSurface = Color(0xFF2C2C2E);
  static const Color darkCard = Color(0xFF2C2C2E);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFF9A9A9A);
  static const Color darkDivider = Color(0xFF3A3A3C);

  // ── 状态颜色 ──
  static const Color statusActive = Color(0xFF34C759); // 激活 - 绿色
  static const Color statusInactive = Color(0xFF5AC8FA); // 未激活 - 蓝色
  static const Color statusExpired = Color(0xFF8E8E93); // 已过期 - 灰色
  static const Color statusArchived = Color(0xFF636366); // 已归档 - 暗灰

  // ── 有效期倒计时颜色 ──
  static const Color countdownSafe = Color(0xFF34C759); // > 30天
  static const Color countdownWarning = Color(0xFFFF9500); // 7-30天
  static const Color countdownDanger = Color(0xFFFF3B30); // < 7天
  static const Color countdownExpired = Color(0xFF8E8E93); // 已过期

  // ── 强调色 ──
  static const Color primary = Color(0xFF5E5CE6); // 主色 - 靛蓝紫
  static const Color primaryLight = Color(0xFF7A78E8);
  static const Color accent = Color(0xFFFF9F0A); // 辅助色 - 琥珀

  // ── 卡片默认配色池（当运营商颜色未知时随机分配） ──
  static const List<Color> cardColorPool = [
    Color(0xFF5E5CE6), // 靛蓝紫
    Color(0xFFFF6482), // 珊瑚粉
    Color(0xFF30D158), // 翠绿
    Color(0xFFFF9F0A), // 琥珀
    Color(0xFF64D2FF), // 天蓝
    Color(0xFFBF5AF2), // 紫罗兰
    Color(0xFFFF453A), // 绯红
    Color(0xFFFFD60A), // 金黄
    Color(0xFFAC8E68), // 青铜
    Color(0xFF00C7BE), // 薄荷
    Color(0xFFFF375F), // 玫红
    Color(0xFF5856D6), // 鸢尾蓝
    Color(0xFF30B0C7), // 深天蓝
    Color(0xFFE85D75), // 玫瑰
    Color(0xFF40C8E0), // 蔚蓝
    Color(0xFFA07DD7), // 薰衣草
  ];

  /// 根据已有颜色集，从颜色池中选择一个未被使用的颜色
  static Color pickUniqueColor(Set<int> usedColors) {
    for (final color in cardColorPool) {
      if (!usedColors.contains(color.toARGB32())) {
        return color;
      }
    }
    // 如果颜色池用完，基于池大小生成 HSL 色相偏移
    final hue = (usedColors.length * 37.0) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.55).toColor();
  }

  /// 根据背景颜色亮度决定前景文字颜色
  static Color textOnColor(Color background) {
    return background.computeLuminance() > 0.5
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFFFFFFF);
  }

  /// 生成卡片渐变色（基于主题色）
  static List<Color> cardGradient(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    return [
      hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor(),
      baseColor,
      hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor(),
    ];
  }
}
