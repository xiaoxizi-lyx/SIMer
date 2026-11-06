import 'package:flutter/material.dart';

import '../../../models/tag.dart';
import '../../../widgets/color_picker_dialog.dart';
import '../form_widgets.dart';
import '../sim_form_draft.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key, required this.draft, required this.tags});

  final SimFormDraft draft;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    final color = draft.cardColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('卡片颜色'),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final picked = await ColorPickerDialog.show(
              context,
              currentColor: color,
              carrierDefaultColor: draft.carrierDefaultColor,
              carrierName: draft.carrierName,
            );
            if (picked != null) draft.chooseColor(picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.chevron_right_rounded),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Text('更改颜色', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const FieldLabel('标签'),
        if (tags.isEmpty)
          Text(
            '还没有标签，可在「设置 → 标签管理」中添加',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.5),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                FilterChip(
                  showCheckmark: false,
                  selected: draft.tagIds.contains(tag.id),
                  onSelected: (selected) => draft.update(() {
                    selected
                        ? draft.tagIds.add(tag.id!)
                        : draft.tagIds.remove(tag.id);
                  }),
                  label: Row(
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
                      Text(tag.name),
                    ],
                  ),
                ),
            ],
          ),
        const SizedBox(height: 16),
        const FieldLabel('来源渠道'),
        TextFormField(
          controller: draft.source,
          decoration: const InputDecoration(hintText: '例如：官网、线下门店、朋友转让'),
        ),
        const SizedBox(height: 12),
        const FieldLabel('备注'),
        TextFormField(
          controller: draft.notes,
          decoration: const InputDecoration(hintText: '其他备忘信息'),
          maxLines: 3,
        ),
      ],
    );
  }
}
