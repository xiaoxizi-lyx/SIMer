import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    const mono = TextStyle(fontFamily: AppFonts.mono, fontSize: 14);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('SM-DP+ 服务器地址'),
        TextFormField(
          controller: draft.smdpAddress,
          style: mono,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: '例如 rsp.example.com'),
        ),
        const SizedBox(height: 12),
        const FieldLabel('激活码（匹配 ID）'),
        TextFormField(
          controller: draft.matchingId,
          style: mono,
          decoration: const InputDecoration(hintText: 'Matching ID'),
        ),
        const SizedBox(height: 12),
        const FieldLabel('确认码'),
        TextFormField(
          controller: draft.confirmationCode,
          style: mono,
          decoration: InputDecoration(
            hintText: '如运营商提供',
            helperText: draft.confirmationCodeRequired
                ? '此 eSIM 的激活码标明安装时需要确认码（不在二维码中，由运营商另行提供）'
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
              label: const Text('扫描/识别二维码'),
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
                          Clipboard.setData(ClipboardData(text: lpa));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已复制完整激活码')),
                          );
                        },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('复制完整激活码'),
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
