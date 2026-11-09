import 'package:flutter/material.dart';

import '../data/countries.dart';
import '../l10n/l10n.dart';
import '../models/enums.dart';
import '../theme/app_colors.dart';

/// 水平滚动筛选条
///
/// 包含状态筛选、国家筛选、标签筛选三组 chip
class FilterChips extends StatelessWidget {
  // 当前筛选状态
  final StatusFilter? statusFilter;
  final String? countryFilter;
  final String? carrierFilter;
  final List<int> tagFilters;

  // 可用选项
  final Map<StatusFilter, int> statusCounts;
  final Set<String> availableCountries;

  /// 卡片中保存的运营商名称 → 显示名称（按界面语言）。
  final List<MapEntry<String, String>> availableCarriers;
  final List<MapEntry<int, String>> availableTags; // id → name

  // 回调
  final ValueChanged<StatusFilter?> onStatusChanged;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onCarrierChanged;
  final ValueChanged<List<int>> onTagsChanged;

  const FilterChips({
    super.key,
    required this.statusFilter,
    required this.countryFilter,
    required this.carrierFilter,
    required this.tagFilters,
    required this.statusCounts,
    required this.availableCountries,
    required this.availableCarriers,
    required this.availableTags,
    required this.onStatusChanged,
    required this.onCountryChanged,
    required this.onCarrierChanged,
    required this.onTagsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipTextColor = isDark ? AppColors.darkText : AppColors.lightText;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // ── 状态筛选 ──
          _buildChip(
            context: context,
            label: context.l10n.filterAll,
            isSelected: statusFilter == null,
            onTap: () => onStatusChanged(null),
            chipTextColor: chipTextColor,
          ),
          ...StatusFilter.values.map((status) {
            final count = statusCounts[status] ?? 0;
            return _buildChip(
              context: context,
              label: count > 0
                  ? '${status.label(context.l10n)} $count'
                  : status.label(context.l10n),
              isSelected: statusFilter == status,
              onTap: () =>
                  onStatusChanged(statusFilter == status ? null : status),
              statusColor: _statusColor(status),
              chipTextColor: chipTextColor,
            );
          }),

          // ── 分隔 ──
          if (availableCountries.isNotEmpty) _chipDivider(),

          // ── 国家筛选 ──
          ...availableCountries.map((code) {
            final emoji = CountryData.countryCodeToEmoji(code);
            return _buildChip(
              context: context,
              label:
                  '$emoji ${CountryData.name(code, context.l10n.localeName)}',
              isSelected: countryFilter == code,
              onTap: () =>
                  onCountryChanged(countryFilter == code ? null : code),
              chipTextColor: chipTextColor,
            );
          }),

          // ── 运营商筛选（至少两家运营商时才有意义） ──
          if (availableCarriers.length > 1) ...[
            _chipDivider(),
            ...availableCarriers.map(
              (carrier) => _buildChip(
                context: context,
                label: carrier.value,
                isSelected: carrierFilter == carrier.key,
                onTap: () => onCarrierChanged(
                  carrierFilter == carrier.key ? null : carrier.key,
                ),
                chipTextColor: chipTextColor,
              ),
            ),
          ],

          // ── 标签筛选 ──
          if (availableTags.isNotEmpty) _chipDivider(),
          ...availableTags.map((tag) {
            final isSelected = tagFilters.contains(tag.key);
            return _buildChip(
              context: context,
              label: tag.value,
              isSelected: isSelected,
              onTap: () {
                final updated = List<int>.from(tagFilters);
                if (isSelected) {
                  updated.remove(tag.key);
                } else {
                  updated.add(tag.key);
                }
                onTagsChanged(updated);
              },
              chipTextColor: chipTextColor,
            );
          }),

          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color chipTextColor,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (statusColor != null && isSelected) ...[
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ] else if (statusColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? Colors.white : chipTextColor,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: AppColors.primary,
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : Theme.of(context).dividerTheme.color ?? AppColors.lightDivider,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _chipDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Container(width: 1, color: AppColors.lightDivider),
    );
  }

  Color _statusColor(StatusFilter status) => switch (status) {
    StatusFilter.active => AppColors.statusActive,
    StatusFilter.inactive => AppColors.statusInactive,
    StatusFilter.expiringSoon => AppColors.countdownWarning,
    StatusFilter.expired => AppColors.statusExpired,
  };
}
