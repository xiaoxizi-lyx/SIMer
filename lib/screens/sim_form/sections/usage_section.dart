import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../form_widgets.dart';
import '../sim_form_draft.dart';
import '../sim_form_validators.dart';

class UsageSection extends StatelessWidget {
  const UsageSection({super.key, required this.draft});

  final SimFormDraft draft;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget field(
      String label,
      TextEditingController controller, {
      String? hint,
      bool integer = false,
    }) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
            keyboardType: TextInputType.numberWithOptions(decimal: !integer),
            validator: (value) =>
                (integer
                        ? SimFormValidators.integer(value)
                        : SimFormValidators.decimal(value))
                    ?.message(l),
          ),
        ],
      ),
    );

    Widget row(List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: children,
      ),
    );

    return Column(
      children: [
        row([
          field(
            l.formDataRemaining,
            draft.dataBalance,
            hint: l.formDataRemainingHint,
          ),
          field(l.formDataTotal, draft.dataTotal, hint: l.formDataTotalHint),
        ]),
        row([
          field(l.formVoiceRemaining, draft.voiceRemaining),
          field(l.formVoiceTotal, draft.voiceTotal),
        ]),
        row([
          field(l.formSmsRemaining, draft.smsRemaining, integer: true),
          field(l.formSmsTotal, draft.smsTotal, integer: true),
        ]),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FieldLabel(l.formBalance),
                  TextFormField(
                    controller: draft.balance,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) =>
                        SimFormValidators.decimal(value)?.message(l),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FieldLabel(l.formCurrency),
                  TextFormField(
                    controller: draft.currency,
                    decoration: const InputDecoration(hintText: 'CNY'),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
