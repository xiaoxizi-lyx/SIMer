import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/sim_card.dart';
import 'reminder_planner.dart';

/// 到期提醒通知。
///
/// 不再依赖每天运行的后台任务（国产系统上常被延迟或杀掉），而是在卡片变化、
/// 设置变化与应用启动时，为每张卡片直接向系统预约一次性的提醒
/// （非精确闹钟，无需 SCHEDULE_EXACT_ALARM 权限；重启后由插件自动恢复）。
abstract final class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'simer_expiry_reminders';
  static const String _channelName = '到期提醒';
  static const String _channelDescription = 'SIM 卡即将到期、今天到期或已过期时提醒';

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
  );

  /// 用户点击通知后要打开的卡片 UUID；首页监听并展示卡片详情。
  static final ValueNotifier<String?> openCardRequest = ValueNotifier(null);

  static bool _initialized = false;

  static AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  static Future<void> initialize() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final uuid = response.payload;
        if (uuid != null && uuid.isNotEmpty) openCardRequest.value = uuid;
      },
    );
    _initialized = true;

    // 应用由点击通知冷启动时
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if ((launch?.didNotificationLaunchApp ?? false) &&
        payload != null &&
        payload.isNotEmpty) {
      openCardRequest.value = payload;
    }
  }

  /// 系统是否允许本应用发送通知。
  static Future<bool> areEnabled() async =>
      await _android?.areNotificationsEnabled() ?? false;

  /// 请求通知权限（Android 13+ 会弹出系统对话框）。返回是否已授权。
  static Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  /// 按当前卡片重新预约所有提醒：先取消尚未触发的旧提醒，已显示的通知保持不变。
  static Future<void> reschedule(
    Iterable<SimCard> cards, {
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) return;
    await _plugin.cancelAllPendingNotifications();
    if (!enabled) return;

    final plan = ReminderPlanner.plan(
      cards,
      now: DateTime.now(),
      hour: hour,
      minute: minute,
    );
    for (final reminder in plan) {
      try {
        await _plugin.zonedSchedule(
          id: reminder.id,
          title: reminder.title,
          body: reminder.body,
          // 以绝对时刻预约；时区变化后在下次启动时按新时区重新预约
          scheduledDate: tz.TZDateTime.from(reminder.fireAt, tz.UTC),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: reminder.cardUuid,
        );
      } on Exception catch (e) {
        debugPrint('预约提醒失败 ($reminder): $e');
      }
    }
  }
}
