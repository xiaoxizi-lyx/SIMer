import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/enums.dart';
import '../theme/app_colors.dart';

/// 有效期倒计时组件
///
/// 根据剩余天数自动变色：
/// - 绿色 >30天 | 橙色 7-30天 | 红色 <7天（附脉冲动画）| 灰色已过期
class ValidityCountdown extends StatefulWidget {
  final int? daysRemaining;
  final ValidityType validityType;
  final int? rollingDays;
  final Color textColor;
  final double fontSize;
  final bool compact;

  const ValidityCountdown({
    super.key,
    required this.daysRemaining,
    required this.validityType,
    this.rollingDays,
    this.textColor = Colors.white,
    this.fontSize = 13,
    this.compact = false,
  });

  @override
  State<ValidityCountdown> createState() => _ValidityCountdownState();
}

class _ValidityCountdownState extends State<ValidityCountdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _updatePulse();
  }

  @override
  void didUpdateWidget(covariant ValidityCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePulse();
  }

  void _updatePulse() {
    final days = widget.daysRemaining;
    if (days != null && days >= 0 && days < 7) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _countdownColor {
    final days = widget.daysRemaining;
    if (days == null) return widget.textColor.withValues(alpha: 0.6);
    if (days < 0) return AppColors.countdownExpired;
    if (days < 7) return AppColors.countdownDanger;
    if (days <= 30) return AppColors.countdownWarning;
    return AppColors.countdownSafe;
  }

  IconData get _icon {
    final days = widget.daysRemaining;
    if (days == null) return Icons.all_inclusive_rounded;
    if (days < 0) return Icons.error_outline_rounded;
    if (days < 7) return Icons.warning_amber_rounded;
    return Icons.timer_outlined;
  }

  @override
  Widget build(BuildContext context) {
    // 无期限
    if (widget.validityType == ValidityType.noExpiration) {
      return _buildRow(
        icon: Icons.all_inclusive_rounded,
        text: '无期限',
        color: widget.textColor.withValues(alpha: 0.6),
        animate: false,
      );
    }

    final days = widget.daysRemaining;
    final color = _countdownColor;

    // 已过期
    if (days != null && days < 0) {
      return _buildRow(
        icon: _icon,
        text: '已过期 ${-days} 天',
        color: color,
        animate: false,
      );
    }

    // 滚动有效期的特殊提示
    String rollingHint = '';
    if (widget.validityType == ValidityType.rolling &&
        widget.rollingDays != null) {
      rollingHint = ' · ${widget.rollingDays}天一用';
    }

    // 正常倒计时
    final text = days != null ? '剩余 $days 天$rollingHint' : '未设定';
    final shouldPulse = days != null && days >= 0 && days < 7;

    return _buildRow(
      icon: _icon,
      text: text,
      color: color,
      animate: shouldPulse,
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String text,
    required Color color,
    required bool animate,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: widget.fontSize + 2, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );

    if (animate) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _pulseAnimation.value,
            child: child,
          );
        },
        child: content,
      );
    }

    return content;
  }
}
