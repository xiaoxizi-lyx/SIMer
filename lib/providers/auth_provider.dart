import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/platform_service.dart';

/// 离开应用多久后重新上锁。
enum LockTimeout {
  immediately(Duration.zero, '立即'),
  seconds30(Duration(seconds: 30), '30 秒后'),
  minute1(Duration(minutes: 1), '1 分钟后'),
  minutes5(Duration(minutes: 5), '5 分钟后');

  const LockTimeout(this.duration, this.label);
  final Duration duration;
  final String label;

  static LockTimeout fromName(String? name) => LockTimeout.values.firstWhere(
    (t) => t.name == name,
    orElse: () => LockTimeout.seconds30,
  );
}

/// 应用锁与防窥保护。
///
/// - 冷启动时、以及离开应用超过 [lockTimeout] 后回来时要求验证身份；
/// - 本应用主动打开的系统界面（文件选择器、分享面板等）期间不会触发上锁，
///   见 [withoutAutoLock]；
/// - 查询验证能力出错时保持锁定（失败即锁定），只有设备确实没有任何锁屏方式时
///   才自动关闭应用锁，并通过 [notice] 告知用户。
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthBackend? backend})
    : _backend = backend ?? LocalAuthBackend();

  static const String _lockEnabledKey = 'app_lock_enabled';
  static const String _lockTimeoutKey = 'app_lock_timeout';
  static const String _privacyKey = 'privacy_protection_enabled';

  final AuthBackend _backend;

  bool _lockEnabled = false;
  bool _locked = false;
  bool _authenticating = false;
  bool _deviceSecure = false;
  bool _privacyProtection = true;
  LockTimeout _lockTimeout = LockTimeout.seconds30;
  String? _lastError;
  String? _notice;
  DateTime? _backgroundedAt;
  int _suspendDepth = 0;

  bool get lockEnabled => _lockEnabled;

  /// 当前是否需要显示锁屏。
  bool get isLocked => _lockEnabled && _locked;
  bool get isAuthenticating => _authenticating;

  /// 设备是否设置了锁屏密码或生物识别（可以开启应用锁）。
  bool get deviceSecure => _deviceSecure;
  LockTimeout get lockTimeout => _lockTimeout;
  bool get privacyProtection => _privacyProtection;

  /// 最近一次验证失败的原因（显示在锁屏上）。
  String? get lastError => _lastError;

  /// 需要告知用户的一次性提示（例如应用锁被自动关闭）。
  String? get notice => _notice;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _lockEnabled = prefs.getBool(_lockEnabledKey) ?? false;
    _lockTimeout = LockTimeout.fromName(prefs.getString(_lockTimeoutKey));
    _privacyProtection = prefs.getBool(_privacyKey) ?? true;

    final availability = await _backend.availability();
    _deviceSecure = availability == AuthAvailability.available;
    if (_lockEnabled) {
      if (availability == AuthAvailability.notConfigured) {
        // 设备已移除锁屏（移除时系统本身要求验证原密码），无法再验证身份
        _lockEnabled = false;
        await prefs.setBool(_lockEnabledKey, false);
        _notice = '设备已不再设置锁屏密码或生物识别，应用锁已自动关闭';
      } else {
        // 可用或查询出错都保持锁定；出错时锁屏上可重试
        _locked = true;
      }
    }
    await PlatformService.setPrivacyProtection(enabled: _privacyProtection);
    notifyListeners();
  }

  /// 验证身份以解锁。返回是否已解锁。
  Future<bool> authenticate() async {
    if (!_lockEnabled) {
      _locked = false;
      notifyListeners();
      return true;
    }
    if (_authenticating) return false;
    _authenticating = true;
    _lastError = null;
    notifyListeners();
    try {
      final result = await _backend.authenticate();
      switch (result) {
        case AuthResult.success:
          _locked = false;
        case AuthResult.cancelled:
          break;
        case AuthResult.noCredentials:
          // 运行期间设备移除了锁屏：与启动时的处理一致
          _lockEnabled = false;
          _locked = false;
          _notice = '设备已不再设置锁屏密码或生物识别，应用锁已自动关闭';
          await _savePref((p) => p.setBool(_lockEnabledKey, false));
        case AuthResult.lockedOut:
          _lastError = '尝试次数过多，请稍后再试或使用设备密码';
        case AuthResult.failed:
          _lastError = '验证失败，请重试';
      }
      return !isLocked;
    } finally {
      _authenticating = false;
      _backgroundedAt = null;
      notifyListeners();
    }
  }

  /// 开启或关闭应用锁（两种操作都需要先验证身份）。返回错误信息，成功时为 null。
  Future<String?> setLockEnabled(bool enabled) async {
    if (_lockEnabled == enabled) return null;
    final availability = await _backend.availability();
    _deviceSecure = availability == AuthAvailability.available;
    if (enabled && !_deviceSecure) {
      notifyListeners();
      return '请先在系统设置中设置锁屏密码或生物识别';
    }
    if (availability == AuthAvailability.available) {
      _authenticating = true;
      notifyListeners();
      final AuthResult result;
      try {
        result = await _backend.authenticate();
      } finally {
        _authenticating = false;
        _backgroundedAt = null;
      }
      if (result != AuthResult.success) {
        notifyListeners();
        return result == AuthResult.cancelled ? null : '身份验证失败';
      }
    }
    _lockEnabled = enabled;
    _locked = false;
    notifyListeners();
    await _savePref((p) => p.setBool(_lockEnabledKey, enabled));
    return null;
  }

  Future<void> setLockTimeout(LockTimeout timeout) async {
    if (_lockTimeout == timeout) return;
    _lockTimeout = timeout;
    notifyListeners();
    await _savePref((p) => p.setString(_lockTimeoutKey, timeout.name));
  }

  Future<void> setPrivacyProtection(bool enabled) async {
    if (_privacyProtection == enabled) return;
    _privacyProtection = enabled;
    notifyListeners();
    await PlatformService.setPrivacyProtection(enabled: enabled);
    await _savePref((p) => p.setBool(_privacyKey, enabled));
  }

  void dismissNotice() {
    if (_notice == null) return;
    _notice = null;
    notifyListeners();
  }

  /// 应用生命周期变化（由 AppLockGate 转发）。
  void handleLifecycle(AppLifecycleState state) {
    if (!_lockEnabled || _authenticating || _suspendDepth > 0) return;
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _backgroundedAt ??= clock.now();
        if (_lockTimeout == LockTimeout.immediately && !_locked) {
          _locked = true;
          notifyListeners();
        }
      case AppLifecycleState.resumed:
        final since = _backgroundedAt;
        _backgroundedAt = null;
        if (since != null &&
            !_locked &&
            clock.now().difference(since) >= _lockTimeout.duration) {
          _locked = true;
          notifyListeners();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  /// 执行由本应用主动打开系统界面的操作（文件选择、分享、相册等），期间不自动上锁。
  Future<T> withoutAutoLock<T>(Future<T> Function() action) async {
    _suspendDepth++;
    try {
      return await action();
    } finally {
      _suspendDepth--;
      _backgroundedAt = null;
    }
  }

  static Future<void> _savePref(
    Future<bool> Function(SharedPreferences prefs) write,
  ) async {
    await write(await SharedPreferences.getInstance());
  }
}
