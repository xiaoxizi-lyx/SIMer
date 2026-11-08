import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/calendar_date.dart';
import '../models/sim_card.dart';
import '../providers/sim_card_provider.dart';
import 'add_edit_sim_screen.dart';

/// 卡片上的常用操作，供首页列表与卡片详情共用。可撤销的操作会在 SnackBar 中提供「撤销」。
abstract final class CardActions {
  static Future<void> edit(BuildContext context, SimCard card) =>
      Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => AddEditSimScreen(simCard: card)),
      );

  /// 「我已使用」：把上次使用日记为今天，滚动有效期随之顺延。
  static Future<void> markAsUsed(BuildContext context, SimCard card) async {
    final l = context.l10n;
    final provider = context.read<SimCardProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final id = card.id!;
    final previous = card.lastUsedDate;
    try {
      await provider.markAsUsed(id);
    } on Exception catch (e) {
      debugPrint('记录使用失败: $e');
      messenger.showSnackBar(SnackBar(content: Text(l.actionFailed)));
      return;
    }
    final expiration = card.effectiveExpirationDate;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            expiration == null
                ? l.markUsedDone
                : l.markUsedDoneExtended(CalendarDate.format(expiration)),
          ),
          action: SnackBarAction(
            label: l.commonUndo,
            onPressed: () => unawaited(provider.setLastUsedDate(id, previous)),
          ),
        ),
      );
  }

  /// 归档（先确认，完成后可撤销）。
  static Future<void> archive(BuildContext context, SimCard card) async {
    final l = context.l10n;
    final carrier = card.carrierLabel(l);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.archiveDialogTitle),
        content: Text(l.archiveDialogMessage(carrier)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.cardArchive),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<SimCardProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final id = card.id!;
    try {
      await provider.archiveSimCard(id);
    } on Exception catch (e) {
      debugPrint('归档失败: $e');
      messenger.showSnackBar(SnackBar(content: Text(l.archiveFailed)));
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l.archiveDone(carrier)),
          action: SnackBarAction(
            label: l.commonUndo,
            onPressed: () => unawaited(provider.restoreSimCard(id)),
          ),
        ),
      );
  }
}
