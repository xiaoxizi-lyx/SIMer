import 'package:flutter/material.dart';

import '../../models/calendar_date.dart';
import '../../theme/app_colors.dart';
import 'sim_form_draft.dart';

/// 可折叠的表单分区。
///
/// 折叠时内容仍保留在组件树中（[Offstage]），因此保存时能校验所有分区的字段，
/// 输入内容也不会因折叠而丢失。
class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.section,
    required this.expanded,
    required this.hasError,
    required this.onToggle,
    required this.children,
  });

  final SimFormSection section;
  final bool expanded;
  final bool hasError;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = hasError
        ? theme.colorScheme.error
        : expanded
        ? AppColors.primary.withValues(alpha: 0.3)
        : theme.dividerTheme.color ?? AppColors.lightDivider;

    // 使用 Material 承载背景，ListTile / InkWell 的水波纹才能正常显示
    return Material(
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor,
          width: expanded || hasError ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(section.icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasError) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.error_rounded,
                      size: 16,
                      color: theme.colorScheme.error,
                      semanticLabel: '此分区有需要修改的内容',
                    ),
                  ],
                  const Spacer(),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Offstage(
              offstage: !expanded,
              child: TickerMode(
                enabled: expanded,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 字段上方的小标题。
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

/// 可选择、可清除的日期字段。
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.value,
    required this.hint,
    required this.onChanged,
    this.errorText,
    this.helperText,
    this.lastDate,
  });

  final DateTime? value;
  final String hint;
  final ValueChanged<DateTime?> onChanged;
  final String? errorText;
  final String? helperText;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final date = value;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final last = lastDate ?? DateTime(2100);
        final initial = date ?? CalendarDate.today();
        final picked = await showDatePicker(
          context: context,
          initialDate: initial.isAfter(last) ? last : initial,
          firstDate: DateTime(2000),
          lastDate: last,
        );
        if (picked != null) onChanged(CalendarDate.of(picked));
      },
      child: InputDecorator(
        isEmpty: date == null,
        decoration: InputDecoration(
          hintText: hint,
          errorText: errorText,
          helperText: helperText,
          helperMaxLines: 2,
          prefixIcon: const Icon(Icons.event_rounded, size: 20),
          suffixIcon: date == null
              ? const Icon(Icons.chevron_right_rounded)
              : IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  tooltip: '清除日期',
                  onPressed: () => onChanged(null),
                ),
        ),
        child: date == null ? null : Text(CalendarDate.format(date)),
      ),
    );
  }
}

/// 点击后弹出选择器的只读字段（运营商、国家等）。
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.icon,
    required this.text,
    required this.hint,
    required this.onTap,
    this.errorText,
  });

  final IconData icon;
  final String text;
  final String hint;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        isEmpty: text.isEmpty,
        decoration: InputDecoration(
          hintText: hint,
          errorText: errorText,
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: const Icon(Icons.chevron_right_rounded),
        ),
        child: text.isEmpty ? null : Text(text),
      ),
    );
  }
}
