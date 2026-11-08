import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
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
    final l = context.l10n;
    final today = CalendarDate.today();
    final type = draft.validityType;
    final secondary = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(l.formValidityType),
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
                    option.label(l),
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    option.description(l),
                    style: TextStyle(fontSize: 11, color: secondary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FieldLabel(l.formActivationDate),
        DateField(
          value: draft.activationDate,
          hint: l.formActivationDateHint,
          onChanged: (date) => draft.update(() => draft.activationDate = date),
        ),
        if (type == ValidityType.fixedDate) ...[
          const SizedBox(height: 12),
          FieldLabel(l.formExpirationDate),
          DateField(
            value: draft.expirationDate,
            hint: l.formExpirationDateHint,
            helperText: l.formExpirationHelper,
            errorText: showErrors && draft.expirationDate == null
                ? l.formErrorExpirationRequired
                : null,
            onChanged: (date) =>
                draft.update(() => draft.expirationDate = date),
          ),
        ],
        if (type == ValidityType.rolling) ...[
          const SizedBox(height: 12),
          FieldLabel(l.formRollingDays),
          TextFormField(
            controller: draft.rollingDays,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: l.formRollingDaysHint,
              suffixText: l.formDaysSuffix,
              helperText: l.formRollingDaysHelper,
              helperMaxLines: 2,
            ),
            validator: (value) =>
                SimFormValidators.rollingDays(value)?.message(l),
          ),
          const SizedBox(height: 12),
          FieldLabel(l.formLastUsedDate),
          DateField(
            value: draft.lastUsedDate,
            hint: l.formLastUsedHint,
            lastDate: today,
            helperText: l.formLastUsedHelper,
            errorText: showErrors
                ? SimFormValidators.lastUsedDate(
                    draft.lastUsedDate,
                    today,
                  )?.message(l)
                : null,
            onChanged: (date) => draft.update(() => draft.lastUsedDate = date),
          ),
        ],
        if (type != ValidityType.noExpiration) ...[
          const SizedBox(height: 12),
          FieldLabel(l.formReminderDays),
          TextFormField(
            controller: draft.reminderDays,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: l.formReminderDaysHint,
              suffixText: l.formDaysSuffix,
              helperText: l.formReminderDaysHelper,
              helperMaxLines: 2,
            ),
            validator: (value) =>
                SimFormValidators.reminderDays(value)?.message(l),
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
        final l = context.l10n;
        final days = card.daysRemaining!;
        final status = days < 0
            ? l.countdownExpiredDays(-days)
            : days == 0
            ? l.countdownDueToday
            : l.countdownDaysLeft(days);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            l.formExpirationPreview(CalendarDate.format(expiration), status),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        );
      },
    );
  }
}
