import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/carriers.dart';
import '../../../data/countries.dart';
import '../../../l10n/l10n.dart';
import '../../../models/enums.dart';
import '../../../theme/app_fonts.dart';
import '../../../widgets/carrier_picker_sheet.dart';
import '../../../widgets/country_picker_sheet.dart';
import '../form_widgets.dart';
import '../sim_form_draft.dart';
import '../sim_form_validators.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    super.key,
    required this.draft,
    required this.showErrors,
  });

  final SimFormDraft draft;
  final bool showErrors;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final missingCarrier = showErrors && draft.carrierName.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(l.formSimType),
        SegmentedButton<SimType>(
          segments: [
            for (final type in SimType.values)
              ButtonSegment(
                value: type,
                label: Text(type.label(l)),
                icon: Icon(
                  type == SimType.esim
                      ? Icons.qr_code_rounded
                      : Icons.sim_card_outlined,
                  size: 18,
                ),
              ),
          ],
          selected: {draft.type},
          onSelectionChanged: (selection) =>
              draft.update(() => draft.type = selection.first),
        ),
        const SizedBox(height: 16),
        FieldLabel(l.formActivationStatus),
        SegmentedButton<ActivationStatus>(
          segments: [
            for (final status in ActivationStatus.values)
              ButtonSegment(value: status, label: Text(status.label(l))),
          ],
          selected: {draft.activationStatus},
          onSelectionChanged: (selection) =>
              draft.update(() => draft.activationStatus = selection.first),
        ),
        const SizedBox(height: 16),
        FieldLabel(l.fieldCarrier),
        PickerField(
          icon: Icons.cell_tower_rounded,
          text: CarrierData.displayName(
            carrierCode: draft.carrierCode,
            storedName: draft.carrierName,
            languageCode: l.localeName,
          ),
          hint: l.formCarrierHint,
          errorText: missingCarrier ? l.formCarrierRequired : null,
          onTap: () async {
            final choice = await CarrierPickerSheet.show(
              context,
              countryCode: draft.countryCode,
            );
            if (choice != null) draft.chooseCarrier(choice);
          },
        ),
        const SizedBox(height: 16),
        FieldLabel(l.fieldCountry),
        PickerField(
          icon: Icons.public_rounded,
          text: CountryData.displayName(draft.countryCode, l.localeName),
          hint: l.countryPickerTitle,
          onTap: () async {
            final code = await CountryPickerSheet.show(context);
            if (code != null) draft.update(() => draft.countryCode = code);
          },
        ),
        const SizedBox(height: 16),
        const FieldLabel('ICCID'),
        TextFormField(
          controller: draft.iccid,
          decoration: InputDecoration(
            hintText: l.formIccidHint,
            prefixIcon: const Icon(Icons.credit_card_rounded, size: 20),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
          ],
          style: const TextStyle(fontFamily: AppFonts.mono, fontSize: 14),
          validator: (value) => SimFormValidators.iccid(value)?.message(l),
        ),
        const SizedBox(height: 16),
        FieldLabel(l.formPhoneNumbers),
        for (final (index, controller) in draft.phones.indexed)
          Padding(
            key: ObjectKey(controller),
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: index == 0
                          ? l.fieldPrimaryNumber
                          : l.fieldNumberN(index + 1),
                      prefixIcon: const Icon(Icons.phone_rounded, size: 20),
                    ),
                  ),
                ),
                if (draft.phones.length > 1)
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    tooltip: l.formRemoveNumber,
                    onPressed: () => draft.removePhone(index),
                  ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: draft.addPhone,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l.formAddNumber),
          ),
        ),
      ],
    );
  }
}
