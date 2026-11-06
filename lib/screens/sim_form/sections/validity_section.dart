import 'package:flutter/material.dart';

import '../../../models/calendar_date.dart';
import '../../../models/enums.dart';
import '../../../theme/app_colors.dart';
import '../form_widgets.dart';
import '../sim_form_draft.dart';
import '../sim_form_validators.dart';

class ValiditySection extends StatelessWidget {
  const ValiditySection({
    super.key,
    required this.draft,
    required this.showErrors,
  });

  final SimFormDraft draft;
  final bool showErrors;

  @override
  Widget build(BuildContext context) {
    final today = CalendarDate.today();
    final type = draft.validityType;
    final secondary = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('有效期类型'),
        RadioGroup<ValidityType>(
          groupValue: type,
          onChanged: (value) {
            if (value != null) draft.update(() => draft.validityType = value);
          },
          child: Column(
            children: [
              for (final option in ValidityType.values)
                RadioListTile<ValidityType>(
                  value: option,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option.label,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    option.description,
                    style: TextStyle(fontSize: 11, color: secondary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const FieldLabel('激活日期'),
        DateField(
          value: draft.activationDate,
          hint: '选择激活日期（可选）',
          onChanged: (date) => draft.update(() => draft.activationDate = date),
        ),
        if (type == ValidityType.fixedDate) ...[
          const SizedBox(height: 12),
          const FieldLabel('到期日期'),
          DateField(
            value: draft.expirationDate,
            hint: '选择到期日期',
            helperText: '到期日当天仍然有效',
            errorText: showErrors && draft.expirationDate == null
                ? '请选择到期日期'
                : null,
            onChanged: (date) =>
                draft.update(() => draft.expirationDate = date),
          ),
        ],
        if (type == ValidityType.rolling) ...[
          const SizedBox(height: 12),
          const FieldLabel('滚动天数'),
          TextFormField(
            controller: draft.rollingDays,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '例如 180',
              suffixText: '天',
              helperText: '每次使用后，有效期从使用当天起重新计算这么多天',
              helperMaxLines: 2,
            ),
            validator: SimFormValidators.rollingDays,
          ),
          const SizedBox(height: 12),
          const FieldLabel('上次使用日期'),
          DateField(
            value: draft.lastUsedDate,
            hint: '未填写',
            lastDate: today,
            helperText: '未填写时按激活日期计算；激活日期也未填写时按添加日期计算',
            errorText: showErrors
                ? SimFormValidators.lastUsedDate(draft.lastUsedDate, today)
                : null,
            onChanged: (date) => draft.update(() => draft.lastUsedDate = date),
          ),
        ],
        if (type != ValidityType.noExpiration) ...[
          const SizedBox(height: 12),
          const FieldLabel('提前提醒天数'),
          TextFormField(
            controller: draft.reminderDays,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '例如 7',
              suffixText: '天',
              helperText: '到期前这么多天开始提醒，并显示为「即将到期」',
              helperMaxLines: 2,
            ),
            validator: SimFormValidators.reminderDays,
          ),
          const SizedBox(height: 12),
          _ExpirationPreview(draft: draft),
        ],
      ],
    );
  }
}

/// 按当前填写内容预览到期日，滚动天数修改时实时更新。
class _ExpirationPreview extends StatelessWidget {
  const _ExpirationPreview({required this.draft});

  final SimFormDraft draft;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([draft.rollingDays, draft.reminderDays]),
      builder: (context, _) {
        final card = draft.build(newUuid: '_preview');
        final expiration = card.effectiveExpirationDate;
        if (expiration == null) return const SizedBox.shrink();
        final days = card.daysRemaining!;
        final status = days < 0
            ? '已过期 ${-days} 天'
            : days == 0
            ? '今天到期'
            : '剩余 $days 天';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '到期日：${CalendarDate.format(expiration)}（$status）',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        );
      },
    );
  }
}
