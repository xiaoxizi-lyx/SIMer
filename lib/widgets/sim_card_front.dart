import 'package:flutter/material.dart';

import '../models/sim_card.dart';
import '../models/enums.dart';
import '../models/tag.dart';
import '../data/countries.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import 'validity_countdown.dart';

/// SIM卡正面 – Apple Wallet 风格
class SimCardFront extends StatelessWidget {
  final SimCard simCard;
  final List<Tag> tags;
  final VoidCallback? onMarkAsUsed;

  const SimCardFront({
    super.key,
    required this.simCard,
    this.tags = const [],
    this.onMarkAsUsed,
  });

  Color get _baseColor => Color(simCard.cardColor);

  Color get _textColor => AppColors.textOnColor(_baseColor);

  Color get _secondaryTextColor => _textColor.withValues(alpha: 0.7);

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.cardGradient(_baseColor);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _baseColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 顶部行：旗帜+运营商名 / 状态徽章 ──
              _buildTopRow(),
              const Spacer(),
              // ── 中部：号码 + 倒计时 ──
              _buildMiddleSection(),
              const Spacer(),
              // ── 底部：ICCID / SIM类型+标签 ──
              _buildBottomRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    final emoji = CountryData.countryCodeToEmoji(simCard.countryCode);
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            simCard.carrierName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    // 归档 > 已过期 > 用户设置的激活状态
    final (String label, Color badgeColor) = simCard.isArchived
        ? ('已归档', AppColors.statusArchived)
        : simCard.isExpired
        ? (ValidityState.expired.label, AppColors.statusExpired)
        : switch (simCard.activationStatus) {
            ActivationStatus.active => (
              ActivationStatus.active.label,
              AppColors.statusActive,
            ),
            ActivationStatus.inactive => (
              ActivationStatus.inactive.label,
              AppColors.statusInactive,
            ),
          };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColor == Colors.white ? Colors.white : badgeColor,
        ),
      ),
    );
  }

  Widget _buildMiddleSection() {
    // 滚动有效期卡在提醒窗口内或已过期时，在正面直接提供续期按钮
    final state = simCard.validityState;
    final showMarkUsed =
        simCard.validityType == ValidityType.rolling &&
        (state == ValidityState.expiringSoon || state == ValidityState.expired);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主号码
        if (simCard.primaryNumber != null)
          Text(
            simCard.primaryNumber!,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textColor,
              letterSpacing: 1.2,
            ),
          ),
        // 次要号码
        if (simCard.phoneNumbers.length > 1) ...[
          const SizedBox(height: 2),
          Text(
            simCard.phoneNumbers.skip(1).join(' · '),
            style: TextStyle(fontSize: 12, color: _secondaryTextColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 6),
        // 倒计时 + 滚动有效期按钮
        Row(
          children: [
            ValidityCountdown(
              daysRemaining: simCard.daysRemaining,
              validityType: simCard.validityType,
              rollingDays: simCard.rollingDays,
              textColor: _textColor,
              fontSize: 12,
            ),
            if (showMarkUsed && onMarkAsUsed != null) ...[
              const SizedBox(width: 8),
              _buildMarkUsedButton(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMarkUsedButton() {
    return GestureDetector(
      onTap: onMarkAsUsed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              '我已使用',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomRow() {
    // 找到第一个匹配的标签
    Tag? firstTag;
    if (simCard.tagIds.isNotEmpty && tags.isNotEmpty) {
      for (final tag in tags) {
        if (simCard.tagIds.contains(tag.id)) {
          firstTag = tag;
          break;
        }
      }
    }

    return Row(
      children: [
        // ICCID
        Expanded(
          child: Text(
            simCard.formattedIccid ?? '',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: _secondaryTextColor,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        // SIM类型图标
        Icon(
          simCard.type == SimType.esim
              ? Icons.qr_code_rounded
              : Icons.sim_card_outlined,
          size: 16,
          color: _secondaryTextColor,
        ),
        // 标签名
        if (firstTag != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _textColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              firstTag.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _secondaryTextColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
