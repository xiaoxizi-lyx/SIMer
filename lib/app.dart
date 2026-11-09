import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/l10n.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'theme/app_theme.dart';

/// SIMer 主应用
class SimerApp extends StatelessWidget {
  const SimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 只在主题模式或界面语言变化时重建 MaterialApp
    final themeMode = context.select<ThemeProvider, ThemeMode>(
      (p) => p.themeMode,
    );
    final locale = context.select<LocaleProvider, Locale?>((p) => p.locale);
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // 跟随系统时为 null：中文系统显示简体中文，其他语言显示英文。
      // 系统组件（日期选择器、复制粘贴菜单等）与界面使用同一语言。
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const HomeScreen(),
      // 锁屏覆盖在所有页面之上（包括后来打开的页面、对话框与底部弹窗）
      builder: (context, child) => AppLockGate(child: child!),
    );
  }
}
