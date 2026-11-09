import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../models/sim_card.dart';
import '../services/qr_parser_service.dart';
import '../theme/app_colors.dart';
import 'qr_code_view.dart';

/// 用卡片保存的激活码重新生成 eSIM 二维码，便于在另一台设备上扫码安装。
class EsimQrSheet extends StatefulWidget {
  const EsimQrSheet({super.key, required this.card, required this.code});

  final SimCard card;
  final LpaActivationCode code;

  /// 卡片没有完整、有效的激活码时不显示任何内容。
  static Future<void> show(BuildContext context, SimCard card) async {
    final code = QrParserService.forCard(card);
    if (code == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => EsimQrSheet(card: card, code: code),
    );
  }

  @override
  State<EsimQrSheet> createState() => _EsimQrSheetState();
}

class _EsimQrSheetState extends State<EsimQrSheet> {
  /// 已复制：弹窗会挡住页面底部的提示条，因此直接在按钮上反馈。
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final code = widget.code;
    final lpa = code.toLpaString();
    final qrSize = (MediaQuery.sizeOf(context).shortestSide - 96).clamp(
      200.0,
      320.0,
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.esimQrTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              widget.card.carrierLabel(l),
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: QrCodeView(
                data: lpa,
                size: qrSize,
                semanticLabel: l.esimQrSemantics,
              ),
            ),
            const SizedBox(height: 16),
            Text(l.esimQrHint, style: const TextStyle(fontSize: 13)),
            if (code.confirmationCodeRequired) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.countdownWarning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l.esimQrNeedsConfirmation,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  unawaited(Clipboard.setData(ClipboardData(text: lpa)));
                  setState(() => _copied = true);
                },
                icon: Icon(
                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                  size: 18,
                ),
                label: Text(
                  _copied
                      ? l.formCopiedActivationCode
                      : l.formCopyActivationCode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
