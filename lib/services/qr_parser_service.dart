/// eSIM 激活码（GSMA SGP.22 §4.1 Activation Code）。
///
/// 二维码内容为 `LPA:` 加上以 `$` 分隔的字段：
///
/// | 序号 | 字段 | 说明 |
/// | --- | --- | --- |
/// | 1 | AC_Format | 固定为 `1` |
/// | 2 | SM-DP+ 地址 | 主机名，如 `smdp.example.com` |
/// | 3 | AC_Token（匹配 ID） | 运营商分配的 Matching ID |
/// | 4 | SM-DP+ OID | 可选 |
/// | 5 | 确认码必需标志 | 可选，`1` 表示安装时需要运营商另行提供的确认码 |
///
/// 注意：确认码本身从不出现在激活码中。
class LpaActivationCode {
  const LpaActivationCode({
    required this.smdpAddress,
    required this.matchingId,
    this.smdpOid,
    this.confirmationCodeRequired = false,
  });

  final String smdpAddress;
  final String matchingId;
  final String? smdpOid;
  final bool confirmationCodeRequired;

  /// 规范化的激活码文本（带 `LPA:` 前缀），可用于复制或重新生成二维码。
  String toLpaString() {
    final fields = <String>['1', smdpAddress, matchingId];
    if (smdpOid != null || confirmationCodeRequired) fields.add(smdpOid ?? '');
    if (confirmationCodeRequired) fields.add('1');
    return 'LPA:${fields.join(r'$')}';
  }

  @override
  String toString() => toLpaString();
}

/// 二维码 / 激活码文本的解析结果。
class QrParseResult {
  const QrParseResult._({required this.rawData, this.code, this.errorMessage});

  factory QrParseResult.success(LpaActivationCode code, String rawData) =>
      QrParseResult._(rawData: rawData, code: code);

  factory QrParseResult.failure(String message, String rawData) =>
      QrParseResult._(rawData: rawData, errorMessage: message);

  /// 去除首尾空白后的原始内容。
  final String rawData;
  final LpaActivationCode? code;
  final String? errorMessage;

  bool get isSuccess => code != null;

  @override
  String toString() => isSuccess
      ? 'QrParseResult($code)'
      : 'QrParseResult(error: $errorMessage)';
}

/// eSIM 激活码解析（GSMA SGP.22 v2.2.2 §4.1）。
abstract final class QrParserService {
  static final RegExp _hostname = RegExp(
    r'^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?'
    r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*(?::\d{1,5})?$',
  );

  /// 解析二维码内容或手动输入的激活码文本。
  ///
  /// 同时接受带 `LPA:` 前缀（二维码）与不带前缀（如邮件中给出的 `1$...`）的写法。
  static QrParseResult parse(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return QrParseResult.failure('内容为空', raw);

    var body = raw;
    if (body.toUpperCase().startsWith('LPA:')) {
      body = body.substring(4);
    } else if (!body.startsWith(r'1$')) {
      return QrParseResult.failure(r'不是 eSIM 激活码（应以 LPA:1$ 开头）', raw);
    }

    final fields = body.split(r'$').map((f) => f.trim()).toList();
    if (fields.first != '1') {
      return QrParseResult.failure('不支持的激活码格式版本「${fields.first}」', raw);
    }
    if (fields.length < 3) {
      return QrParseResult.failure('激活码不完整，缺少 SM-DP+ 地址或匹配 ID', raw);
    }

    final smdpAddress = fields[1];
    if (smdpAddress.isEmpty) {
      return QrParseResult.failure('SM-DP+ 地址为空', raw);
    }
    if (!_hostname.hasMatch(smdpAddress)) {
      return QrParseResult.failure('SM-DP+ 地址格式不正确：$smdpAddress', raw);
    }

    final matchingId = fields[2];
    if (matchingId.isEmpty) {
      return QrParseResult.failure('匹配 ID 为空', raw);
    }

    final oid = fields.length > 3 && fields[3].isNotEmpty ? fields[3] : null;
    final confirmationCodeRequired = fields.length > 4 && fields[4] == '1';

    return QrParseResult.success(
      LpaActivationCode(
        smdpAddress: smdpAddress,
        matchingId: matchingId,
        smdpOid: oid,
        confirmationCodeRequired: confirmationCodeRequired,
      ),
      raw,
    );
  }
}
