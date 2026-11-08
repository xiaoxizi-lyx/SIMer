import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database_helper.dart';
import 'backup_codec.dart';
import 'backup_crypto.dart';

/// 导入前的预览：已解析的备份内容 + 与本机重复的卡片数量。
class ImportPreview {
  const ImportPreview({
    required this.data,
    required this.duplicateCount,
    this.wasEncrypted = false,
  });

  final BackupData data;
  final int duplicateCount;

  /// 是否为（已用密码解密的）加密备份。
  final bool wasEncrypted;
}

/// 已生成、等待保存或分享的备份文件。
class PreparedExport {
  const PreparedExport({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

/// 用户选择的备份文件（已读取并解析为 JSON，尚未解密与解码）。
class PickedBackup {
  const PickedBackup(this.root);

  final Map<String, dynamic> root;

  bool get isEncrypted => BackupCrypto.isEncrypted(root);
}

/// 通过分享面板导出的结果。
enum ShareExportStatus { shared, dismissed, unknown }

/// 数据备份与恢复。
///
/// 备份只能由用户在应用内手动发起：
/// - 「保存到文件」通过系统文件选择器（SAF）写到用户指定位置，应用内不保留副本；
/// - 「分享」把临时文件放在缓存目录 `exports/` 下，下次导出或下次启动时清理。
///
/// 备份可以用密码加密（见 [BackupCrypto]）；加解密在后台 isolate 中进行。
abstract final class BackupService {
  static const String _exportDirName = 'exports';
  static const String _filePrefix = 'simer_backup';

  @visibleForTesting
  static String fileNameFor(DateTime time, {bool encrypted = false}) =>
      '${_filePrefix}_${DateFormat('yyyyMMdd_HHmmss').format(time)}'
      '${encrypted ? '_encrypted' : ''}.json';

  /// 生成备份文件内容；[password] 不为空时加密。
  static Future<PreparedExport> prepareExport({String? password}) async {
    final snapshot = await DatabaseHelper.instance.exportSnapshot();
    final now = DateTime.now();
    final json = BackupCodec.encode(
      cards: snapshot.cards,
      tags: snapshot.tags,
      exportedAt: now,
    );
    final content = password == null
        ? json
        : await Isolate.run(() => BackupCrypto.encrypt(json, password));
    return PreparedExport(
      bytes: Uint8List.fromList(utf8.encode(content)),
      fileName: fileNameFor(now, encrypted: password != null),
    );
  }

  /// 通过系统「保存到」对话框保存备份。返回 `true` 表示已保存，`false` 表示用户取消。
  static Future<bool> saveToFile(
    PreparedExport export, {
    required String dialogTitle,
  }) async {
    final uri = await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: export.fileName,
      mimeType: 'application/json',
      bytes: export.bytes,
    );
    return uri != null;
  }

  /// 通过系统分享面板发送备份文件。
  static Future<ShareExportStatus> share(
    PreparedExport export, {
    required String subject,
  }) async {
    // 接收方应用可能在分享面板关闭后才读取文件，因此不能分享后立即删除，
    // 只清理较早的临时文件。
    await purgeExportCache(olderThan: const Duration(minutes: 10));
    final dir = await _exportDir();
    final file = File(p.join(dir.path, export.fileName));
    await file.writeAsBytes(export.bytes, flush: true);

    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: subject,
      ),
    );
    return switch (result.status) {
      ShareResultStatus.success => ShareExportStatus.shared,
      ShareResultStatus.dismissed => ShareExportStatus.dismissed,
      ShareResultStatus.unavailable => ShareExportStatus.unknown,
    };
  }

  /// 删除缓存目录中的分享临时文件（可能是明文副本）。
  static Future<void> purgeExportCache({
    Duration olderThan = Duration.zero,
  }) async {
    try {
      final dir = await _exportDir();
      final cutoff = DateTime.now().subtract(olderThan);
      await for (final entity in dir.list()) {
        if (entity is File && entity.lastModifiedSync().isBefore(cutoff)) {
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

  /// 让用户选择备份文件并读取为 JSON。用户取消时返回 `null`。
  ///
  /// 文件无法使用时抛出 [BackupFormatException]。
  static Future<PickedBackup?> pickFile() async {
    // 部分文件管理器无法正确识别 .json 的 MIME 类型，因此不按扩展名过滤，改为校验内容。
    final picked = await FilePicker.pickFile();
    if (picked == null) return null;
    try {
      final length = await picked.length();
      if (length != null && length > BackupCodec.maxFileBytes) {
        throw const BackupFormatException(BackupError.fileTooLarge);
      }
      final bytes = await picked.readAsBytes();
      if (bytes.length > BackupCodec.maxFileBytes) {
        throw const BackupFormatException(BackupError.fileTooLarge);
      }
      final String text;
      try {
        text = utf8.decode(bytes);
      } on FormatException {
        throw const BackupFormatException(BackupError.notUtf8);
      }
      return PickedBackup(BackupCodec.parseRoot(text));
    } on FileSystemException {
      throw const BackupFormatException(BackupError.unreadable);
    } finally {
      // 若 file_picker 把所选文件复制到了应用缓存，读取后立即删除该副本。
      await FilePicker.clearTemporaryFiles();
    }
  }

  /// 解码（加密备份先用 [password] 解密）并统计与本机重复的卡片，不写入数据库。
  ///
  /// 文件无法使用或密码错误时抛出 [BackupFormatException]。
  static Future<ImportPreview> preview(
    PickedBackup backup, {
    String? password,
  }) async {
    var root = backup.root;
    if (backup.isEncrypted) {
      if (password == null) {
        throw ArgumentError.notNull('password');
      }
      final encrypted = backup.root;
      final json = await Isolate.run(
        () => BackupCrypto.decrypt(encrypted, password),
      );
      root = BackupCodec.parseRoot(json);
    }
    final data = BackupCodec.decodeRoot(root);
    final duplicates = await DatabaseHelper.instance.findExistingUuids(
      data.cards.map((c) => c.uuid),
    );
    return ImportPreview(
      data: data,
      duplicateCount: duplicates.length,
      wasEncrypted: backup.isEncrypted,
    );
  }

  /// 把预览中的数据写入数据库。
  static Future<ImportResult> importBackup(
    ImportPreview preview,
    ImportConflictPolicy policy,
  ) => DatabaseHelper.instance.importBackup(preview.data, policy: policy);
}
