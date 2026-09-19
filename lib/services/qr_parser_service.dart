/// eSIM QR码解析服务
///
/// 解析 LPA 格式的 eSIM 激活码：
/// `LPA:1$<SM-DP+ 地址>$<匹配 ID>[$<确认码>]`
class QrParserService {
  QrParserService._();

  /// 解析 QR 码原始数据
  static QrParseResult parse(String rawData) {
    if (rawData.isEmpty) {
      return QrParseResult.failure('QR码数据为空');
    }

    final trimmed = rawData.trim();

    // 检查 LPA 前缀（不区分大小写）
    if (!trimmed.toUpperCase().startsWith('LPA:')) {
      return QrParseResult.failure('不是有效的 eSIM 激活码格式（缺少 LPA: 前缀）');
    }

    // 移除 "LPA:" 前缀
    final afterPrefix = trimmed.substring(4);

    // 按 '$' 分割
    final parts = afterPrefix.split(r'$');

    // 至少需要 3 个部分：协议版本、SM-DP+ 地址、匹配 ID
    if (parts.length < 3) {
      return QrParseResult.failure(
        '激活码格式不完整，需要包含 SM-DP+ 地址和匹配 ID',
      );
    }

    // 解析协议版本（通常为 "1"）
    final protocolVersion = parts[0].trim();
    if (protocolVersion.isEmpty) {
      return QrParseResult.failure('缺少协议版本号');
    }

    // SM-DP+ 地址
    final smdpAddress = parts[1].trim();
    if (smdpAddress.isEmpty) {
      return QrParseResult.failure('SM-DP+ 地址为空');
    }

    // 匹配 ID
    final matchingId = parts[2].trim();
    if (matchingId.isEmpty) {
      return QrParseResult.failure('匹配 ID 为空');
    }

    // 可选的确认码（第4个部分）
    String? confirmationCode;
    if (parts.length > 3) {
      final code = parts[3].trim();
      if (code.isNotEmpty) {
        confirmationCode = code;
      }
    }

    return QrParseResult.success(
      smdpAddress: smdpAddress,
      matchingId: matchingId,
      confirmationCode: confirmationCode,
      rawData: trimmed,
    );
  }

  /// 验证一个字符串是否为有效的 LPA 格式
  static bool isValidLpaFormat(String data) {
    final result = parse(data);
    return result.isSuccess;
  }

  /// 从解析结果构建 LPA 字符串
  static String buildLpaString({
    required String smdpAddress,
    required String matchingId,
    String? confirmationCode,
  }) {
    final buffer = StringBuffer('LPA:1\$$smdpAddress\$$matchingId');
    if (confirmationCode != null && confirmationCode.isNotEmpty) {
      buffer.write('\$$confirmationCode');
    }
    return buffer.toString();
  }
}

/// QR码解析结果
class QrParseResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? smdpAddress;
  final String? matchingId;
  final String? confirmationCode;
  final String? rawData;

  const QrParseResult._({
    required this.isSuccess,
    this.errorMessage,
    this.smdpAddress,
    this.matchingId,
    this.confirmationCode,
    this.rawData,
  });

  factory QrParseResult.success({
    required String smdpAddress,
    required String matchingId,
    String? confirmationCode,
    required String rawData,
  }) {
    return QrParseResult._(
      isSuccess: true,
      smdpAddress: smdpAddress,
      matchingId: matchingId,
      confirmationCode: confirmationCode,
      rawData: rawData,
    );
  }

  factory QrParseResult.failure(String message) {
    return QrParseResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'QrParseResult(SM-DP+: $smdpAddress, matchingId: $matchingId, '
          'confirmationCode: $confirmationCode)';
    }
    return 'QrParseResult(error: $errorMessage)';
  }
}
