import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/countries.dart';
import '../l10n/l10n.dart';
import '../models/enums.dart';
import '../models/sensitive_mask.dart';
import '../models/sim_card.dart';
import '../models/tag.dart';
import '../services/qr_parser_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import 'esim_qr_sheet.dart';
import 'validity_countdown.dart';

/// SIM卡背面 – 完整详情视图
class SimCardBack extends StatelessWidget {
  final SimCard simCard;
  final List<Tag> tags;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onMarkAsUsed;

  /// ICCID、激活码与确认码是否默认打码显示（见设置中的「隐藏敏感信息」）。
  final bool maskSensitive;

  const SimCardBack({
    super.key,
    required this.simCard,
    this.tags = const [],
    this.onEdit,
    this.onArchive,
    this.onMarkAsUsed,
    this.maskSensitive = true,
  });

  Color get _baseColor => Color(simCard.cardColor);
  Color get _textColor => AppColors.textOnColor(_baseColor);
  Color get _secondaryColor => _textColor.withValues(alpha: 0.65);
  Color get _dividerColor => _textColor.withValues(alpha: 0.15);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final gradient = AppColors.cardGradient(_baseColor);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 标题行 ──
              _buildHeader(l),
              _divider(),
              // ── 基本信息 ──
              _buildSection(l.backSectionBasic, [
                _infoRow(l.fieldCarrier, simCard.carrierLabel(l)),
                _infoRow(
                  l.fieldCountry,
                  CountryData.displayName(simCard.countryCode, l.localeName),
                ),
                if (simCard.iccid != null && simCard.iccid!.isNotEmpty)
                  _infoRowWithCopy(
                    'ICCID',
                    simCard.formattedIccid!,
                    simCard.iccid!,
                    monospace: true,
                    masked: SensitiveMask.iccid(simCard.iccid!),
                  ),
                if (simCard.phoneNumbers.isNotEmpty)
                  ...simCard.phoneNumbers.asMap().entries.map(
                    (e) => _infoRow(
                      e.key == 0
                          ? l.fieldPrimaryNumber
                          : l.fieldNumberN(e.key + 1),
                      e.value,
                    ),
                  ),
                _infoRow(l.fieldSimType, simCard.type.label(l)),
              ]),
              _divider(),
              // ── 有效期 ──
              _buildSection(l.backSectionValidity, [
                _infoRow(l.fieldValidityType, simCard.validityType.label(l)),
                if (simCard.activationDate != null)
                  _infoRow(
                    l.fieldActivationDate,
                    _formatDate(simCard.activationDate!),
                  ),
                if (simCard.effectiveExpirationDate != null)
                  _infoRow(
                    l.fieldExpirationDate,
                    _formatDate(simCard.effectiveExpirationDate!),
                  ),
                if (simCard.validityType == ValidityType.rolling &&
                    simCard.rollingDays != null)
                  _infoRow(
                    l.fieldRollingCycle,
                    l.daysCount(simCard.rollingDays!),
                  ),
                if (simCard.lastUsedDate != null)
                  _infoRow(l.fieldLastUsed, _formatDate(simCard.lastUsedDate!)),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ValidityCountdown(
                    daysRemaining: simCard.daysRemaining,
                    validityType: simCard.validityType,
                    rollingDays: simCard.rollingDays,
                    textColor: _textColor,
                    fontSize: 13,
                  ),
                ),
              ]),
              // ── 用量统计 ──
              if (_hasUsageData()) ...[
                _divider(),
                _buildSection(l.backSectionUsage, _buildUsageRows(l)),
              ],
              // ── 功能支持 ──
              if (simCard.features.supportedCount > 0) ...[
                _divider(),
                _buildSection(l.backSectionFeatures, _buildFeatureRows(l)),
              ],
              // ── eSIM信息 ──
              if (simCard.type == SimType.esim && _hasEsimInfo()) ...[
                _divider(),
                _buildSection(l.backSectionEsim, [
                  if (simCard.rspServerAddress != null &&
                      simCard.rspServerAddress!.isNotEmpty)
                    _infoRowWithCopy(
                      'SM-DP+',
                      simCard.rspServerAddress!,
                      simCard.rspServerAddress!,
                    ),
                  if (simCard.activationCode != null &&
                      simCard.activationCode!.isNotEmpty)
                    _infoRowWithCopy(
                      l.fieldMatchingId,
                      simCard.activationCode!,
                      simCard.activationCode!,
                      masked: SensitiveMask.code(simCard.activationCode!),
                    ),
                  if (simCard.confirmationCode != null &&
                      simCard.confirmationCode!.isNotEmpty)
                    _infoRowWithCopy(
                      l.fieldConfirmationCode,
                      simCard.confirmationCode!,
                      simCard.confirmationCode!,
                      masked: SensitiveMask.full(simCard.confirmationCode!),
                    ),
                  if (QrParserService.forCard(simCard) != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: _textColor,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => EsimQrSheet.show(context, simCard),
                        icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                        label: Text(l.esimQrShow),
                      ),
                    ),
                ]),
              ],
              // ── 来源 / 备注 ──
              if ((simCard.source != null && simCard.source!.isNotEmpty) ||
                  (simCard.notes != null && simCard.notes!.isNotEmpty)) ...[
                _divider(),
                _buildSection(l.backSectionOther, [
                  if (simCard.source != null && simCard.source!.isNotEmpty)
                    _infoRow(l.fieldSource, simCard.source!),
                  if (simCard.notes != null && simCard.notes!.isNotEmpty)
                    _infoRow(l.fieldNotes, simCard.notes!),
                ]),
              ],
              // ── 标签 ──
              if (simCard.tagIds.isNotEmpty && tags.isNotEmpty) ...[
                _divider(),
                _buildTagSection(),
              ],
              // ── 操作按钮 ──
              const SizedBox(height: 16),
              _buildActions(l),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    final emoji = CountryData.countryCodeToEmoji(simCard.countryCode);
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            simCard.carrierLabel(l),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
        ),
        Icon(Icons.flip_to_front_rounded, color: _secondaryColor, size: 20),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _secondaryColor,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _infoRow(String label, String value) => _InfoRow(
    label: label,
    value: value,
    textColor: _textColor,
    secondaryColor: _secondaryColor,
  );

  /// 带复制按钮的一行。[masked] 是打码后的显示内容，仅在开启「隐藏敏感信息」时使用。
  Widget _infoRowWithCopy(
    String label,
    String displayValue,
    String copyValue, {
    bool monospace = false,
    String? masked,
  }) => _InfoRow(
    label: label,
    value: displayValue,
    maskedValue: maskSensitive ? masked : null,
    copyValue: copyValue,
    monospace: monospace,
    textColor: _textColor,
    secondaryColor: _secondaryColor,
  );

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(color: _dividerColor, height: 1),
    );
  }

  bool _hasUsageData() {
    return simCard.dataBalanceMB != null ||
        simCard.dataTotalMB != null ||
        simCard.voiceMinutesRemaining != null ||
        simCard.smsRemaining != null ||
        simCard.balance != null;
  }

  List<Widget> _buildUsageRows(AppLocalizations l) {
    final rows = <Widget>[];
    if (simCard.dataBalanceMB != null || simCard.dataTotalMB != null) {
      final balance = simCard.dataBalanceMB;
      final total = simCard.dataTotalMB;
      String val = '';
      if (balance != null && total != null) {
        val = '${_formatMB(balance)} / ${_formatMB(total)}';
      } else if (balance != null) {
        val = l.usageRemaining(_formatMB(balance));
      } else if (total != null) {
        val = l.usageTotal(_formatMB(total));
      }
      rows.add(_infoRow(l.usageData, val));
    }
    if (simCard.voiceMinutesRemaining != null ||
        simCard.voiceMinutesTotal != null) {
      final rem = simCard.voiceMinutesRemaining;
      final total = simCard.voiceMinutesTotal;
      String val = '';
      if (rem != null && total != null) {
        val = l.usageMinutes(
          '${rem.toStringAsFixed(0)} / ${total.toStringAsFixed(0)}',
        );
      } else if (rem != null) {
        val = l.usageRemaining(l.usageMinutes(rem.toStringAsFixed(0)));
      } else if (total != null) {
        val = l.usageTotal(l.usageMinutes(total.toStringAsFixed(0)));
      }
      rows.add(_infoRow(l.usageVoice, val));
    }
    if (simCard.smsRemaining != null || simCard.smsTotal != null) {
      final rem = simCard.smsRemaining;
      final total = simCard.smsTotal;
      String val = '';
      if (rem != null && total != null) {
        val = l.usageMessages('$rem / $total');
      } else if (rem != null) {
        val = l.usageRemaining(l.usageMessages('$rem'));
      } else if (total != null) {
        val = l.usageTotal(l.usageMessages('$total'));
      }
      rows.add(_infoRow(l.usageSms, val));
    }
    if (simCard.balance != null) {
      final currency = simCard.balanceCurrency ?? '';
      rows.add(
        _infoRow(
          l.usageBalance,
          '$currency ${simCard.balance!.toStringAsFixed(2)}'.trim(),
        ),
      );
    }
    return rows;
  }

  String _formatMB(double mb) {
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(0)} MB';
  }

  List<Widget> _buildFeatureRows(AppLocalizations l) {
    return simCard.features.entries.where((e) => e.value.supported).map((e) {
      final note = e.value.note;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 14,
              color: AppColors.statusActive,
            ),
            const SizedBox(width: 6),
            Text(
              e.key.label(l),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _textColor,
              ),
            ),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note,
                  style: TextStyle(fontSize: 11, color: _secondaryColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  bool _hasEsimInfo() {
    return (simCard.rspServerAddress != null &&
            simCard.rspServerAddress!.isNotEmpty) ||
        (simCard.activationCode != null &&
            simCard.activationCode!.isNotEmpty) ||
        (simCard.confirmationCode != null &&
            simCard.confirmationCode!.isNotEmpty);
  }

  Widget _buildTagSection() {
    final matchedTags = tags
        .where((t) => simCard.tagIds.contains(t.id))
        .toList();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: matchedTags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Color(tag.color).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(tag.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                tag.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions(AppLocalizations l) {
    final markUsed = simCard.validityType == ValidityType.rolling
        ? onMarkAsUsed
        : null;
    return Row(
      spacing: 10,
      children: [
        if (onEdit != null)
          Expanded(
            child: _actionButton(
              icon: Icons.edit_rounded,
              label: l.commonEdit,
              onTap: onEdit!,
            ),
          ),
        if (markUsed != null)
          Expanded(
            child: _actionButton(
              icon: Icons.check_circle_outline_rounded,
              label: l.cardMarkUsed,
              onTap: markUsed,
            ),
          ),
        if (onArchive != null)
          Expanded(
            child: _actionButton(
              icon: simCard.isArchived
                  ? Icons.unarchive_rounded
                  : Icons.archive_rounded,
              label: simCard.isArchived ? l.cardUnarchive : l.cardArchive,
              onTap: onArchive!,
            ),
          ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _textColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: _textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// 卡片背面的一行信息：标签 + 值，可选复制按钮与打码。
///
/// 标签列宽度随界面语言调整：英文标签更长。
/// 有 [maskedValue] 时默认显示打码内容，点击眼睛图标切换；复制的始终是完整内容。
class _InfoRow extends StatefulWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.secondaryColor,
    this.maskedValue,
    this.copyValue,
    this.monospace = false,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color secondaryColor;

  /// 打码后的显示内容；为空表示不打码。
  final String? maskedValue;

  /// 不为空时显示复制按钮，复制此内容。
  final String? copyValue;
  final bool monospace;

  @override
  State<_InfoRow> createState() => _InfoRowState();
}

class _InfoRowState extends State<_InfoRow> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final copy = widget.copyValue;
    final masked = widget.maskedValue;
    final hidden = masked != null && !_revealed;
    final iconColor = widget.secondaryColor;

    Widget iconButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback onTap,
    }) => Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Icon(icon, size: 14, color: iconColor, semanticLabel: tooltip),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: l.localeName == 'zh' ? 72 : 112,
            child: Text(
              widget.label,
              style: TextStyle(fontSize: 12, color: widget.secondaryColor),
            ),
          ),
          Expanded(
            child: Text(
              hidden ? masked : widget.value,
              style: widget.monospace
                  ? TextStyle(
                      fontFamily: AppFonts.mono,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: widget.textColor,
                    )
                  : TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: widget.textColor,
                    ),
            ),
          ),
          if (masked != null)
            iconButton(
              icon: hidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              tooltip: hidden
                  ? l.sensitiveShow(widget.label)
                  : l.sensitiveHide(widget.label),
              onTap: () => setState(() => _revealed = !_revealed),
            ),
          if (copy != null)
            iconButton(
              icon: Icons.copy_rounded,
              tooltip: l.copyField(widget.label),
              onTap: () {
                unawaited(Clipboard.setData(ClipboardData(text: copy)));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.copiedField(widget.label)),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
