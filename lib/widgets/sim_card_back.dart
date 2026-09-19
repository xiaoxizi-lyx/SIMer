import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sim_card.dart';
import '../models/enums.dart';
import '../models/tag.dart';
import '../data/countries.dart';
import '../theme/app_colors.dart';
import 'validity_countdown.dart';

/// SIM卡背面 – 完整详情视图
class SimCardBack extends StatelessWidget {
  final SimCard simCard;
  final List<Tag> tags;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;

  const SimCardBack({
    super.key,
    required this.simCard,
    this.tags = const [],
    this.onEdit,
    this.onArchive,
  });

  Color get _baseColor => Color(simCard.cardColor);
  Color get _textColor => AppColors.textOnColor(_baseColor);
  Color get _secondaryColor => _textColor.withValues(alpha: 0.65);
  Color get _dividerColor => _textColor.withValues(alpha: 0.15);

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(context),
              _divider(),
              // ── 基本信息 ──
              _buildSection('基本信息', [
                _infoRow('运营商', simCard.carrierName),
                _infoRow(
                  '国家/地区',
                  CountryData.displayName(simCard.countryCode),
                ),
                if (simCard.iccid != null && simCard.iccid!.isNotEmpty)
                  _infoRowWithCopy(context, 'ICCID', simCard.formattedIccid!,
                      simCard.iccid!),
                if (simCard.phoneNumbers.isNotEmpty)
                  ...simCard.phoneNumbers.asMap().entries.map(
                        (e) => _infoRow(
                          e.key == 0 ? '主号码' : '号码${e.key + 1}',
                          e.value,
                        ),
                      ),
                _infoRow('SIM类型', simCard.type.label),
              ]),
              _divider(),
              // ── 有效期 ──
              _buildSection('有效期', [
                _infoRow('类型', simCard.validityType.label),
                if (simCard.activationDate != null)
                  _infoRow('激活日期', _formatDate(simCard.activationDate!)),
                if (simCard.effectiveExpirationDate != null)
                  _infoRow(
                      '到期日期', _formatDate(simCard.effectiveExpirationDate!)),
                if (simCard.validityType == ValidityType.rolling &&
                    simCard.rollingDays != null)
                  _infoRow('滚动周期', '${simCard.rollingDays} 天'),
                if (simCard.lastUsedDate != null)
                  _infoRow('上次使用', _formatDate(simCard.lastUsedDate!)),
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
                _buildSection('用量', _buildUsageRows()),
              ],
              // ── 功能支持 ──
              if (simCard.features.supportedCount > 0) ...[
                _divider(),
                _buildSection('功能支持', _buildFeatureRows()),
              ],
              // ── eSIM信息 ──
              if (simCard.type == SimType.esim && _hasEsimInfo()) ...[
                _divider(),
                _buildSection('eSIM信息', [
                  if (simCard.rspServerAddress != null &&
                      simCard.rspServerAddress!.isNotEmpty)
                    _infoRowWithCopy(context, 'SM-DP+',
                        simCard.rspServerAddress!, simCard.rspServerAddress!),
                  if (simCard.activationCode != null &&
                      simCard.activationCode!.isNotEmpty)
                    _infoRowWithCopy(context, '激活码',
                        simCard.activationCode!, simCard.activationCode!),
                  if (simCard.confirmationCode != null &&
                      simCard.confirmationCode!.isNotEmpty)
                    _infoRow('确认码', simCard.confirmationCode!),
                ]),
              ],
              // ── 来源 / 备注 ──
              if ((simCard.source != null && simCard.source!.isNotEmpty) ||
                  (simCard.notes != null && simCard.notes!.isNotEmpty)) ...[
                _divider(),
                _buildSection('其他', [
                  if (simCard.source != null && simCard.source!.isNotEmpty)
                    _infoRow('来源', simCard.source!),
                  if (simCard.notes != null && simCard.notes!.isNotEmpty)
                    _infoRow('备注', simCard.notes!),
                ]),
              ],
              // ── 标签 ──
              if (simCard.tagIds.isNotEmpty && tags.isNotEmpty) ...[
                _divider(),
                _buildTagSection(),
              ],
              // ── 操作按钮 ──
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final emoji = CountryData.countryCodeToEmoji(simCard.countryCode);
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            simCard.carrierName,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
        ),
        Icon(
          Icons.flip_to_front_rounded,
          color: _secondaryColor,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _secondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowWithCopy(
    BuildContext context,
    String label,
    String displayValue,
    String copyValue,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _secondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: label == 'ICCID'
                  ? GoogleFonts.robotoMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _textColor,
                    )
                  : GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: copyValue));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已复制 $label'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Icon(
              Icons.copy_rounded,
              size: 14,
              color: _secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

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

  List<Widget> _buildUsageRows() {
    final rows = <Widget>[];
    if (simCard.dataBalanceMB != null || simCard.dataTotalMB != null) {
      final balance = simCard.dataBalanceMB;
      final total = simCard.dataTotalMB;
      String val = '';
      if (balance != null && total != null) {
        val = '${_formatMB(balance)} / ${_formatMB(total)}';
      } else if (balance != null) {
        val = '剩余 ${_formatMB(balance)}';
      } else if (total != null) {
        val = '总量 ${_formatMB(total)}';
      }
      rows.add(_infoRow('流量', val));
    }
    if (simCard.voiceMinutesRemaining != null ||
        simCard.voiceMinutesTotal != null) {
      final rem = simCard.voiceMinutesRemaining;
      final total = simCard.voiceMinutesTotal;
      String val = '';
      if (rem != null && total != null) {
        val = '${rem.toStringAsFixed(0)} / ${total.toStringAsFixed(0)} 分钟';
      } else if (rem != null) {
        val = '剩余 ${rem.toStringAsFixed(0)} 分钟';
      } else if (total != null) {
        val = '总量 ${total.toStringAsFixed(0)} 分钟';
      }
      rows.add(_infoRow('通话', val));
    }
    if (simCard.smsRemaining != null || simCard.smsTotal != null) {
      final rem = simCard.smsRemaining;
      final total = simCard.smsTotal;
      String val = '';
      if (rem != null && total != null) {
        val = '$rem / $total 条';
      } else if (rem != null) {
        val = '剩余 $rem 条';
      } else if (total != null) {
        val = '总量 $total 条';
      }
      rows.add(_infoRow('短信', val));
    }
    if (simCard.balance != null) {
      final currency = simCard.balanceCurrency ?? '';
      rows.add(_infoRow('余额', '$currency ${simCard.balance!.toStringAsFixed(2)}'));
    }
    return rows;
  }

  String _formatMB(double mb) {
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(0)} MB';
  }

  List<Widget> _buildFeatureRows() {
    return simCard.features.entries
        .where((e) => e.value.supported)
        .map((e) {
      final note = e.value.note;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                size: 14, color: AppColors.statusActive),
            const SizedBox(width: 6),
            Text(
              e.key,
              style: GoogleFonts.inter(
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
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _secondaryColor,
                  ),
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
    final matchedTags =
        tags.where((t) => simCard.tagIds.contains(t.id)).toList();
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
                style: GoogleFonts.inter(
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

  Widget _buildActions() {
    return Row(
      children: [
        if (onEdit != null)
          Expanded(
            child: _actionButton(
              icon: Icons.edit_rounded,
              label: '编辑',
              onTap: onEdit!,
            ),
          ),
        if (onEdit != null && onArchive != null) const SizedBox(width: 10),
        if (onArchive != null)
          Expanded(
            child: _actionButton(
              icon: simCard.status == SimStatus.archived
                  ? Icons.unarchive_rounded
                  : Icons.archive_rounded,
              label: simCard.status == SimStatus.archived ? '取消归档' : '归档',
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
              style: GoogleFonts.inter(
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
