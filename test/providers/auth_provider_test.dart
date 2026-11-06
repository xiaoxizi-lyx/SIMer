import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simer/providers/auth_provider.dart';
import 'package:simer/services/auth_service.dart';

class FakeAuthBackend implements AuthBackend {
  AuthAvailability availabilityResult = AuthAvailability.available;
  AuthResult authResult = AuthResult.success;
  int authCalls = 0;

  @override
  Future<AuthAvailability> availability() async => availabilityResult;

  @override
  Future<AuthResult> authenticate() async {
    authCalls++;
    return authResult;
  }
}

Future<AuthProvider> _provider(
  FakeAuthBackend backend, {
  bool lockEnabled = true,
  String timeout = 'seconds30',
}) async {
  SharedPreferences.setMockInitialValues({
    'app_lock_enabled': lockEnabled,
    'app_lock_timeout': timeout,
  });
  final provider = AuthProvider(backend: backend);
  await provider.initialize();
  return provider;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('冷启动时锁定，验证成功后解锁', () async {
    final backend = FakeAuthBackend();
    final auth = await _provider(backend);
    expect(auth.isLocked, isTrue);
    expect(await auth.authenticate(), isTrue);
    expect(auth.isLocked, isFalse);
  });

  test('查询验证能力出错时保持锁定（失败即锁定）', () async {
    final backend = FakeAuthBackend()
      ..availabilityResult = AuthAvailability.error;
    final auth = await _provider(backend);
    expect(auth.isLocked, isTrue);
  });

  test('设备移除了锁屏时自动关闭应用锁并给出提示', () async {
    final backend = FakeAuthBackend()
      ..availabilityResult = AuthAvailability.notConfigured;
    final auth = await _provider(backend);
    expect(auth.lockEnabled, isFalse);
    expect(auth.isLocked, isFalse);
    expect(auth.notice, isNotNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('app_lock_enabled'), isFalse);
  });

  test('离开应用超过设定时长才重新上锁', () async {
    final backend = FakeAuthBackend();
    final auth = await _provider(backend);
    await auth.authenticate();

    var now = DateTime(2026, 11, 6, 12);
    await withClock(Clock(() => now), () async {
      auth.handleLifecycle(AppLifecycleState.paused);
      now = now.add(const Duration(seconds: 10));
      auth.handleLifecycle(AppLifecycleState.resumed);
      expect(auth.isLocked, isFalse, reason: '10 秒 < 30 秒');

      auth.handleLifecycle(AppLifecycleState.hidden);
      now = now.add(const Duration(seconds: 31));
      auth.handleLifecycle(AppLifecycleState.resumed);
      expect(auth.isLocked, isTrue);
    });
  });

  test('「立即」模式在进入后台时就上锁', () async {
    final auth = await _provider(FakeAuthBackend(), timeout: 'immediately');
    await auth.authenticate();
    auth.handleLifecycle(AppLifecycleState.paused);
    expect(auth.isLocked, isTrue);
  });

  test('本应用打开的外部界面（文件选择、分享等）期间不上锁', () async {
    final auth = await _provider(FakeAuthBackend(), timeout: 'immediately');
    await auth.authenticate();
    await auth.withoutAutoLock(() async {
      auth
        ..handleLifecycle(AppLifecycleState.paused)
        ..handleLifecycle(AppLifecycleState.resumed);
    });
    expect(auth.isLocked, isFalse);
  });

  test('开启应用锁需要设备已设置锁屏并通过一次验证', () async {
    final backend = FakeAuthBackend()
      ..availabilityResult = AuthAvailability.notConfigured;
    final auth = await _provider(backend, lockEnabled: false);
    expect(await auth.setLockEnabled(true), isNotNull);
    expect(auth.lockEnabled, isFalse);

    backend
      ..availabilityResult = AuthAvailability.available
      ..authResult = AuthResult.failed;
    expect(await auth.setLockEnabled(true), isNotNull);
    expect(auth.lockEnabled, isFalse);

    backend.authResult = AuthResult.success;
    expect(await auth.setLockEnabled(true), isNull);
    expect(auth.lockEnabled, isTrue);
  });
}
