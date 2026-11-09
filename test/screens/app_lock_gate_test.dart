import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simer/l10n/app_localizations.dart';
import 'package:simer/providers/auth_provider.dart';
import 'package:simer/screens/lock_screen.dart';
import 'package:simer/services/auth_service.dart';

import '../support/l10n.dart';

class _Backend implements AuthBackend {
  AuthResult result = AuthResult.success;

  @override
  Future<AuthAvailability> availability() async => AuthAvailability.available;

  @override
  Future<AuthResult> authenticate(AuthPrompt prompt) async => result;
}

void main() {
  testWidgets('锁定后锁屏覆盖已打开的页面，下层内容不可点击', (tester) async {
    SharedPreferences.setMockInitialValues({
      'app_lock_enabled': true,
      'app_lock_timeout': 'immediately',
    });
    final backend = _Backend();
    final auth = AuthProvider(backend: backend);
    await tester.runAsync(auth.initialize);
    await tester.runAsync(() => auth.authenticate(testPrompt));
    expect(auth.isLocked, isFalse);
    // 之后锁屏自动发起的验证被用户取消，应保持锁定
    backend.result = AuthResult.cancelled;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: MaterialApp(
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => AppLockGate(child: child!),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('ICCID 8986...')),
                  ),
                ),
                child: const Text('打开详情'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开详情'));
    await tester.pumpAndSettle();
    expect(find.text('ICCID 8986...').hitTestable(), findsOneWidget);

    auth.handleLifecycle(AppLifecycleState.paused);
    await tester.pump();

    expect(find.byType(LockScreen), findsOneWidget);
    expect(find.text('ICCID 8986...').hitTestable(), findsNothing);
  });
}
