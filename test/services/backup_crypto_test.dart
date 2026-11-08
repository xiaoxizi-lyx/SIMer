import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:simer/services/backup_codec.dart';
import 'package:simer/services/backup_crypto.dart';

/// 测试中使用较少的迭代次数，避免拖慢测试；默认参数单独测试一次。
const _fastIterations = 1000;

const _plaintext = '{"app":"SIMer","formatVersion":2,"simCards":[],"tags":[]}';

Future<Map<String, dynamic>> _encrypt(
  String plaintext,
  String password, {
  int iterations = _fastIterations,
}) async => jsonDecode(
  await BackupCrypto.encrypt(plaintext, password, iterations: iterations),
) as Map<String, dynamic>;

Matcher _throwsBackupError(BackupError error) => throwsA(
  isA<BackupFormatException>().having((e) => e.error, 'error', error),
);

void main() {
  group('BackupCrypto', () {
    test('加密后可用同一密码解密，密文不含明文', () async {
      final root = await _encrypt(_plaintext, 'correct horse');
      expect(BackupCrypto.isEncrypted(root), isTrue);
      expect(jsonEncode(root), isNot(contains('simCards')));
      expect(await BackupCrypto.decrypt(root, 'correct horse'), _plaintext);
    });

    test('支持中文与表情等任意字符的密码和内容', () async {
      const text = '{"notes":"中国移动 · 保号卡 📶"}';
      final root = await _encrypt(text, '密码🔑テスト');
      expect(await BackupCrypto.decrypt(root, '密码🔑テスト'), text);
    });

    test('写入文件头的参数与默认值一致（真实迭代次数）', () async {
      final root = await _encrypt(
        _plaintext,
        'correct horse',
        iterations: BackupCrypto.defaultIterations,
      );
      final header = root['encryption'] as Map<String, dynamic>;
      expect(root['app'], 'SIMer');
      expect(header['version'], BackupCrypto.envelopeVersion);
      expect(header['kdf'], 'PBKDF2-HMAC-SHA512');
      expect(header['cipher'], 'AES-256-GCM');
      expect(header['iterations'], 210000);
      expect(base64Decode(header['salt'] as String), hasLength(16));
      expect(base64Decode(header['nonce'] as String), hasLength(12));
      expect(await BackupCrypto.decrypt(root, 'correct horse'), _plaintext);
    });

    test('每次加密使用不同的盐与随机数', () async {
      final a = await _encrypt(_plaintext, 'pw123456');
      final b = await _encrypt(_plaintext, 'pw123456');
      expect(a['encryption'], isNot(equals(b['encryption'])));
      expect(a['ciphertext'], isNot(b['ciphertext']));
    });

    test('密码错误时报告密码错误，而不是返回错误数据', () async {
      final root = await _encrypt(_plaintext, 'right password');
      await expectLater(
        BackupCrypto.decrypt(root, 'wrong password'),
        _throwsBackupError(BackupError.wrongPassword),
      );
    });

    test('密文、盐或迭代次数被改动时解密失败', () async {
      final root = await _encrypt(_plaintext, 'pw123456');
      final header = root['encryption'] as Map<String, dynamic>;

      final sealed = base64Decode(root['ciphertext'] as String);
      sealed[0] ^= 0x01;
      await expectLater(
        BackupCrypto.decrypt({
          ...root,
          'ciphertext': base64Encode(sealed),
        }, 'pw123456'),
        _throwsBackupError(BackupError.wrongPassword),
      );

      final salt = base64Decode(header['salt'] as String);
      salt[0] ^= 0x01;
      await expectLater(
        BackupCrypto.decrypt({
          ...root,
          'encryption': {...header, 'salt': base64Encode(salt)},
        }, 'pw123456'),
        _throwsBackupError(BackupError.wrongPassword),
      );

      await expectLater(
        BackupCrypto.decrypt({
          ...root,
          'encryption': {...header, 'iterations': _fastIterations + 1},
        }, 'pw123456'),
        _throwsBackupError(BackupError.wrongPassword),
      );
    });

    test('文件结构损坏时报告文件损坏', () async {
      final root = await _encrypt(_plaintext, 'pw123456');
      await expectLater(
        BackupCrypto.decrypt({...root, 'ciphertext': '%%%'}, 'pw123456'),
        _throwsBackupError(BackupError.corrupted),
      );
      await expectLater(
        BackupCrypto.decrypt({...root, 'ciphertext': 42}, 'pw123456'),
        _throwsBackupError(BackupError.corrupted),
      );
      await expectLater(
        BackupCrypto.decrypt({...root, 'encryption': 'x'}, 'pw123456'),
        _throwsBackupError(BackupError.corrupted),
      );
    });

    test('拒绝更新版本或不支持的加密参数，并限制迭代次数上限', () async {
      final root = await _encrypt(_plaintext, 'pw123456');
      final header = root['encryption'] as Map<String, dynamic>;
      Map<String, dynamic> withHeader(Map<String, dynamic> changes) => {
        ...root,
        'encryption': {...header, ...changes},
      };

      await expectLater(
        BackupCrypto.decrypt(withHeader({'version': 2}), 'pw123456'),
        _throwsBackupError(BackupError.newerVersion),
      );
      for (final changes in <Map<String, dynamic>>[
        {'kdf': 'scrypt'},
        {'cipher': 'AES-128-CBC'},
        {'iterations': 0},
        {'iterations': BackupCrypto.maxIterations + 1},
        {'iterations': 'many'},
      ]) {
        await expectLater(
          BackupCrypto.decrypt(withHeader(changes), 'pw123456'),
          _throwsBackupError(BackupError.unsupportedEncryption),
          reason: '$changes',
        );
      }
    });

    test('普通（未加密）备份不会被识别为加密备份', () {
      expect(
        BackupCrypto.isEncrypted(
          jsonDecode(_plaintext) as Map<String, dynamic>,
        ),
        isFalse,
      );
    });

    test('可注入随机数源，便于复现', () async {
      final a = await BackupCrypto.encrypt(
        _plaintext,
        'pw123456',
        iterations: _fastIterations,
        random: Random(1),
      );
      final b = await BackupCrypto.encrypt(
        _plaintext,
        'pw123456',
        iterations: _fastIterations,
        random: Random(1),
      );
      expect(a, b);
    });
  });
}
