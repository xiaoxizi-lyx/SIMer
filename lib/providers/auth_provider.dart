import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

/// 认证状态管理
class AuthProvider extends ChangeNotifier {
  static const String _biometricEnabledKey = 'biometric_enabled';

  bool _isAuthenticated = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _isLoading = false;

  // ── Getters ──

  bool get isAuthenticated => _isAuthenticated;
  bool get biometricEnabled => _biometricEnabled;
  bool get biometricAvailable => _biometricAvailable;
  bool get isLoading => _isLoading;

  /// 是否需要进行认证（已启用但未认证）
  bool get needsAuthentication => _biometricEnabled && !_isAuthenticated;

  /// 初始化：加载设置并检查设备能力
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 检查设备是否支持生物识别
      _biometricAvailable = await AuthService.isBiometricAvailable();

      // 加载用户设置
      final prefs = await SharedPreferences.getInstance();
      _biometricEnabled = prefs.getBool(_biometricEnabledKey) ?? false;

      // 如果设备不支持，强制关闭
      if (!_biometricAvailable) {
        _biometricEnabled = false;
      }

      // 如果未启用生物识别，直接标记为已认证
      if (!_biometricEnabled) {
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint('初始化认证服务失败: $e');
      // 出错时默认允许访问
      _isAuthenticated = true;
      _biometricEnabled = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 执行生物识别认证
  Future<bool> authenticate() async {
    if (!_biometricEnabled) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await AuthService.authenticate();
      _isAuthenticated = success;
      return success;
    } catch (e) {
      debugPrint('认证失败: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 设置是否启用生物识别锁定
  /// 返回错误信息字符串，null 表示成功
  Future<String?> setBiometricEnabled(bool enabled) async {
    if (_biometricEnabled == enabled) return null;

    // 如果要启用，先验证一次确保可用
    if (enabled) {
      try {
        final isAvailable = await AuthService.isBiometricAvailable();
        if (!isAvailable) {
          return '设备不支持生物识别或未设置锁屏密码';
        }
        final success = await AuthService.authenticate();
        if (!success) return '身份验证失败或已取消';
      } catch (e) {
        debugPrint('生物识别验证异常: $e');
        return '验证过程出现异常: $e';
      }
    }

    _biometricEnabled = enabled;

    // 如果关闭了生物识别，直接标记为已认证
    if (!enabled) {
      _isAuthenticated = true;
    }

    notifyListeners();

    // 持久化设置
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    return null;
  }

  /// 锁定应用（重新要求认证）
  void lock() {
    if (_biometricEnabled) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  /// 当应用恢复到前台时检查是否需要重新认证
  Future<void> onAppResumed() async {
    if (_biometricEnabled && !_isAuthenticated) {
      await authenticate();
    }
  }
}
