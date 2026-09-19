import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/sim_card_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/filter_provider.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 初始化通知服务并调度每日到期后台检查
  await NotificationService.initialize();
  await NotificationService.scheduleExpiryCheck();

  // 初始化 providers
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final authProvider = AuthProvider();
  await authProvider.initialize();

  final simCardProvider = SimCardProvider();
  await simCardProvider.loadAll();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: simCardProvider),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
      ],
      child: const SimKeeperApp(),
    ),
  );
}
