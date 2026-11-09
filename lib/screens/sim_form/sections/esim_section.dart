import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/l10n.dart';
import '../../../services/qr_parser_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';
import '../form_widgets.dart';
import '../sim_form_draft.dart';

class EsimSection extends StatelessWidget {
  const EsimSection({super.key, required this.draft, required this.onScan});

  final SimFormDraft draft;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    const mono = TextStyle(fontFamily: AppFonts.mono, fontSize: 14);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(l.formSmdpAddress),
        TextFormField(
          controller: draft.smdpAddress,
          style: mono,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(hintText: l.formSmdpHint),
        ),
        const SizedBox(height: 12),
        FieldLabel(l.scanResultMatchingId),
        TextFormField(
          controller: draft.matchingId,
          style: mono,
          decoration: const InputDecoration(hintText: 'Matching ID'),
        ),
        const SizedBox(height: 12),
        FieldLabel(l.fieldConfirmationCode),
        TextFormField(
          controller: draft.confirmationCode,
          style: mono,
          decoration: InputDecoration(
            hintText: l.formConfirmationHint,
            helperText: draft.confirmationCodeRequired
                ? l.formConfirmationRequired
                : null,
            helperMaxLines: 3,
            helperStyle: draft.confirmationCodeRequired
                ? const TextStyle(color: AppColors.countdownWarning)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: Text(l.formScanQr),
            ),
            ListenableBuilder(
              listenable: Listenable.merge([
                draft.smdpAddress,
                draft.matchingId,
              ]),
              builder: (context, _) {
                final lpa = _lpaString();
                return TextButton.icon(
                  onPressed: lpa == null
                      ? null
                      : () {
                          unawaited(
                            Clipboard.setData(ClipboardData(text: lpa)),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.formCopiedActivationCode)),
                          );
                        },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(l.formCopyActivationCode),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 由当前填写的 SM-DP+ 与匹配 ID 组成的激活码（字段不完整时为 null）。
  String? _lpaString() {
    final smdp = draft.smdpAddress.text.trim();
    final matchingId = draft.matchingId.text.trim();
    if (smdp.isEmpty || matchingId.isEmpty) return null;
    final saved = draft.qrCodeRawData;
    final parsed = saved == null ? null : QrParserService.parse(saved).code;
    return LpaActivationCode(
      smdpAddress: smdp,
      matchingId: matchingId,
      smdpOid: parsed?.smdpOid,
      confirmationCodeRequired: draft.confirmationCodeRequired,
    ).toLpaString();
  }
}
