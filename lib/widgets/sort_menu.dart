import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/enums.dart';
import '../theme/app_colors.dart';

/// 排序菜单弹出组件
class SortMenu extends StatelessWidget {
  final SortBy currentSortBy;
  final SortOrder currentSortOrder;
  final ValueChanged<SortBy> onSortByChanged;
  final ValueChanged<SortOrder> onSortOrderChanged;

  const SortMenu({
    super.key,
    required this.currentSortBy,
    required this.currentSortOrder,
    required this.onSortByChanged,
    required this.onSortOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortBy>(
      icon: Icon(
        Icons.sort_rounded,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      tooltip: '排序',
      onSelected: (sortBy) {
        if (sortBy == currentSortBy) {
          // 相同排序项 → 切换升降序
          onSortOrderChanged(currentSortOrder.toggled);
        } else {
          onSortByChanged(sortBy);
        }
      },
      itemBuilder: (context) {
        return SortBy.values.map((sortBy) {
          final isSelected = sortBy == currentSortBy;
          return PopupMenuItem<SortBy>(
            value: sortBy,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: isSelected
                      ? Icon(
                          currentSortOrder == SortOrder.ascending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 18,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  sortBy.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
