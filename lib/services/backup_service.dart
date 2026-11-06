import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database_helper.dart';
import 'backup_codec.dart';

/// 导入前的预览：已解析的备份内容 + 与本机重复的卡片数量。
class ImportPreview {
  const ImportPreview({required this.data, required this.duplicateCount});

  final BackupData data;
  final int duplicateCount;
}

/// 通过分享面板导出的结果。
enum ShareExportStatus { shared, dismissed, unknown }

/// 数据备份与恢复。
///
/// 备份只能由用户在应用内手动发起：
/// - 「保存到文件」通过系统文件选择器（SAF）写到用户指定位置，应用内不保留副本；
/// - 「分享」把临时文件放在缓存目录 `exports/` 下，下次导出或下次启动时清理。
abstract final class BackupService {
  static const String _exportDirName = 'exports';
  static const String _filePrefix = 'simer_backup';

  @visibleForTesting
  static String fileNameFor(DateTime time) =>
      '${_filePrefix}_${DateFormat('yyyyMMdd_HHmmss').format(time)}.json';

  static Future<String> _buildBackupJson() async {
    final snapshot = await DatabaseHelper.instance.exportSnapshot();
    return BackupCodec.encode(
      cards: snapshot.cards,
      tags: snapshot.tags,
      exportedAt: DateTime.now(),
    );
  }

  /// 通过系统「保存到」对话框保存备份。返回 `true` 表示已保存，`false` 表示用户取消。
  static Future<bool> saveToFile() async {
    final json = await _buildBackupJson();
    final uri = await FilePicker.saveFile(
      dialogTitle: '保存 SIMer 备份',
      fileName: fileNameFor(DateTime.now()),
      mimeType: 'application/json',
      bytes: Uint8List.fromList(utf8.encode(json)),
    );
    return uri != null;
  }

  /// 通过系统分享面板发送备份文件。
  static Future<ShareExportStatus> share() async {
    // 接收方应用可能在分享面板关闭后才读取文件，因此不能分享后立即删除，
    // 只清理较早的临时文件。
    await purgeExportCache(olderThan: const Duration(minutes: 10));
    final dir = await _exportDir();
    final file = File(p.join(dir.path, fileNameFor(DateTime.now())));
    await file.writeAsString(await _buildBackupJson(), flush: true);

    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'SIMer 数据备份',
      ),
    );
    return switch (result.status) {
      ShareResultStatus.success => ShareExportStatus.shared,
      ShareResultStatus.dismissed => ShareExportStatus.dismissed,
      ShareResultStatus.unavailable => ShareExportStatus.unknown,
    };
  }

  /// 删除缓存目录中的分享临时文件（含敏感信息的明文副本）。
  static Future<void> purgeExportCache({
    Duration olderThan = Duration.zero,
  }) async {
    try {
      final dir = await _exportDir();
      final cutoff = DateTime.now().subtract(olderThan);
      await for (final entity in dir.list()) {
        if (entity is File && (await entity.lastModified()).isBefore(cutoff)) {
          await entity.delete();
        }
      }
    } on FileSystemException catch (e) {
      debugPrint('清理导出缓存失败: $e');
    }
  }

  static Future<Directory> _exportDir() async {
    final cache = await getTemporaryDirectory();
    return Directory(p.join(cache.path, _exportDirName))
        .create(recursive: true);
  }

  /// 让用户选择备份文件并解析（不写入数据库）。用户取消时返回 `null`。
  ///
  /// 文件无法使用时抛出 [BackupFormatException]。
  static Future<ImportPreview?> pickAndPreview() async {
    // 部分文件管理器无法正确识别 .json 的 MIME 类型，因此不按扩展名过滤，改为校验内容。
    final picked = await FilePicker.pickFile();
    if (picked == null) return null;
    try {
      final length = await picked.length();
      if (length != null && length > BackupCodec.maxFileBytes) {
        throw const BackupFormatException('文件过大（超过 10 MB），不是有效的 SIMer 备份');
      }
      final bytes = await picked.readAsBytes();
      if (bytes.length > BackupCodec.maxFileBytes) {
        throw const BackupFormatException('文件过大（超过 10 MB），不是有效的 SIMer 备份');
      }
      final String text;
      try {
        text = utf8.decode(bytes);
      } on FormatException {
        throw const BackupFormatException('文件编码不是 UTF-8，不是有效的 SIMer 备份');
      }
      final data = BackupCodec.decode(text);
      final duplicates = await DatabaseHelper.instance.findExistingUuids(
        data.cards.map((c) => c.uuid),
      );
      return ImportPreview(data: data, duplicateCount: duplicates.length);
    } on FileSystemException {
      throw const BackupFormatException('无法读取所选文件');
    } finally {
      // 若 file_picker 把所选文件复制到了应用缓存，读取后立即删除该明文副本。
      await FilePicker.clearTemporaryFiles();
    }
  }

  /// 把预览中的数据写入数据库。
  static Future<ImportResult> importBackup(
    ImportPreview preview,
    ImportConflictPolicy policy,
  ) => DatabaseHelper.instance.importBackup(preview.data, policy: policy);
}
