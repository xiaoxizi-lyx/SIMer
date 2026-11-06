import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// 设备能否进行身份验证。
enum AuthAvailability {
  /// 已设置锁屏密码或录入了生物识别。
  available,

  /// 设备没有任何可用的验证方式（未设置锁屏）。
  notConfigured,

  /// 查询失败（插件或系统异常）。
  error,
}

/// 一次身份验证的结果。
enum AuthResult { success, cancelled, noCredentials, lockedOut, failed }

/// 身份验证后端；测试中可替换为假实现。
abstract interface class AuthBackend {
  Future<AuthAvailability> availability();

  Future<AuthResult> authenticate();
}

/// 基于 `local_auth` 的实现：优先生物识别，可回退到设备密码。
class LocalAuthBackend implements AuthBackend {
  LocalAuthBackend([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<AuthAvailability> availability() async {
    try {
      return await _auth.isDeviceSupported()
          ? AuthAvailability.available
          : AuthAvailability.notConfigured;
    } on Exception catch (e) {
      debugPrint('查询身份验证能力失败: $e');
      return AuthAvailability.error;
    }
  }

  @override
  Future<AuthResult> authenticate() async {
    try {
      final success = await _auth.authenticate(
        localizedReason: '请验证身份以访问 SIMer',
        biometricOnly: false, // 允许回退到设备密码
        persistAcrossBackgrounding: true,
        sensitiveTransaction: false,
      );
      return success ? AuthResult.success : AuthResult.failed;
    } on LocalAuthException catch (e) {
      return switch (e.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled ||
        LocalAuthExceptionCode.timeout ||
        LocalAuthExceptionCode.userRequestedFallback => AuthResult.cancelled,
        LocalAuthExceptionCode.noCredentialsSet => AuthResult.noCredentials,
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout => AuthResult.lockedOut,
        _ => AuthResult.failed,
      };
    }
  }
}
