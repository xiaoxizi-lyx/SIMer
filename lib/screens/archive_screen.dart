import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/sim_card.dart';
import '../providers/auth_provider.dart';
import '../providers/sim_card_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/sim_card_front.dart';

/// 归档SIM卡页面
///
/// 显示已归档的卡片，可恢复或永久删除
class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimCardProvider>();
    final archivedCards = provider.archivedCards;
    final maskSensitive = context.select<AuthProvider, bool>(
      (a) => a.maskSensitiveInfo,
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.archiveTitle)),
      body: archivedCards.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              itemCount: archivedCards.length,
              itemBuilder: (context, index) {
                final card = archivedCards[index];
                return _buildArchivedCard(
                  context,
                  card,
                  provider,
                  maskSensitive: maskSensitive,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.archive_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.archiveEmptyTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.archiveEmptySubtitle,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedCard(
    BuildContext context,
    SimCard card,
    SimCardProvider provider, {
    required bool maskSensitive,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // 卡片正面（略灰化）
          Opacity(
            opacity: 0.75,
            child: SimCardFront(
              simCard: card,
              tags: provider.tags,
              maskSensitive: maskSensitive,
            ),
          ),
          const SizedBox(height: 8),
          // 操作按钮行
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 恢复
              _actionChip(
                context,
                icon: Icons.unarchive_rounded,
                label: context.l10n.archiveRestore,
                color: AppColors.primary,
                onTap: () async {
                  final l = context.l10n;
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await provider.restoreSimCard(card.id!);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l.archiveRestored(card.carrierLabel(l))),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } on Exception catch (e) {
                    debugPrint('恢复失败: $e');
                    messenger.showSnackBar(
                      SnackBar(content: Text(l.archiveRestoreFailed)),
                    );
                  }
                },
              ),
              const SizedBox(width: 12),
              // 永久删除
              _actionChip(
                context,
                icon: Icons.delete_forever_rounded,
                label: context.l10n.archiveDeleteForever,
                color: AppColors.countdownDanger,
                onTap: () => _confirmPermanentDelete(context, card, provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPermanentDelete(
    BuildContext context,
    SimCard card,
    SimCardProvider provider,
  ) {
    final l = context.l10n;
    final carrier = card.carrierLabel(l);
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.archiveDeleteForever),
          content: Text(l.archiveDeleteMessage(carrier)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.commonCancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.countdownDanger,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await provider.permanentlyDelete(card.id!);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(l.archiveDeleted(carrier)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } on Exception catch (e) {
                  debugPrint('删除失败: $e');
                  messenger.showSnackBar(
                    SnackBar(content: Text(l.archiveDeleteFailed)),
                  );
                }
              },
              child: Text(l.commonDelete),
            ),
          ],
        ),
      ),
    );
  }
}
