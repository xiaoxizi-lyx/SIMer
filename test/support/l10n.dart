import 'package:flutter/material.dart';
import 'package:simer/l10n/app_localizations.dart';
import 'package:simer/services/auth_service.dart';

/// 中文与英文界面文案（不依赖 BuildContext）。
final AppLocalizations zh = lookupAppLocalizations(const Locale('zh'));
final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

/// 测试中传给身份验证的对话框文字。
const AuthPrompt testPrompt = AuthPrompt(
  title: 'title',
  reason: 'reason',
  cancel: 'cancel',
);

/// 带本地化的 MaterialApp；默认中文界面。
Widget localizedApp({
  required Widget home,
  Locale locale = const Locale('zh'),
}) => MaterialApp(
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: home,
);
