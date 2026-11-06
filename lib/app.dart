import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'theme/app_theme.dart';

/// SIMer 主应用
class SimerApp extends StatelessWidget {
  const SimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 只在主题模式变化时重建 MaterialApp
    final themeMode = context.select<ThemeProvider, ThemeMode>(
      (p) => p.themeMode,
    );
    return MaterialApp(
      title: 'SIMer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // 界面文字为中文：系统组件（日期选择器、复制粘贴菜单等）也使用中文
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeScreen(),
      // 锁屏覆盖在所有页面之上（包括后来打开的页面、对话框与底部弹窗）
      builder: (context, child) => AppLockGate(child: child!),
    );
  }
}
