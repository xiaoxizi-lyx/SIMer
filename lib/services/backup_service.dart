import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';

/// 数据备份与恢复服务
class BackupService {
  BackupService._();

  static const String _filePrefix = 'sim_keeper_backup';
  static const String _fileExtension = '.json';

  /// 导出数据到 JSON 文件并通过分享面板分享
  static Future<BackupResult> exportToJson() async {
    try {
      // 从数据库导出 JSON 字符串
      final jsonString = await DatabaseHelper.instance.exportToJson();

      // 获取导出文件路径
      final filePath = await getExportFilePath();
      final file = File(filePath);

      // 写入文件
      await file.writeAsString(jsonString, flush: true);

      // 通过系统分享面板分享文件
      final xFile = XFile(filePath, mimeType: 'application/json');
      await Share.shareXFiles(
        [xFile],
        subject: 'SIMer 数据备份',
        text: '来自 SIMer 的数据备份文件',
      );

      return BackupResult.success('数据已导出到: ${file.path}');
    } catch (e) {
      return BackupResult.failure('导出失败: $e');
    }
  }

  /// 从 JSON 文件导入数据
  static Future<BackupResult> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return BackupResult.failure('文件不存在: $filePath');
      }

      final jsonString = await file.readAsString();

      // 基本的 JSON 格式验证
      if (jsonString.trim().isEmpty) {
        return BackupResult.failure('文件内容为空');
      }

      final importResult =
          await DatabaseHelper.instance.importFromJson(jsonString);

      return BackupResult.success(importResult.summary);
    } catch (e) {
      return BackupResult.failure('导入失败: $e');
    }
  }

  /// 生成带时间戳的导出文件路径
  static Future<String> getExportFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${_filePrefix}_$timestamp$_fileExtension';
    return '${directory.path}/$fileName';
  }

  /// 获取应用文档目录下所有备份文件
  static Future<List<File>> getBackupFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = Directory(directory.path);

    if (!await dir.exists()) return [];

    final files = await dir
        .list()
        .where((entity) =>
            entity is File &&
            entity.path.contains(_filePrefix) &&
            entity.path.endsWith(_fileExtension))
        .cast<File>()
        .toList();

    // 按修改时间降序排列
    files.sort((a, b) =>
        b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    return files;
  }

  /// 删除指定备份文件
  static Future<bool> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 获取导出文件大小的可读字符串
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// 备份操作结果
class BackupResult {
  final bool isSuccess;
  final String message;

  const BackupResult._({required this.isSuccess, required this.message});

  factory BackupResult.success(String message) =>
      BackupResult._(isSuccess: true, message: message);

  factory BackupResult.failure(String message) =>
      BackupResult._(isSuccess: false, message: message);
}
