import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../providers/auth_provider.dart';
import '../providers/sim_card_provider.dart';
import '../services/backup_codec.dart';
import '../services/backup_service.dart';

enum _ExportTarget { file, share }

/// 导出备份：先提示备份中含敏感信息，再由用户选择保存位置或分享对象。
Future<void> runExportFlow(BuildContext context) async {
  final target = await showDialog<_ExportTarget>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('导出备份'),
      content: const Text(
        '备份为明文 JSON 文件，包含全部 SIM 卡与标签数据，其中有 ICCID、电话号码、'
        'eSIM 激活码与确认码等敏感信息。\n\n'
        '请只保存到你信任的位置，或直接发送到你自己的新设备，导入完成后及时删除备份文件。',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(_ExportTarget.share),
          child: const Text('分享'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(_ExportTarget.file),
          child: const Text('保存到文件'),
        ),
      ],
    ),
  );
  if (target == null || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final auth = context.read<AuthProvider>();
  try {
    final String message;
    switch (target) {
      case _ExportTarget.file:
        final saved = await auth.withoutAutoLock(BackupService.saveToFile);
        message = saved ? '备份已保存' : '已取消保存';
      case _ExportTarget.share:
        message = switch (await auth.withoutAutoLock(BackupService.share)) {
          ShareExportStatus.shared => '备份已分享',
          ShareExportStatus.dismissed => '已取消分享',
          ShareExportStatus.unknown => '已打开分享面板',
        };
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  } on Exception catch (e) {
    debugPrint('导出失败: $e');
    messenger.showSnackBar(const SnackBar(content: Text('导出失败，请重试')));
  }
}

/// 导入备份：选择文件 → 解析并预览 → 用户确认冲突策略 → 在事务中写入。
Future<void> runImportFlow(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final provider = context.read<SimCardProvider>();
  final auth = context.read<AuthProvider>();

  final ImportPreview? preview;
  try {
    preview = await auth.withoutAutoLock(BackupService.pickAndPreview);
  } on BackupFormatException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return;
  } on Exception catch (e) {
    debugPrint('读取备份失败: $e');
    messenger.showSnackBar(const SnackBar(content: Text('无法读取所选文件')));
    return;
  }
  if (preview == null || !context.mounted) return;

  final policy = await showDialog<ImportConflictPolicy>(
    context: context,
    builder: (_) => _ImportPreviewDialog(preview: preview!),
  );
  if (policy == null || !context.mounted) return;

  final ImportResult result;
  try {
    result = await BackupService.importBackup(preview, policy);
  } on Exception catch (e) {
    debugPrint('导入失败: $e');
    messenger.showSnackBar(const SnackBar(content: Text('导入失败，现有数据未做任何修改')));
    return;
  }
  await provider.loadAll();
  if (!context.mounted) return;

  if (result.failedRecords.isEmpty) {
    messenger.showSnackBar(SnackBar(content: Text(result.summary)));
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('导入完成'),
      content: SingleChildScrollView(
        child: Text(
          '${result.summary}\n\n以下记录无法解析，已跳过：\n'
          '${result.failedRecords.map((e) => '• $e').join('\n')}',
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('知道了'),
        ),
      ],
    ),
  );
}

class _ImportPreviewDialog extends StatelessWidget {
  const _ImportPreviewDialog({required this.preview});

  static const _maxListedErrors = 5;

  final ImportPreview preview;

  @override
  Widget build(BuildContext context) {
    final data = preview.data;
    final duplicates = preview.duplicateCount;
    final exportedAt = data.exportedAt;
    final errors = data.errors;
    final nothingToImport = data.cards.isEmpty && data.tags.isEmpty;
    final errorStyle = TextStyle(color: Theme.of(context).colorScheme.error);

    return AlertDialog(
      title: const Text('导入备份'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            if (exportedAt != null)
              Text(
                '导出时间：${DateFormat('yyyy-MM-dd HH:mm').format(exportedAt.toLocal())}',
              ),
            Text('卡片：${data.cards.length} 张'),
            if (duplicates > 0) Text('其中 $duplicates 张与本机已有卡片相同（UUID 一致）'),
            Text('标签：${data.tags.length} 个（同名标签会自动合并）'),
            if (data.formatVersion == BackupCodec.legacyFormatVersion)
              const Text('此备份来自 SIMer 1.0，导入时会自动转换格式。'),
            if (errors.isNotEmpty) ...[
              Text('${errors.length} 条记录无法解析，将被跳过：', style: errorStyle),
              for (final error in errors.take(_maxListedErrors))
                Text('• $error', style: errorStyle),
              if (errors.length > _maxListedErrors)
                Text('…等共 ${errors.length} 条', style: errorStyle),
            ],
            if (nothingToImport) const Text('备份中没有可导入的数据。'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        if (duplicates > 0) ...[
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(ImportConflictPolicy.overwrite),
            child: const Text('覆盖重复'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(ImportConflictPolicy.skip),
            child: const Text('跳过重复'),
          ),
        ] else
          ElevatedButton(
            onPressed: nothingToImport
                ? null
                : () => Navigator.of(context).pop(ImportConflictPolicy.skip),
            child: const Text('导入'),
          ),
      ],
    );
  }
}
