import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sim_card.dart';
import '../services/notification_service.dart';
import 'sim_card_provider.dart';

/// 到期提醒设置，并在卡片或设置变化后重新预约提醒。
class ReminderProvider extends ChangeNotifier {
  ReminderProvider({required this._cards});

  static const String _enabledKey = 'reminders_enabled';
  static const String _timeKey = 'reminder_time_minutes';
  static const String _askedKey = 'notification_permission_requested';

  final SimCardProvider _cards;

  bool _enabled = true;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _permissionGranted = true;
  Timer? _debounce;

  bool get enabled => _enabled;
  TimeOfDay get time => _time;

  /// 系统通知权限是否已授予（未授予时提醒不会显示）。
  bool get permissionGranted => _permissionGranted;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;
    final minutes = prefs.getInt(_timeKey) ?? 9 * 60;
    _time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    _permissionGranted = await NotificationService.areEnabled();
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    if (value) await requestPermission();
    cardsChanged();
  }

  Future<void> setTime(TimeOfDay value) async {
    if (_time == value) return;
    _time = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeKey, value.hour * 60 + value.minute);
    cardsChanged();
  }

  /// 请求通知权限并刷新状态。
  Future<void> requestPermission() async {
    _permissionGranted =
        await NotificationService.areEnabled() ||
        await NotificationService.requestPermission();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askedKey, true);
    notifyListeners();
  }

  /// 保存了带到期日的卡片后调用：首次需要时请求一次通知权限，不重复打扰。
  Future<void> onCardSaved(SimCard card) async {
    if (!_enabled || card.effectiveExpirationDate == null) return;
    if (await NotificationService.areEnabled()) {
      _permissionGranted = true;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_askedKey) ?? false) return;
    await requestPermission();
  }

  /// 卡片或设置变化后调用；短时间内的多次变化合并为一次重新预约。
  void cardsChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_reschedule());
    });
  }

  Future<void> _reschedule() => NotificationService.reschedule(
    _cards.simCards,
    enabled: _enabled,
    hour: _time.hour,
    minute: _time.minute,
  );

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
