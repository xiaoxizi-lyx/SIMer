import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/sim_card_provider.dart';
import '../services/backup_codec.dart';
import '../services/backup_crypto.dart';
import '../services/backup_service.dart';

enum _ExportTarget { file, share }

/// 导出对话框的结果：保存方式与（可选的）加密密码。
class _ExportRequest {
  const _ExportRequest(this.target, this.password);

  final _ExportTarget target;
  final String? password;
}

/// 导出备份：选择是否加密（默认加密）与保存方式，生成文件后保存或分享。
Future<void> runExportFlow(BuildContext context) async {
  final request = await showDialog<_ExportRequest>(
    context: context,
    builder: (_) => const _ExportDialog(),
  );
  if (request == null || !context.mounted) return;

  final l = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final auth = context.read<AuthProvider>();
  try {
    final password = request.password;
    final export = password == null
        ? await BackupService.prepareExport()
        : await _withProgress(
            context,
            l.exportEncrypting,
            () => BackupService.prepareExport(password: password),
          );
    final String message;
    switch (request.target) {
      case _ExportTarget.file:
        final saved = await auth.withoutAutoLock(
          () => BackupService.saveToFile(
            export,
            dialogTitle: l.exportSaveDialogTitle,
          ),
        );
        message = saved ? l.exportSaved : l.exportSaveCancelled;
      case _ExportTarget.share:
        final status = await auth.withoutAutoLock(
          () => BackupService.share(export, subject: l.exportShareSubject),
        );
        message = switch (status) {
          ShareExportStatus.shared => l.exportShared,
          ShareExportStatus.dismissed => l.exportShareCancelled,
          ShareExportStatus.unknown => l.exportShareOpened,
        };
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  } on Exception catch (e) {
    debugPrint('导出失败: $e');
    messenger.showSnackBar(SnackBar(content: Text(l.exportFailed)));
  }
}

/// 导入备份：选择文件 →（加密备份）输入密码并解密 → 预览 → 用户确认冲突策略 → 在事务中写入。
Future<void> runImportFlow(BuildContext context) async {
  final l = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final provider = context.read<SimCardProvider>();
  final auth = context.read<AuthProvider>();

  final PickedBackup? picked;
  try {
    picked = await auth.withoutAutoLock(BackupService.pickFile);
  } on BackupFormatException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.error.message(l))));
    return;
  } on Exception catch (e) {
    debugPrint('读取备份失败: $e');
    messenger.showSnackBar(SnackBar(content: Text(l.backupErrorUnreadable)));
    return;
  }
  if (picked == null || !context.mounted) return;

  final ImportPreview preview;
  try {
    final decoded = picked.isEncrypted
        ? await _decrypt(context, picked)
        : await BackupService.preview(picked);
    if (decoded == null) return;
    preview = decoded;
  } on BackupFormatException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.error.message(l))));
    return;
  }
  if (!context.mounted) return;

  final policy = await showDialog<ImportConflictPolicy>(
    context: context,
    builder: (_) => _ImportPreviewDialog(preview: preview),
  );
  if (policy == null || !context.mounted) return;

  final ImportResult result;
  try {
    result = await BackupService.importBackup(preview, policy);
  } on Exception catch (e) {
    debugPrint('导入失败: $e');
    messenger.showSnackBar(SnackBar(content: Text(l.importFailed)));
    return;
  }
  await provider.loadAll();
  if (!context.mounted) return;

  if (result.failedRecords.isEmpty) {
    messenger.showSnackBar(SnackBar(content: Text(result.summary(l))));
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.importDoneTitle),
      content: SingleChildScrollView(
        child: Text(
          '${result.summary(l)}\n\n${l.importSkippedRecords}\n'
          '${result.failedRecords.map((e) => '• ${e.message(l)}').join('\n')}',
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l.commonGotIt),
        ),
      ],
    ),
  );
}

/// 反复询问密码直到解密成功；用户取消时返回 null。
Future<ImportPreview?> _decrypt(
  BuildContext context,
  PickedBackup picked,
) async {
  final l = context.l10n;
  String? error;
  while (context.mounted) {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _PasswordDialog(errorText: error),
    );
    if (password == null || !context.mounted) return null;
    try {
      return await _withProgress(
        context,
        l.importDecrypting,
        () => BackupService.preview(picked, password: password),
      );
    } on BackupFormatException catch (e) {
      if (e.error != BackupError.wrongPassword) rethrow;
      error = e.error.message(l);
    }
  }
  return null;
}

/// 执行耗时操作（加解密）期间显示不可关闭的进度对话框。
Future<T> _withProgress<T>(
  BuildContext context,
  String message,
  Future<T> Function() task,
) async {
  final navigator = Navigator.of(context);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await task();
  } finally {
    navigator.pop();
  }
}

/// 导出前的说明、加密选项与密码输入。
class _ExportDialog extends StatefulWidget {
  const _ExportDialog();

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _encrypt = true;
  bool _obscure = true;

  /// 用户尝试导出后才显示密码校验错误。
  bool _showErrors = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _passwordError(AppLocalizations l) =>
      _password.text.length < BackupCrypto.minPasswordLength
      ? l.exportPasswordTooShort(BackupCrypto.minPasswordLength)
      : null;

  String? _confirmError(AppLocalizations l) =>
      _confirm.text != _password.text ? l.exportPasswordMismatch : null;

  void _submit(_ExportTarget target) {
    final l = context.l10n;
    if (_encrypt && (_passwordError(l) != null || _confirmError(l) != null)) {
      setState(() => _showErrors = true);
      return;
    }
    Navigator.of(context)
        .pop(_ExportRequest(target, _encrypt ? _password.text : null));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return AlertDialog(
      title: Text(l.settingsExport),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.exportIntro),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l.exportEncrypt),
              value: _encrypt,
              onChanged: (value) => setState(() => _encrypt = value),
            ),
            if (_encrypt) ...[
              TextField(
                controller: _password,
                obscureText: _obscure,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: l.exportPassword,
                  errorText: _showErrors ? _passwordError(l) : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirm,
                obscureText: _obscure,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: l.exportPasswordConfirm,
                  errorText: _showErrors ? _confirmError(l) : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text(l.exportPasswordWarning, style: hintStyle),
            ] else
              Text(
                l.exportPlainWarning,
                style: hintStyle?.copyWith(color: theme.colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        TextButton(
          onPressed: () => _submit(_ExportTarget.share),
          child: Text(l.exportShare),
        ),
        ElevatedButton(
          onPressed: () => _submit(_ExportTarget.file),
          child: Text(l.exportSaveToFile),
        ),
      ],
    );
  }
}

/// 输入加密备份的密码。
class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({this.errorText});

  /// 上一次尝试失败的原因（例如密码错误）。
  final String? errorText;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_password.text.isEmpty) return;
    Navigator.of(context).pop(_password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.importPasswordTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.importPasswordMessage),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            autofocus: true,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l.exportPassword,
              errorText: widget.errorText,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        ElevatedButton(onPressed: _submit, child: Text(l.importDecrypt)),
      ],
    );
  }
}

class _ImportPreviewDialog extends StatelessWidget {
  const _ImportPreviewDialog({required this.preview});

  static const _maxListedErrors = 5;

  final ImportPreview preview;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final data = preview.data;
    final duplicates = preview.duplicateCount;
    final exportedAt = data.exportedAt;
    final errors = data.errors;
    final nothingToImport = data.cards.isEmpty && data.tags.isEmpty;
    final errorStyle = TextStyle(color: Theme.of(context).colorScheme.error);

    return AlertDialog(
      title: Text(l.settingsImport),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            if (preview.wasEncrypted) Text(l.importWasEncrypted),
            if (exportedAt != null)
              Text(
                l.importExportedAt(
                  DateFormat.yMd(l.localeName)
                      .add_Hm()
                      .format(exportedAt.toLocal()),
                ),
              ),
            Text(l.importCards(data.cards.length)),
            if (duplicates > 0) Text(l.importDuplicates(duplicates)),
            Text(l.importTags(data.tags.length)),
            if (data.formatVersion == BackupCodec.legacyFormatVersion)
              Text(l.importLegacy),
            if (errors.isNotEmpty) ...[
              Text(l.importUnreadableRecords(errors.length), style: errorStyle),
              for (final error in errors.take(_maxListedErrors))
                Text('• ${error.message(l)}', style: errorStyle),
              if (errors.length > _maxListedErrors)
                Text(l.importMoreErrors(errors.length), style: errorStyle),
            ],
            if (nothingToImport) Text(l.importNothing),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        if (duplicates > 0) ...[
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(ImportConflictPolicy.overwrite),
            child: Text(l.importOverwrite),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(ImportConflictPolicy.skip),
            child: Text(l.importSkip),
          ),
        ] else
          ElevatedButton(
            onPressed: nothingToImport
                ? null
                : () => Navigator.of(context).pop(ImportConflictPolicy.skip),
            child: Text(l.importButton),
          ),
      ],
    );
  }
}
