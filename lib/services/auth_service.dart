import 'package:local_auth/local_auth.dart';

/// 生物识别认证服务
class AuthService {
  AuthService._();

  static final LocalAuthentication _auth = LocalAuthentication();

  /// 检查设备是否支持生物识别
  static Future<bool> isBiometricAvailable() async {
    try {
      // 检查设备是否支持生物识别硬件
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      // 检查设备是否有可用的认证方式（包括设备密码）
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// 获取可用的生物识别类型
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// 获取生物识别类型的中文描述
  static Future<String> getBiometricTypeLabel() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.face)) {
      return '面容识别';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return '指纹识别';
    } else if (biometrics.contains(BiometricType.iris)) {
      return '虹膜识别';
    }
    return '设备密码';
  }

  /// 触发生物识别认证
  ///
  /// 返回 `true` 表示认证成功，`false` 表示认证失败或取消
  static Future<bool> authenticate() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: '请验证身份以访问 SIMer',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // 允许回退到设备密码
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );
    } catch (_) {
      // 认证过程发生异常（如用户多次失败后被锁定），返回失败
      return false;
    }
  }
}
