import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import '../database/database_helper.dart';

/// 通知服务：SIM卡到期提醒
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'sim_keeper_expiry';
  static const String _channelName = 'SIM卡到期提醒';
  static const String _channelDescription = '当SIM卡即将到期或需要使用时发送提醒';
  static const String _taskName = 'sim_keeper_daily_check';
  static const String _taskUniqueName = 'com.simkeeper.dailyExpiryCheck';

  /// 初始化通知插件
  static Future<void> initialize() async {
    // Android 初始化设置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 初始化设置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 请求 Android 13+ 通知权限
    await _requestPermissions();
  }

  /// 请求通知权限
  static Future<void> _requestPermissions() async {
    // Android
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    // iOS
    final iosPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// 通知被点击时的回调
  static void _onNotificationTapped(NotificationResponse response) {
    // 后续接入页面导航：根据 payload 跳转到对应SIM卡详情
    // payload 格式: sim_card_id
  }

  /// 注册每日后台检查任务
  static Future<void> scheduleExpiryCheck() async {
    await Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false,
    );

    await Workmanager().registerPeriodicTask(
      _taskUniqueName,
      _taskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      initialDelay: const Duration(minutes: 5),
    );
  }

  /// 取消每日后台检查任务
  static Future<void> cancelExpiryCheck() async {
    await Workmanager().cancelByUniqueName(_taskUniqueName);
  }

  /// 检查所有卡片并发送需要提醒的通知
  static Future<void> checkAndNotify() async {
    final cardsNeedingReminder =
        await DatabaseHelper.instance.getSimCardsNeedingReminder();

    for (int i = 0; i < cardsNeedingReminder.length; i++) {
      final card = cardsNeedingReminder[i];
      final daysLeft = card.daysRemaining ?? 0;

      String title;
      String body;

      if (daysLeft <= 0) {
        title = '⚠️ SIM卡已过期';
        body = '${card.carrierName} 的SIM卡已过期，请及时处理';
      } else if (daysLeft == 1) {
        title = '🔴 SIM卡明天到期';
        body = '${card.carrierName} 的SIM卡将在明天到期';
      } else {
        title = '📱 SIM卡即将到期';
        body = '${card.carrierName} 的SIM卡将在 $daysLeft 天后到期';
      }

      // 滚动有效期的特殊提示
      if (card.validityType.name == 'rolling') {
        body += '，请尽快使用以续期';
      }

      await _showNotification(
        id: card.id ?? i,
        title: title,
        body: body,
        payload: '${card.id}',
      );
    }
  }

  /// 显示单条通知
  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// 清除所有通知
  static Future<void> clearAllNotifications() async {
    await _notifications.cancelAll();
  }
}

/// WorkManager 回调入口（必须是顶层函数）
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == 'sim_keeper_daily_check') {
      await NotificationService.checkAndNotify();
    }
    return true;
  });
}
