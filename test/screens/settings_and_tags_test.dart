import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simer/l10n/app_localizations.dart';
import 'package:simer/models/tag.dart';
import 'package:simer/providers/auth_provider.dart';
import 'package:simer/providers/filter_provider.dart';
import 'package:simer/providers/locale_provider.dart';
import 'package:simer/providers/reminder_provider.dart';
import 'package:simer/providers/sim_card_provider.dart';
import 'package:simer/providers/theme_provider.dart';
import 'package:simer/screens/settings_screen.dart';
import 'package:simer/screens/tag_manage_screen.dart';
import 'package:simer/services/auth_service.dart';

import '../support/test_db.dart';

class _Backend implements AuthBackend {
  @override
  Future<AuthAvailability> availability() async => AuthAvailability.available;

  @override
  Future<AuthResult> authenticate(AuthPrompt prompt) async =>
      AuthResult.success;
}

void main() {
  final dbs = useTestDatabases();

  Widget app({
    required LocaleProvider locale,
    required SimCardProvider cards,
    required AuthProvider auth,
    required Widget home,
  }) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider.value(value: locale),
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: cards),
      ChangeNotifierProvider(create: (_) => FilterProvider()),
      ChangeNotifierProvider(
        create: (_) => ReminderProvider(cards: cards, locale: locale),
      ),
    ],
    child: Consumer<LocaleProvider>(
      builder: (_, l, _) => MaterialApp(
        locale: l.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: home,
      ),
    ),
  );

  testWidgets('设置页渲染无异常，可以切换语言与「隐藏敏感信息」', (tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'app_language': 'zh'});
    final locale = LocaleProvider();
    await tester.runAsync(locale.load);
    final auth = AuthProvider(backend: _Backend());

    await tester.pumpWidget(
      app(
        locale: locale,
        cards: SimCardProvider(database: dbs.open('settings')),
        auth: auth,
        home: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsOneWidget);

    await tester.tap(find.text('语言 / Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(locale.language, AppLanguage.en);
    expect(find.text('Settings'), findsOneWidget);

    // 主题设置里也有「System default」：只点语言对话框中的那一项
    await tester.tap(find.text('Language / 语言'));
    await tester.pumpAndSettle();
    expect(find.text('System default'), findsNWidgets(2));
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('System default'),
      ),
    );
    await tester.pumpAndSettle();
    expect(locale.language, AppLanguage.system);

    await tester.tap(find.text('Hide sensitive details'));
    await tester.pumpAndSettle();
    expect(auth.maskSensitiveInfo, isFalse);

    // 语言变化会触发提醒重新预约（500 ms 防抖），让计时器走完
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('标签管理页渲染无异常', (tester) async {
    SharedPreferences.setMockInitialValues({'app_language': 'zh'});
    final locale = LocaleProvider();
    await tester.runAsync(locale.load);
    final cards = SimCardProvider(database: dbs.open('tags'));
    await tester.runAsync(
      () => cards.addTag(Tag(name: '旅行', color: 0xFF34C759)),
    );

    await tester.pumpWidget(
      app(
        locale: locale,
        cards: cards,
        auth: AuthProvider(backend: _Backend()),
        home: const TagManageScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('旅行'), findsOneWidget);

    // 图标按钮有可读的说明，点击编辑会打开预填好的对话框
    await tester.tap(find.byTooltip('编辑'));
    await tester.pumpAndSettle();
    expect(find.text('编辑标签'), findsOneWidget);
    expect(find.widgetWithText(TextField, '旅行'), findsOneWidget);
    expect(find.byTooltip('删除'), findsOneWidget);
  });
}
