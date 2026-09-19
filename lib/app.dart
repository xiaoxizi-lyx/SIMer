import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';

/// SIM Keeper 主应用
class SimKeeperApp extends StatelessWidget {
  const SimKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, _) {
        return MaterialApp(
          title: 'SIMer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          home: _buildHome(authProvider),
        );
      },
    );
  }

  Widget _buildHome(AuthProvider authProvider) {
    // 如果启用了生物识别且未认证，显示锁屏
    if (authProvider.biometricEnabled && !authProvider.isAuthenticated) {
      return const LockScreen();
    }
    return const HomeScreen();
  }
}
