import 'dart:convert';

import '../models/json_utils.dart';
import '../models/sim_card.dart';
import '../models/tag.dart';

/// 整份备份文件不可用的原因；界面层把它转换为当前语言的说明。
enum BackupError {
  /// 文件超过 [BackupCodec.maxFileBytes]。
  fileTooLarge,

  /// 文件不是 UTF-8 文本。
  notUtf8,

  /// 无法读取所选文件。
  unreadable,

  /// 文件不是有效的 JSON。
  notJson,

  /// JSON 结构不是 SIMer 备份。
  unrecognized,

  /// 由更新版本的 SIMer 导出。
  newerVersion,

  /// 格式版本无法识别。
  unsupportedVersion,

  /// 缺少格式版本信息。
  missingVersion,

  /// 文件结构已损坏（例如顶层的列表字段类型不对）。
  corrupted,

  /// 加密备份：密码错误，或文件被修改、已损坏（AES-GCM 无法区分这两种情况）。
  wrongPassword,

  /// 加密备份使用了本版本不支持的加密方式或参数。
  unsupportedEncryption,
}

/// 整份备份文件不可用。
class BackupFormatException implements Exception {
  const BackupFormatException(this.error);

  final BackupError error;

  @override
  String toString() => 'BackupFormatException(${error.name})';
}

/// 备份中的记录类型。
enum BackupRecordKind { tag, card }

/// 备份中单条记录解析失败；导入时跳过该记录并向用户汇报。
class BackupRecordError {
  const BackupRecordError({
    required this.kind,
    required this.index,
    this.field,
    this.problem,
  });

  final BackupRecordKind kind;

  /// 记录在备份中的序号（从 1 开始）。
  final int index;

  /// 出问题的字段；为 null 时表示整条记录的格式不对。
  final String? field;
  final JsonFieldProblem? problem;

  @override
  String toString() =>
      'BackupRecordError(${kind.name} #$index, '
      '${field ?? 'record'}: ${problem?.name ?? 'invalid'})';
}

/// 备份中的标签，保留其在来源数据库中的 id，用于还原卡片与标签的关联。
class BackupTag {
  const BackupTag({required this.sourceId, required this.tag});

  final int? sourceId;
  final Tag tag;
}

/// 导入时遇到本机已存在（UUID 相同）的卡片如何处理。
enum ImportConflictPolicy {
  /// 保留本机数据，跳过备份中的这张卡片。
  skip,

  /// 用备份中的数据覆盖本机这张卡片。
  overwrite,
}

/// 解析后的备份内容（尚未写入数据库）。
class BackupData {
  const BackupData({
    required this.formatVersion,
    required this.exportedAt,
    required this.tags,
    required this.cards,
    required this.errors,
  });

  final int formatVersion;
  final DateTime? exportedAt;
  final List<BackupTag> tags;

  /// 卡片的 [SimCard.tagIds] 仍是来源数据库中的标签 id，导入时再映射为本机 id。
  final List<SimCard> cards;

  /// 无法解析、将被跳过的记录。
  final List<BackupRecordError> errors;
}

/// SIMer 备份文件（JSON）的编码与解码。纯 Dart 实现，不依赖数据库与平台。
///
/// 加密备份是把这里的 JSON 整体加密后放进另一层 JSON，见 `BackupCrypto`。
abstract final class BackupCodec {
  /// 当前导出格式版本。
  static const int currentFormatVersion = 2;

  /// SIMer 1.0.x 导出的格式（顶层字段为 `"version": 1`）。
  static const int legacyFormatVersion = 1;

  /// 拒绝读取超过此大小的文件，避免误选大文件导致内存问题。
  static const int maxFileBytes = 10 * 1024 * 1024;

  static const String appIdentifier = 'SIMer';

  static String encode({
    required List<SimCard> cards,
    required List<Tag> tags,
    required DateTime exportedAt,
  }) {
    final data = <String, Object?>{
      'app': appIdentifier,
      'formatVersion': currentFormatVersion,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'tags': [for (final tag in tags) tag.toJson()],
      'simCards': [for (final card in cards) card.toJson()],
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// 解析 JSON 文本为对象。不是 JSON 对象时抛出 [BackupFormatException]。
  static Map<String, dynamic> parseRoot(String source) {
    final Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException {
      throw const BackupFormatException(BackupError.notJson);
    }
    if (root is! Map<String, dynamic>) {
      throw const BackupFormatException(BackupError.unrecognized);
    }
    return root;
  }

  /// 解析备份文本。整份文件不可用时抛出 [BackupFormatException]；
  /// 单条记录损坏时记入 [BackupData.errors] 并继续解析其余记录。
  static BackupData decode(String source) => decodeRoot(parseRoot(source));

  /// 同 [decode]，输入为已解析的 JSON 对象。
  static BackupData decodeRoot(Map<String, dynamic> root) {
    final formatVersion = _detectFormatVersion(root);
    final errors = <BackupRecordError>[];

    final tags = <BackupTag>[];
    final rawTags = _list(root, 'tags');
    for (var i = 0; i < rawTags.length; i++) {
      try {
        final tag = Tag.fromJson(_object(rawTags[i]));
        tags.add(BackupTag(sourceId: tag.id, tag: tag));
      } on FormatException catch (e) {
        errors.add(_recordError(BackupRecordKind.tag, i + 1, e));
      }
    }

    final cards = <SimCard>[];
    final rawCards = _list(root, 'simCards');
    for (var i = 0; i < rawCards.length; i++) {
      try {
        cards.add(SimCard.fromJson(_object(rawCards[i])));
      } on FormatException catch (e) {
        errors.add(_recordError(BackupRecordKind.card, i + 1, e));
      }
    }

    final exportedAt = root['exportedAt'];
    return BackupData(
      formatVersion: formatVersion,
      exportedAt: exportedAt is String ? DateTime.tryParse(exportedAt) : null,
      tags: tags,
      cards: cards,
      errors: errors,
    );
  }

  static BackupRecordError _recordError(
    BackupRecordKind kind,
    int index,
    FormatException e,
  ) => e is JsonFieldException
      ? BackupRecordError(
          kind: kind,
          index: index,
          field: e.field,
          problem: e.problem,
        )
      : BackupRecordError(kind: kind, index: index);

  static int _detectFormatVersion(Map<String, dynamic> root) {
    final version = root['formatVersion'];
    if (version is int) {
      if (version > currentFormatVersion) {
        throw const BackupFormatException(BackupError.newerVersion);
      }
      if (version < legacyFormatVersion) {
        throw const BackupFormatException(BackupError.unsupportedVersion);
      }
      return version;
    }
    if (root['version'] == legacyFormatVersion && root['simCards'] is List) {
      return legacyFormatVersion;
    }
    throw const BackupFormatException(BackupError.missingVersion);
  }

  static List<Object?> _list(Map<String, dynamic> root, String key) {
    final value = root[key];
    if (value == null) return const [];
    if (value is List) return value;
    throw const BackupFormatException(BackupError.corrupted);
  }

  static Map<String, dynamic> _object(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('record is not an object');
  }
}
