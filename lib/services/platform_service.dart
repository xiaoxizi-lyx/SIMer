import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 与 Android 原生层（MainActivity）通信的少量平台能力。
abstract final class PlatformService {
  static const MethodChannel _channel = MethodChannel(
    'io.github.xiaoxizi_lyx.simer/platform',
  );

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// 防窥保护：Android 13+ 在最近任务中隐藏应用快照；更早的系统改用 FLAG_SECURE
  /// （此时也会禁止截屏）。
  static Future<void> setPrivacyProtection({required bool enabled}) =>
      _invoke('setPrivacyProtection', {'enabled': enabled});

  /// 打开系统中本应用的设置页（例如让用户手动授予相机权限）。
  static Future<void> openAppSettings() => _invoke('openAppSettings');

  static Future<void> _invoke(String method, [Object? arguments]) async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on PlatformException catch (e) {
      debugPrint('平台调用 $method 失败: $e');
    } on MissingPluginException {
      // 测试环境或非 Android 平台没有原生实现
    }
  }
}
