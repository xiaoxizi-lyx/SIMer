import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final provider = context.read<SimCardProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final id = card.id!;
    final previous = card.lastUsedDate;
    try {
      await provider.markAsUsed(id);
    } on Exception catch (e) {
      debugPrint('记录使用失败: $e');
      messenger.showSnackBar(const SnackBar(content: Text('操作失败，请重试')));
      return;
    }
    final expiration = card.effectiveExpirationDate;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            expiration == null
                ? '已记录今天使用'
                : '已记录今天使用，有效期顺延至 ${CalendarDate.format(expiration)}',
          ),
          action: SnackBarAction(
            label: '撤销',
            onPressed: () => unawaited(provider.setLastUsedDate(id, previous)),
          ),
        ),
      );
  }

  /// 归档（先确认，完成后可撤销）。
  static Future<void> archive(BuildContext context, SimCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('归档SIM卡'),
        content: Text('确定要将 ${card.carrierName} 的SIM卡归档吗？归档后可在「设置 → 归档」中恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('归档'),
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
      messenger.showSnackBar(const SnackBar(content: Text('归档失败，请重试')));
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('已归档 ${card.carrierName}'),
          action: SnackBarAction(
            label: '撤销',
            onPressed: () => unawaited(provider.restoreSimCard(id)),
          ),
        ),
      );
  }
}
