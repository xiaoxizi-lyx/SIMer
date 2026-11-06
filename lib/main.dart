import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'licenses.dart';
import 'providers/auth_provider.dart';
import 'providers/filter_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/sim_card_provider.dart';
import 'providers/theme_provider.dart';
import 'services/backup_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerBundledLicenses();
  // 清理上次分享导出时留在缓存中的明文备份
  unawaited(BackupService.purgeExportCache());

  final themeProvider = ThemeProvider();
  final authProvider = AuthProvider();
  final simCardProvider = SimCardProvider();
  final reminderProvider = ReminderProvider(cards: simCardProvider);
  // 卡片有任何变化（含首次加载）都重新预约提醒
  simCardProvider.onCardsChanged = reminderProvider.cardsChanged;

  // 各项初始化互不依赖，并行执行以缩短启动白屏时间；单项失败不影响启动
  await Future.wait([
    _guard('主题', themeProvider.loadTheme()),
    _guard('应用锁', authProvider.initialize()),
    _guard('通知', NotificationService.initialize()),
    _guard('提醒设置', reminderProvider.load()),
    _guard('数据', simCardProvider.loadAll()),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: simCardProvider),
        ChangeNotifierProvider.value(value: reminderProvider),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
      ],
      child: const SimerApp(),
    ),
  );
}

Future<void> _guard(String name, Future<void> task) async {
  try {
    await task;
  } on Exception catch (e, stack) {
    debugPrint('初始化$name失败: $e\n$stack');
  }
}
