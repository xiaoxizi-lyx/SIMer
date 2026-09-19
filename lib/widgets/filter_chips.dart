import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/enums.dart';
import '../data/countries.dart';
import '../theme/app_colors.dart';

/// 筛选条件回调
typedef FilterCallback = void Function(String type, String? value);

/// 水平滚动筛选条
///
/// 包含状态筛选、国家筛选、标签筛选三组 chip
class FilterChips extends StatelessWidget {
  // 当前筛选状态
  final SimStatus? statusFilter;
  final String? countryFilter;
  final List<int> tagFilters;

  // 可用选项
  final Set<String> availableCountries;
  final List<MapEntry<int, String>> availableTags; // id → name

  // 回调
  final ValueChanged<SimStatus?> onStatusChanged;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<List<int>> onTagsChanged;

  const FilterChips({
    super.key,
    required this.statusFilter,
    required this.countryFilter,
    required this.tagFilters,
    required this.availableCountries,
    required this.availableTags,
    required this.onStatusChanged,
    required this.onCountryChanged,
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
            label: '全部',
            isSelected: statusFilter == null,
            onTap: () => onStatusChanged(null),
            chipTextColor: chipTextColor,
          ),
          ...SimStatus.values
              .where((s) => s != SimStatus.archived)
              .map((status) {
            return _buildChip(
              context: context,
              label: status.label,
              isSelected: statusFilter == status,
              onTap: () => onStatusChanged(
                statusFilter == status ? null : status,
              ),
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
              label: '$emoji ${CountryData.countries[code] ?? code}',
              isSelected: countryFilter == code,
              onTap: () => onCountryChanged(
                countryFilter == code ? null : code,
              ),
              chipTextColor: chipTextColor,
            );
          }),

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
                decoration: BoxDecoration(
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
        labelStyle: GoogleFonts.inter(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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

  Color _statusColor(SimStatus status) {
    switch (status) {
      case SimStatus.active:
        return AppColors.statusActive;
      case SimStatus.inactive:
        return AppColors.statusInactive;
      case SimStatus.expired:
        return AppColors.statusExpired;
      case SimStatus.archived:
        return AppColors.statusArchived;
    }
  }
}
