import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/sim_card_provider.dart';
import '../screens/card_actions.dart';
import 'sim_card_back.dart';

/// 卡片详情底部弹窗（例如点击到期提醒通知后打开）。
class CardDetailSheet extends StatelessWidget {
  const CardDetailSheet({super.key, required this.cardUuid});

  final String cardUuid;

  /// 在 [context]（通常是首页）上打开卡片详情。
  static Future<void> show(BuildContext context, String cardUuid) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => CardDetailSheet(cardUuid: cardUuid),
      );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimCardProvider>();
    final card = provider.getSimCardByUuid(cardUuid);
    final maskSensitive = context.select<AuthProvider, bool>(
      (a) => a.maskSensitiveInfo,
    );
    if (card == null) {
      return SizedBox(
        height: 160,
        child: Center(child: Text(context.l10n.cardDetailDeleted)),
      );
    }

    // 操作前先关闭弹窗，再在首页上执行（SnackBar 与对话框显示在首页）
    final hostContext = Navigator.of(context).context;
    void closeThen(Future<void> Function(BuildContext) action) {
      Navigator.of(context).pop();
      unawaited(action(hostContext));
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SimCardBack(
          simCard: card,
          tags: provider.tags,
          maskSensitive: maskSensitive,
          onEdit: () => closeThen((ctx) => CardActions.edit(ctx, card)),
          onMarkAsUsed: () =>
              closeThen((ctx) => CardActions.markAsUsed(ctx, card)),
          onArchive: card.isArchived
              ? null
              : () => closeThen((ctx) => CardActions.archive(ctx, card)),
        ),
      ),
    );
  }
}
