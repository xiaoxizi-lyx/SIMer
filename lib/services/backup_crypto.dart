import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';

import 'backup_codec.dart';

/// 加密备份：把 [BackupCodec.encode] 生成的完整备份 JSON 整体加密，放进外层 JSON。
///
/// ```json
/// {
///   "app": "SIMer",
///   "encryption": {
///     "version": 1,
///     "kdf": "PBKDF2-HMAC-SHA512",
///     "iterations": 210000,
///     "salt": "<Base64，16 字节>",
///     "cipher": "AES-256-GCM",
///     "nonce": "<Base64，12 字节>"
///   },
///   "ciphertext": "<Base64：密文 + 16 字节认证标签>"
/// }
/// ```
///
/// - 密钥由密码经 PBKDF2-HMAC-SHA512 派生，默认迭代次数为 OWASP 推荐的 210,000 次；
///   迭代次数写在文件里，以后可以提高而不影响旧文件的读取。
/// - AES-GCM 的认证标签保证：密码错误或文件被改动时一定解密失败，不会得到错误的数据。
/// - 纯 Dart 实现、不依赖平台，计算量较大，应在后台 isolate 中调用。
abstract final class BackupCrypto {
  static const int envelopeVersion = 1;
  static const String kdfName = 'PBKDF2-HMAC-SHA512';
  static const String cipherName = 'AES-256-GCM';
  static const int defaultIterations = 210000;

  /// 读取时接受的最大迭代次数，避免恶意构造的文件让应用长时间无响应。
  static const int maxIterations = 10000000;

  /// 导出时要求的最短密码长度。
  static const int minPasswordLength = 8;

  static const int _saltLength = 16;
  static const int _nonceLength = 12;
  static const int _macLength = 16;

  /// 已解析的 JSON 是否为加密备份。
  static bool isEncrypted(Map<String, dynamic> root) =>
      root['encryption'] is Map && root.containsKey('ciphertext');

  /// 用 [password] 加密备份 JSON，返回加密备份文件的内容。
  static Future<String> encrypt(
    String plaintext,
    String password, {
    int iterations = defaultIterations,
    Random? random,
  }) async {
    final rng = random ?? Random.secure();
    List<int> randomBytes(int length) =>
        List<int>.generate(length, (_) => rng.nextInt(256));

    final salt = randomBytes(_saltLength);
    final nonce = randomBytes(_nonceLength);
    final key = await _deriveKey(password, salt, iterations);
    final box = await DartAesGcm.with256bits().encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );
    return const JsonEncoder.withIndent('  ').convert({
      'app': BackupCodec.appIdentifier,
      'encryption': {
        'version': envelopeVersion,
        'kdf': kdfName,
        'iterations': iterations,
        'salt': base64Encode(salt),
        'cipher': cipherName,
        'nonce': base64Encode(nonce),
      },
      'ciphertext': base64Encode(box.concatenation(nonce: false)),
    });
  }

  /// 解密加密备份，返回其中的备份 JSON 文本。
  ///
  /// 密码错误或文件被改动时抛出 [BackupError.wrongPassword]；
  /// 文件结构不对时抛出 [BackupError.corrupted]；
  /// 加密方式或参数不受支持时抛出 [BackupError.unsupportedEncryption]。
  static Future<String> decrypt(
    Map<String, dynamic> root,
    String password,
  ) async {
    final header = root['encryption'];
    if (header is! Map<String, dynamic>) {
      throw const BackupFormatException(BackupError.corrupted);
    }
    final version = header['version'];
    if (version is! int) {
      throw const BackupFormatException(BackupError.corrupted);
    }
    if (version > envelopeVersion) {
      throw const BackupFormatException(BackupError.newerVersion);
    }
    final iterations = header['iterations'];
    if (version != envelopeVersion ||
        header['kdf'] != kdfName ||
        header['cipher'] != cipherName ||
        iterations is! int ||
        iterations < 1 ||
        iterations > maxIterations) {
      throw const BackupFormatException(BackupError.unsupportedEncryption);
    }

    final salt = _base64(header['salt']);
    final nonce = _base64(header['nonce']);
    final sealed = _base64(root['ciphertext']);
    if (salt.isEmpty ||
        nonce.length != _nonceLength ||
        sealed.length < _macLength) {
      throw const BackupFormatException(BackupError.corrupted);
    }

    final key = await _deriveKey(password, salt, iterations);
    final box = SecretBox(
      sealed.sublist(0, sealed.length - _macLength),
      nonce: nonce,
      mac: Mac(sealed.sublist(sealed.length - _macLength)),
    );
    final List<int> clear;
    try {
      clear = await DartAesGcm.with256bits().decrypt(box, secretKey: key);
    } on SecretBoxAuthenticationError {
      throw const BackupFormatException(BackupError.wrongPassword);
    }
    try {
      return utf8.decode(clear);
    } on FormatException {
      throw const BackupFormatException(BackupError.corrupted);
    }
  }

  static Uint8List _base64(Object? value) {
    if (value is! String) {
      throw const BackupFormatException(BackupError.corrupted);
    }
    try {
      return base64Decode(value);
    } on FormatException {
      throw const BackupFormatException(BackupError.corrupted);
    }
  }

  static Future<SecretKey> _deriveKey(
    String password,
    List<int> salt,
    int iterations,
  ) => DartPbkdf2(
    macAlgorithm: const DartHmac(DartSha512()),
    iterations: iterations,
    bits: 256,
  ).deriveKeyFromPassword(password: password, nonce: salt);
}
