import 'package:flutter/material.dart';

import '../form_widgets.dart';
import '../sim_form_draft.dart';
import '../sim_form_validators.dart';

class UsageSection extends StatelessWidget {
  const UsageSection({super.key, required this.draft});

  final SimFormDraft draft;

  @override
  Widget build(BuildContext context) {
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
            validator: integer
                ? SimFormValidators.integer
                : SimFormValidators.decimal,
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
          field('流量剩余 (MB)', draft.dataBalance, hint: '例如 1024'),
          field('流量总量 (MB)', draft.dataTotal, hint: '例如 5120'),
        ]),
        row([
          field('通话剩余（分钟）', draft.voiceRemaining),
          field('通话总量（分钟）', draft.voiceTotal),
        ]),
        row([
          field('短信剩余', draft.smsRemaining, integer: true),
          field('短信总量', draft.smsTotal, integer: true),
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
                  const FieldLabel('话费余额'),
                  TextFormField(
                    controller: draft.balance,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: SimFormValidators.decimal,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('币种'),
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
