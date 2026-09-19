import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/tag.dart';
import '../providers/sim_card_provider.dart';
import '../theme/app_colors.dart';

/// 标签管理页面
///
/// CRUD 操作：添加、编辑、删除、重排序
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
        title: const Text('标签管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: '添加标签',
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
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有标签',
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
            '点击右上角添加你的第一个标签',
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

  Widget _buildTagTile(BuildContext context, Tag tag, int index) {
    final tagColor = Color(tag.color);
    final provider = context.read<SimCardProvider>();

    // 统计使用该标签的卡数量
    final usageCount = provider.simCards
        .where((c) => c.tagIds.contains(tag.id))
        .length;

    return Container(
      key: ValueKey(tag.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              Theme.of(context).dividerTheme.color ?? AppColors.lightDivider,
          width: 0.5,
        ),
      ),
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
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: usageCount > 0
            ? Text(
                '已关联 $usageCount 张SIM卡',
                style: GoogleFonts.inter(fontSize: 12),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20),
              onPressed: () => _showAddEditDialog(context, tag: tag),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.countdownDanger,
              ),
              onPressed: () => _confirmDelete(context, tag, usageCount),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddEditDialog(BuildContext context, {Tag? tag}) async {
    final isEditing = tag != null;
    _nameController.text = tag?.name ?? '';
    final provider = context.read<SimCardProvider>();
    Color selectedColor = tag != null
        ? Color(tag.color)
        : AppColors.cardColorPool[
            provider.tags.length % AppColors.cardColorPool.length];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? '编辑标签' : '添加标签'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: '标签名称',
                      prefixIcon: Icon(Icons.label_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 颜色选择
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '标签颜色',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(ctx)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        AppColors.cardColorPool.take(10).map((color) {
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
                                ? Border.all(
                                    color: Colors.white, width: 2)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          color.withValues(alpha: 0.5),
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
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) return;
                    Navigator.of(ctx).pop({
                      'name': name,
                      'color': selectedColor.toARGB32(),
                    });
                  },
                  child: Text(isEditing ? '保存' : '添加'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      if (isEditing) {
        final updated = tag.copyWith(
          name: result['name'] as String,
          color: result['color'] as int,
        );
        await provider.updateTag(updated);
      } else {
        final newTag = Tag(
          name: result['name'] as String,
          color: result['color'] as int,
        );
        await provider.addTag(newTag);
      }
    }
  }

  void _confirmDelete(BuildContext context, Tag tag, int usageCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除标签'),
        content: Text(
          usageCount > 0
              ? '标签"${tag.name}"已被 $usageCount 张SIM卡使用。删除后将从这些卡中移除该标签。确定要删除吗？'
              : '确定要删除标签"${tag.name}"吗？',
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
              ctx.read<SimCardProvider>().deleteTag(tag.id!);
              Navigator.of(ctx).pop();
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
