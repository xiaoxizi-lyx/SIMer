import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/tag.dart';
import '../providers/filter_provider.dart';
import '../providers/sim_card_provider.dart';
import '../theme/app_colors.dart';

/// 标签管理页面
///
/// 添加、编辑、删除标签
class TagManageScreen extends StatefulWidget {
  const TagManageScreen({super.key});

  @override
  State<TagManageScreen> createState() => _TagManageScreenState();
}

class _TagManageScreenState extends State<TagManageScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimCardProvider>();
    final tags = provider.tags;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tagsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: context.l10n.tagsAdd,
            onPressed: () => _showAddEditDialog(context),
          ),
        ],
      ),
      body: tags.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return _buildTagTile(context, tag, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.label_off_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.tagsEmptyTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tagsEmptySubtitle,
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

  Widget _buildTagTile(BuildContext context, Tag tag, int index) {
    final tagColor = Color(tag.color);
    final provider = context.read<SimCardProvider>();

    // 统计使用该标签的卡数量（含已归档的卡片，删除时它们同样会失去该标签）
    final usageCount = [
      ...provider.simCards,
      ...provider.archivedCards,
    ].where((c) => c.tagIds.contains(tag.id)).length;

    // 背景放在 Material 上，编辑/删除按钮的点击水波纹才不会被挡住
    return Padding(
      key: ValueKey(tag.id),
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color:
                Theme.of(context).dividerTheme.color ?? AppColors.lightDivider,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: tagColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          title: Text(
            tag.name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          subtitle: usageCount > 0
              ? Text(
                  context.l10n.tagsUsage(usageCount),
                  style: const TextStyle(fontSize: 12),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                tooltip: context.l10n.commonEdit,
                onPressed: () => _showAddEditDialog(context, tag: tag),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.countdownDanger,
                ),
                tooltip: context.l10n.commonDelete,
                onPressed: () => _confirmDelete(context, tag, usageCount),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddEditDialog(BuildContext context, {Tag? tag}) async {
    final l = context.l10n;
    final isEditing = tag != null;
    _nameController.text = tag?.name ?? '';
    final provider = context.read<SimCardProvider>();
    Color selectedColor = tag != null
        ? Color(tag.color)
        : AppColors.cardColorPool[provider.tags.length %
              AppColors.cardColorPool.length];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? l.tagsEdit : l.tagsAdd),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l.tagsNameHint,
                      prefixIcon: const Icon(Icons.label_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 颜色选择
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l.tagsColor,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(ctx).colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppColors.cardColorPool.take(10).map((color) {
                      final isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() => selectedColor = color);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: AppColors.textOnColor(color),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l.commonCancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) return;
                    if (provider.isTagNameTaken(name, exceptId: tag?.id)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.tagsNameTaken(name))),
                      );
                      return;
                    }
                    Navigator.of(ctx)
                        .pop({'name': name, 'color': selectedColor.toARGB32()});
                  },
                  child: Text(isEditing ? l.commonSave : l.commonAdd),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (isEditing) {
        await provider.updateTag(
          tag.copyWith(
            name: result['name'] as String,
            color: result['color'] as int,
          ),
        );
      } else {
        await provider.addTag(
          Tag(name: result['name'] as String, color: result['color'] as int),
        );
      }
    } on Exception catch (e) {
      debugPrint('保存标签失败: $e');
      messenger.showSnackBar(SnackBar(content: Text(l.tagsSaveFailed)));
    }
  }

  void _confirmDelete(BuildContext context, Tag tag, int usageCount) {
    final l = context.l10n;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.tagsDeleteTitle),
          content: Text(
            usageCount > 0
                ? l.tagsDeleteInUse(tag.name, usageCount)
                : l.tagsDeleteConfirm(tag.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.commonCancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.countdownDanger,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                final id = tag.id!;
                // 同时移除首页中该标签的筛选，避免残留的筛选让列表“莫名”变空
                ctx.read<FilterProvider>().removeTagFilter(id);
                unawaited(ctx.read<SimCardProvider>().deleteTag(id));
              },
              child: Text(l.commonDelete),
            ),
          ],
        ),
      ),
    );
  }
}
