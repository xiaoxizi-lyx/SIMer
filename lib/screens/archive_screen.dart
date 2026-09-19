import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/sim_card.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('归档'),
      ),
      body: archivedCards.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              itemCount: archivedCards.length,
              itemBuilder: (context, index) {
                final card = archivedCards[index];
                return _buildArchivedCard(context, card, provider);
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
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            '没有已归档的SIM卡',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '已归档的SIM卡会显示在这里',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
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
    SimCardProvider provider,
  ) {
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
                label: '恢复',
                color: AppColors.primary,
                onTap: () {
                  provider.restoreSimCard(card.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已恢复 ${card.carrierName}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              // 永久删除
              _actionChip(
                context,
                icon: Icons.delete_forever_rounded,
                label: '永久删除',
                color: AppColors.countdownDanger,
                onTap: () =>
                    _confirmPermanentDelete(context, card, provider),
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
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('永久删除'),
        content: Text(
          '确定要永久删除 ${card.carrierName} 的SIM卡吗？\n\n此操作不可恢复。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.countdownDanger,
            ),
            onPressed: () {
              provider.permanentlyDelete(card.id!);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已永久删除 ${card.carrierName}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
