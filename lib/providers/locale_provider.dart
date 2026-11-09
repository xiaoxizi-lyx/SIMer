import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// 界面语言设置。
enum AppLanguage {
  system,
  zh,
  en;

  /// 固定选择的语言；跟随系统时为 null。
  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.zh => const Locale('zh'),
    AppLanguage.en => const Locale('en'),
  };

  /// 语言选项中显示的名称：各语言用自己的文字书写，与当前界面语言无关。
  String? get nativeName => switch (this) {
    AppLanguage.system => null,
    AppLanguage.zh => '简体中文',
    AppLanguage.en => 'English',
  };

  static AppLanguage fromName(String? name) => AppLanguage.values.firstWhere(
    (l) => l.name == name,
    orElse: () => AppLanguage.system,
  );
}

/// 界面语言：跟随系统，或固定为简体中文 / English。
///
/// 跟随系统时：系统语言为中文（含繁体）显示简体中文，其他语言显示英文。
class LocaleProvider extends ChangeNotifier with WidgetsBindingObserver {
  LocaleProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const String _key = 'app_language';

  AppLanguage _language = AppLanguage.system;

  AppLanguage get language => _language;

  /// 传给 `MaterialApp.locale`；跟随系统时为 null。
  Locale? get locale => _language.locale;

  /// 实际使用的界面语言。
  Locale get effectiveLocale =>
      _language.locale ?? resolve(PlatformDispatcher.instance.locales);

  /// 当前界面语言的文案，用于没有 BuildContext 的地方（例如预约通知）。
  AppLocalizations get strings => lookupAppLocalizations(effectiveLocale);

  /// 按系统的语言偏好列表选出支持的语言（与 MaterialApp 的默认规则一致）。
  static Locale resolve(List<Locale> preferred) =>
      basicLocaleListResolution(preferred, AppLocalizations.supportedLocales);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = AppLanguage.fromName(prefs.getString(_key));
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.name);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // 跟随系统时，系统语言变化会改变界面语言（预约的通知文案也需要更新）
    if (_language == AppLanguage.system) notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
