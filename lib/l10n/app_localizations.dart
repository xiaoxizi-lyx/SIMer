import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'SIMer'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get commonClose;

  /// No description provided for @commonCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get commonCopy;

  /// No description provided for @commonUndo.
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get commonUndo;

  /// No description provided for @commonRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get commonRetry;

  /// No description provided for @commonFollowSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get commonFollowSystem;

  /// No description provided for @commonNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get commonNotSet;

  /// No description provided for @simTypePhysical.
  ///
  /// In zh, this message translates to:
  /// **'实体SIM卡'**
  String get simTypePhysical;

  /// No description provided for @simTypeEsim.
  ///
  /// In zh, this message translates to:
  /// **'eSIM'**
  String get simTypeEsim;

  /// No description provided for @activationActive.
  ///
  /// In zh, this message translates to:
  /// **'激活'**
  String get activationActive;

  /// No description provided for @activationInactive.
  ///
  /// In zh, this message translates to:
  /// **'未激活'**
  String get activationInactive;

  /// No description provided for @validityUnlimited.
  ///
  /// In zh, this message translates to:
  /// **'无期限'**
  String get validityUnlimited;

  /// No description provided for @validityUnknown.
  ///
  /// In zh, this message translates to:
  /// **'未设定'**
  String get validityUnknown;

  /// No description provided for @validityValid.
  ///
  /// In zh, this message translates to:
  /// **'有效'**
  String get validityValid;

  /// No description provided for @validityExpiringSoon.
  ///
  /// In zh, this message translates to:
  /// **'即将到期'**
  String get validityExpiringSoon;

  /// No description provided for @validityExpired.
  ///
  /// In zh, this message translates to:
  /// **'已过期'**
  String get validityExpired;

  /// No description provided for @validityTypeFixedDate.
  ///
  /// In zh, this message translates to:
  /// **'固定到期日'**
  String get validityTypeFixedDate;

  /// No description provided for @validityTypeRolling.
  ///
  /// In zh, this message translates to:
  /// **'滚动有效期'**
  String get validityTypeRolling;

  /// No description provided for @validityTypeNoExpiration.
  ///
  /// In zh, this message translates to:
  /// **'无期限'**
  String get validityTypeNoExpiration;

  /// No description provided for @validityTypeFixedDateDesc.
  ///
  /// In zh, this message translates to:
  /// **'设定一个具体的到期日期，当天仍然有效'**
  String get validityTypeFixedDateDesc;

  /// No description provided for @validityTypeRollingDesc.
  ///
  /// In zh, this message translates to:
  /// **'每隔N天需使用一次，使用后自动续期'**
  String get validityTypeRollingDesc;

  /// No description provided for @validityTypeNoExpirationDesc.
  ///
  /// In zh, this message translates to:
  /// **'此SIM卡没有有效期限制'**
  String get validityTypeNoExpirationDesc;

  /// No description provided for @sortByCreatedAt.
  ///
  /// In zh, this message translates to:
  /// **'添加时间'**
  String get sortByCreatedAt;

  /// No description provided for @sortByExpirationDate.
  ///
  /// In zh, this message translates to:
  /// **'到期时间'**
  String get sortByExpirationDate;

  /// No description provided for @sortByCarrierName.
  ///
  /// In zh, this message translates to:
  /// **'运营商'**
  String get sortByCarrierName;

  /// No description provided for @sortByCountryCode.
  ///
  /// In zh, this message translates to:
  /// **'国家/地区'**
  String get sortByCountryCode;

  /// No description provided for @sortOrderAscending.
  ///
  /// In zh, this message translates to:
  /// **'升序'**
  String get sortOrderAscending;

  /// No description provided for @sortOrderDescending.
  ///
  /// In zh, this message translates to:
  /// **'降序'**
  String get sortOrderDescending;

  /// No description provided for @featureVoice.
  ///
  /// In zh, this message translates to:
  /// **'通话'**
  String get featureVoice;

  /// No description provided for @featureSms.
  ///
  /// In zh, this message translates to:
  /// **'短信'**
  String get featureSms;

  /// No description provided for @featureData.
  ///
  /// In zh, this message translates to:
  /// **'数据流量'**
  String get featureData;

  /// No description provided for @featureWifiCalling.
  ///
  /// In zh, this message translates to:
  /// **'Wi-Fi Calling'**
  String get featureWifiCalling;

  /// No description provided for @featureVolte.
  ///
  /// In zh, this message translates to:
  /// **'VoLTE'**
  String get featureVolte;

  /// No description provided for @featureHotspot.
  ///
  /// In zh, this message translates to:
  /// **'热点共享'**
  String get featureHotspot;

  /// No description provided for @featureEsimTransfer.
  ///
  /// In zh, this message translates to:
  /// **'eSIM转移'**
  String get featureEsimTransfer;

  /// No description provided for @featureIntlRoaming.
  ///
  /// In zh, this message translates to:
  /// **'国际漫游'**
  String get featureIntlRoaming;

  /// No description provided for @lockTimeoutImmediately.
  ///
  /// In zh, this message translates to:
  /// **'立即'**
  String get lockTimeoutImmediately;

  /// No description provided for @lockTimeoutSeconds30.
  ///
  /// In zh, this message translates to:
  /// **'30 秒后'**
  String get lockTimeoutSeconds30;

  /// No description provided for @lockTimeoutMinute1.
  ///
  /// In zh, this message translates to:
  /// **'1 分钟后'**
  String get lockTimeoutMinute1;

  /// No description provided for @lockTimeoutMinutes5.
  ///
  /// In zh, this message translates to:
  /// **'5 分钟后'**
  String get lockTimeoutMinutes5;

  /// No description provided for @authPromptTitle.
  ///
  /// In zh, this message translates to:
  /// **'验证身份'**
  String get authPromptTitle;

  /// No description provided for @authPromptReason.
  ///
  /// In zh, this message translates to:
  /// **'请验证身份以访问 SIMer'**
  String get authPromptReason;

  /// No description provided for @authNoticeLockDisabled.
  ///
  /// In zh, this message translates to:
  /// **'设备已不再设置锁屏密码或生物识别，应用锁已自动关闭'**
  String get authNoticeLockDisabled;

  /// No description provided for @authErrorLockedOut.
  ///
  /// In zh, this message translates to:
  /// **'尝试次数过多，请稍后再试或使用设备密码'**
  String get authErrorLockedOut;

  /// No description provided for @authErrorFailed.
  ///
  /// In zh, this message translates to:
  /// **'验证失败，请重试'**
  String get authErrorFailed;

  /// No description provided for @lockToggleNeedsDeviceLock.
  ///
  /// In zh, this message translates to:
  /// **'请先在系统设置中设置锁屏密码或生物识别'**
  String get lockToggleNeedsDeviceLock;

  /// No description provided for @lockToggleAuthFailed.
  ///
  /// In zh, this message translates to:
  /// **'身份验证失败'**
  String get lockToggleAuthFailed;

  /// No description provided for @countryPickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择国家/地区'**
  String get countryPickerTitle;

  /// No description provided for @countryPickerSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索国家/地区…'**
  String get countryPickerSearchHint;

  /// No description provided for @carrierPickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择运营商'**
  String get carrierPickerTitle;

  /// No description provided for @carrierPickerSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索运营商或国家，或输入自定义名称'**
  String get carrierPickerSearchHint;

  /// No description provided for @carrierPickerUseCustom.
  ///
  /// In zh, this message translates to:
  /// **'使用「{name}」作为自定义运营商'**
  String carrierPickerUseCustom(String name);

  /// No description provided for @carrierPickerEmpty.
  ///
  /// In zh, this message translates to:
  /// **'没有预置运营商'**
  String get carrierPickerEmpty;

  /// No description provided for @filterAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get filterAll;

  /// No description provided for @sortTooltip.
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get sortTooltip;

  /// Screen reader action hint ("double tap to ...").
  ///
  /// In zh, this message translates to:
  /// **'返回卡片正面'**
  String get cardFlipHintToFront;

  /// Screen reader action hint ("double tap to ...").
  ///
  /// In zh, this message translates to:
  /// **'查看卡片详情'**
  String get cardFlipHintToDetails;

  /// No description provided for @featureNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'备注（可选）'**
  String get featureNoteHint;

  /// No description provided for @cardDetailDeleted.
  ///
  /// In zh, this message translates to:
  /// **'这张卡片已被删除'**
  String get cardDetailDeleted;

  /// No description provided for @cardArchivedBadge.
  ///
  /// In zh, this message translates to:
  /// **'已归档'**
  String get cardArchivedBadge;

  /// No description provided for @cardMarkUsed.
  ///
  /// In zh, this message translates to:
  /// **'我已使用'**
  String get cardMarkUsed;

  /// No description provided for @countdownExpiredDays.
  ///
  /// In zh, this message translates to:
  /// **'已过期 {days} 天'**
  String countdownExpiredDays(int days);

  /// No description provided for @countdownDaysLeft.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {days} 天'**
  String countdownDaysLeft(int days);

  /// No description provided for @countdownDueToday.
  ///
  /// In zh, this message translates to:
  /// **'今天到期'**
  String get countdownDueToday;

  /// Appended after the countdown for rolling-validity cards.
  ///
  /// In zh, this message translates to:
  /// **'{days}天一用'**
  String countdownRollingCycle(int days);

  /// No description provided for @colorPickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择卡片颜色'**
  String get colorPickerTitle;

  /// No description provided for @colorPickerCarrierSuggested.
  ///
  /// In zh, this message translates to:
  /// **'{carrier}推荐'**
  String colorPickerCarrierSuggested(String carrier);

  /// No description provided for @colorPickerCarrierSuggestedGeneric.
  ///
  /// In zh, this message translates to:
  /// **'运营商推荐'**
  String get colorPickerCarrierSuggestedGeneric;

  /// No description provided for @colorPickerPresets.
  ///
  /// In zh, this message translates to:
  /// **'预设颜色'**
  String get colorPickerPresets;

  /// No description provided for @colorPickerCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义颜色'**
  String get colorPickerCustom;

  /// No description provided for @lockScreenTitle.
  ///
  /// In zh, this message translates to:
  /// **'SIMer 已锁定'**
  String get lockScreenTitle;

  /// No description provided for @lockScreenPrompt.
  ///
  /// In zh, this message translates to:
  /// **'请验证身份后继续'**
  String get lockScreenPrompt;

  /// No description provided for @lockScreenUnlock.
  ///
  /// In zh, this message translates to:
  /// **'解锁'**
  String get lockScreenUnlock;

  /// No description provided for @backSectionBasic.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get backSectionBasic;

  /// No description provided for @fieldCarrier.
  ///
  /// In zh, this message translates to:
  /// **'运营商'**
  String get fieldCarrier;

  /// No description provided for @fieldCountry.
  ///
  /// In zh, this message translates to:
  /// **'国家/地区'**
  String get fieldCountry;

  /// No description provided for @fieldPrimaryNumber.
  ///
  /// In zh, this message translates to:
  /// **'主号码'**
  String get fieldPrimaryNumber;

  /// No description provided for @fieldNumberN.
  ///
  /// In zh, this message translates to:
  /// **'号码{index}'**
  String fieldNumberN(int index);

  /// No description provided for @fieldSimType.
  ///
  /// In zh, this message translates to:
  /// **'SIM类型'**
  String get fieldSimType;

  /// No description provided for @backSectionValidity.
  ///
  /// In zh, this message translates to:
  /// **'有效期'**
  String get backSectionValidity;

  /// No description provided for @fieldValidityType.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get fieldValidityType;

  /// No description provided for @fieldActivationDate.
  ///
  /// In zh, this message translates to:
  /// **'激活日期'**
  String get fieldActivationDate;

  /// No description provided for @fieldExpirationDate.
  ///
  /// In zh, this message translates to:
  /// **'到期日期'**
  String get fieldExpirationDate;

  /// No description provided for @fieldRollingCycle.
  ///
  /// In zh, this message translates to:
  /// **'滚动周期'**
  String get fieldRollingCycle;

  /// No description provided for @fieldLastUsed.
  ///
  /// In zh, this message translates to:
  /// **'上次使用'**
  String get fieldLastUsed;

  /// No description provided for @daysCount.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天'**
  String daysCount(int days);

  /// No description provided for @backSectionUsage.
  ///
  /// In zh, this message translates to:
  /// **'用量'**
  String get backSectionUsage;

  /// No description provided for @backSectionFeatures.
  ///
  /// In zh, this message translates to:
  /// **'功能支持'**
  String get backSectionFeatures;

  /// No description provided for @backSectionEsim.
  ///
  /// In zh, this message translates to:
  /// **'eSIM信息'**
  String get backSectionEsim;

  /// The Matching ID (AC_Token) stored for an eSIM.
  ///
  /// In zh, this message translates to:
  /// **'激活码'**
  String get fieldMatchingId;

  /// No description provided for @fieldConfirmationCode.
  ///
  /// In zh, this message translates to:
  /// **'确认码'**
  String get fieldConfirmationCode;

  /// No description provided for @backSectionOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get backSectionOther;

  /// No description provided for @fieldSource.
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get fieldSource;

  /// No description provided for @fieldNotes.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get fieldNotes;

  /// No description provided for @copiedField.
  ///
  /// In zh, this message translates to:
  /// **'已复制 {field}'**
  String copiedField(String field);

  /// No description provided for @usageData.
  ///
  /// In zh, this message translates to:
  /// **'流量'**
  String get usageData;

  /// No description provided for @usageVoice.
  ///
  /// In zh, this message translates to:
  /// **'通话'**
  String get usageVoice;

  /// No description provided for @usageSms.
  ///
  /// In zh, this message translates to:
  /// **'短信'**
  String get usageSms;

  /// No description provided for @usageBalance.
  ///
  /// In zh, this message translates to:
  /// **'余额'**
  String get usageBalance;

  /// No description provided for @usageRemaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {amount}'**
  String usageRemaining(String amount);

  /// No description provided for @usageTotal.
  ///
  /// In zh, this message translates to:
  /// **'总量 {amount}'**
  String usageTotal(String amount);

  /// No description provided for @usageMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{amount} 分钟'**
  String usageMinutes(String amount);

  /// No description provided for @usageMessages.
  ///
  /// In zh, this message translates to:
  /// **'{amount} 条'**
  String usageMessages(String amount);

  /// No description provided for @cardArchive.
  ///
  /// In zh, this message translates to:
  /// **'归档'**
  String get cardArchive;

  /// No description provided for @cardUnarchive.
  ///
  /// In zh, this message translates to:
  /// **'取消归档'**
  String get cardUnarchive;

  /// No description provided for @actionFailed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败，请重试'**
  String get actionFailed;

  /// No description provided for @markUsedDone.
  ///
  /// In zh, this message translates to:
  /// **'已记录今天使用'**
  String get markUsedDone;

  /// No description provided for @markUsedDoneExtended.
  ///
  /// In zh, this message translates to:
  /// **'已记录今天使用，有效期顺延至 {date}'**
  String markUsedDoneExtended(String date);

  /// No description provided for @archiveDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'归档SIM卡'**
  String get archiveDialogTitle;

  /// No description provided for @archiveDialogMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要将 {carrier} 的SIM卡归档吗？归档后可在「设置 → 归档」中恢复。'**
  String archiveDialogMessage(String carrier);

  /// No description provided for @archiveFailed.
  ///
  /// In zh, this message translates to:
  /// **'归档失败，请重试'**
  String get archiveFailed;

  /// No description provided for @archiveDone.
  ///
  /// In zh, this message translates to:
  /// **'已归档 {carrier}'**
  String archiveDone(String carrier);

  /// No description provided for @archiveTitle.
  ///
  /// In zh, this message translates to:
  /// **'归档'**
  String get archiveTitle;

  /// No description provided for @archiveEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'没有已归档的SIM卡'**
  String get archiveEmptyTitle;

  /// No description provided for @archiveEmptySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'已归档的SIM卡会显示在这里'**
  String get archiveEmptySubtitle;

  /// No description provided for @archiveRestore.
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get archiveRestore;

  /// No description provided for @archiveRestored.
  ///
  /// In zh, this message translates to:
  /// **'已恢复 {carrier}'**
  String archiveRestored(String carrier);

  /// No description provided for @archiveRestoreFailed.
  ///
  /// In zh, this message translates to:
  /// **'恢复失败，请重试'**
  String get archiveRestoreFailed;

  /// No description provided for @archiveDeleteForever.
  ///
  /// In zh, this message translates to:
  /// **'永久删除'**
  String get archiveDeleteForever;

  /// No description provided for @archiveDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要永久删除 {carrier} 的SIM卡吗？\n\n此操作不可恢复。'**
  String archiveDeleteMessage(String carrier);

  /// No description provided for @archiveDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已永久删除 {carrier}'**
  String archiveDeleted(String carrier);

  /// No description provided for @archiveDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败，请重试'**
  String get archiveDeleteFailed;

  /// No description provided for @tagsTitle.
  ///
  /// In zh, this message translates to:
  /// **'标签管理'**
  String get tagsTitle;

  /// No description provided for @tagsAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加标签'**
  String get tagsAdd;

  /// No description provided for @tagsEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有标签'**
  String get tagsEmptyTitle;

  /// No description provided for @tagsEmptySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'点击右上角添加你的第一个标签'**
  String get tagsEmptySubtitle;

  /// No description provided for @tagsUsage.
  ///
  /// In zh, this message translates to:
  /// **'已关联 {count} 张SIM卡'**
  String tagsUsage(int count);

  /// No description provided for @tagsEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑标签'**
  String get tagsEdit;

  /// No description provided for @tagsNameHint.
  ///
  /// In zh, this message translates to:
  /// **'标签名称'**
  String get tagsNameHint;

  /// No description provided for @tagsColor.
  ///
  /// In zh, this message translates to:
  /// **'标签颜色'**
  String get tagsColor;

  /// No description provided for @tagsNameTaken.
  ///
  /// In zh, this message translates to:
  /// **'已有名为「{name}」的标签'**
  String tagsNameTaken(String name);

  /// No description provided for @commonAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get commonAdd;

  /// No description provided for @tagsSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存标签失败，请重试'**
  String get tagsSaveFailed;

  /// No description provided for @tagsDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除标签'**
  String get tagsDeleteTitle;

  /// No description provided for @tagsDeleteInUse.
  ///
  /// In zh, this message translates to:
  /// **'标签\"{name}\"已被 {count} 张SIM卡使用。删除后将从这些卡中移除该标签。确定要删除吗？'**
  String tagsDeleteInUse(String name, int count);

  /// No description provided for @tagsDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除标签\"{name}\"吗？'**
  String tagsDeleteConfirm(String name);

  /// No description provided for @homeSearchClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭搜索'**
  String get homeSearchClose;

  /// No description provided for @homeSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索运营商、号码、国家、标签…'**
  String get homeSearchHint;

  /// No description provided for @homeSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get homeSearch;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @homeEmptyFiltered.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的SIM卡'**
  String get homeEmptyFiltered;

  /// No description provided for @homeEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有SIM卡记录'**
  String get homeEmpty;

  /// No description provided for @homeEmptyFilteredHint.
  ///
  /// In zh, this message translates to:
  /// **'试试调整筛选条件'**
  String get homeEmptyFilteredHint;

  /// No description provided for @homeEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'点击下方按钮添加你的第一张SIM卡'**
  String get homeEmptyHint;

  /// No description provided for @homeClearFilters.
  ///
  /// In zh, this message translates to:
  /// **'清除筛选'**
  String get homeClearFilters;

  /// No description provided for @homeAddCard.
  ///
  /// In zh, this message translates to:
  /// **'添加SIM/eSIM信息'**
  String get homeAddCard;

  /// No description provided for @settingsSectionTheme.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get settingsSectionTheme;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// Kept bilingual so the setting can be found after switching to an unfamiliar language.
  ///
  /// In zh, this message translates to:
  /// **'语言 / Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsAppLock.
  ///
  /// In zh, this message translates to:
  /// **'应用锁'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockOn.
  ///
  /// In zh, this message translates to:
  /// **'打开应用时验证指纹、面容或设备密码'**
  String get settingsAppLockOn;

  /// No description provided for @settingsAppLockNeedsDeviceLock.
  ///
  /// In zh, this message translates to:
  /// **'需要先在系统设置中设置锁屏密码'**
  String get settingsAppLockNeedsDeviceLock;

  /// No description provided for @settingsAutoLock.
  ///
  /// In zh, this message translates to:
  /// **'自动锁定'**
  String get settingsAutoLock;

  /// No description provided for @settingsAutoLockSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'离开应用多久后需要重新验证'**
  String get settingsAutoLockSubtitle;

  /// No description provided for @autoLockOptionImmediately.
  ///
  /// In zh, this message translates to:
  /// **'离开应用后立即'**
  String get autoLockOptionImmediately;

  /// No description provided for @autoLockOptionSeconds30.
  ///
  /// In zh, this message translates to:
  /// **'离开应用 30 秒后'**
  String get autoLockOptionSeconds30;

  /// No description provided for @autoLockOptionMinute1.
  ///
  /// In zh, this message translates to:
  /// **'离开应用 1 分钟后'**
  String get autoLockOptionMinute1;

  /// No description provided for @autoLockOptionMinutes5.
  ///
  /// In zh, this message translates to:
  /// **'离开应用 5 分钟后'**
  String get autoLockOptionMinutes5;

  /// No description provided for @settingsPrivacyScreen.
  ///
  /// In zh, this message translates to:
  /// **'防窥保护'**
  String get settingsPrivacyScreen;

  /// No description provided for @settingsPrivacyScreenSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在「最近任务」中隐藏应用内容；Android 12 及以下会同时禁止截屏'**
  String get settingsPrivacyScreenSubtitle;

  /// No description provided for @settingsSectionReminders.
  ///
  /// In zh, this message translates to:
  /// **'提醒'**
  String get settingsSectionReminders;

  /// No description provided for @settingsExpiryReminders.
  ///
  /// In zh, this message translates to:
  /// **'到期提醒'**
  String get settingsExpiryReminders;

  /// No description provided for @settingsExpiryRemindersSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在卡片提前提醒日、到期当天与过期次日各提醒一次'**
  String get settingsExpiryRemindersSubtitle;

  /// No description provided for @settingsReminderTime.
  ///
  /// In zh, this message translates to:
  /// **'提醒时间'**
  String get settingsReminderTime;

  /// No description provided for @settingsNotificationsOff.
  ///
  /// In zh, this message translates to:
  /// **'通知权限未开启'**
  String get settingsNotificationsOff;

  /// No description provided for @settingsNotificationsOffSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'未开启时提醒不会显示，点击授权'**
  String get settingsNotificationsOffSubtitle;

  /// No description provided for @settingsSectionData.
  ///
  /// In zh, this message translates to:
  /// **'数据'**
  String get settingsSectionData;

  /// No description provided for @settingsExport.
  ///
  /// In zh, this message translates to:
  /// **'导出备份'**
  String get settingsExport;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'手动导出全部数据，用于迁移到新设备'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsImport.
  ///
  /// In zh, this message translates to:
  /// **'导入备份'**
  String get settingsImport;

  /// No description provided for @settingsImportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'从 SIMer 备份文件恢复数据'**
  String get settingsImportSubtitle;

  /// No description provided for @settingsSectionManage.
  ///
  /// In zh, this message translates to:
  /// **'管理'**
  String get settingsSectionManage;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsSectionAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsAboutDescription.
  ///
  /// In zh, this message translates to:
  /// **'SIM卡信息记录管理，安全存储你的SIM卡与eSIM信息。'**
  String get settingsAboutDescription;

  /// No description provided for @settingsLicenses.
  ///
  /// In zh, this message translates to:
  /// **'开源许可'**
  String get settingsLicenses;

  /// No description provided for @exportIntro.
  ///
  /// In zh, this message translates to:
  /// **'备份包含全部 SIM 卡与标签数据，其中有 ICCID、电话号码、eSIM 激活码与确认码等敏感信息。'**
  String get exportIntro;

  /// No description provided for @exportEncrypt.
  ///
  /// In zh, this message translates to:
  /// **'加密备份（推荐）'**
  String get exportEncrypt;

  /// No description provided for @exportPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get exportPassword;

  /// No description provided for @exportPasswordConfirm.
  ///
  /// In zh, this message translates to:
  /// **'再次输入密码'**
  String get exportPasswordConfirm;

  /// No description provided for @exportPasswordTooShort.
  ///
  /// In zh, this message translates to:
  /// **'密码至少 {min} 位'**
  String exportPasswordTooShort(int min);

  /// No description provided for @exportPasswordMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入的密码不一致'**
  String get exportPasswordMismatch;

  /// No description provided for @exportPasswordWarning.
  ///
  /// In zh, this message translates to:
  /// **'请牢记密码：忘记密码将无法恢复这份备份。'**
  String get exportPasswordWarning;

  /// No description provided for @exportPlainWarning.
  ///
  /// In zh, this message translates to:
  /// **'未加密的备份是明文 JSON 文件。请只保存到你信任的位置，或直接发送到你自己的新设备，导入完成后及时删除。'**
  String get exportPlainWarning;

  /// No description provided for @exportShare.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get exportShare;

  /// No description provided for @exportSaveToFile.
  ///
  /// In zh, this message translates to:
  /// **'保存到文件'**
  String get exportSaveToFile;

  /// No description provided for @exportEncrypting.
  ///
  /// In zh, this message translates to:
  /// **'正在加密…'**
  String get exportEncrypting;

  /// No description provided for @exportSaveDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'保存 SIMer 备份'**
  String get exportSaveDialogTitle;

  /// No description provided for @exportShareSubject.
  ///
  /// In zh, this message translates to:
  /// **'SIMer 数据备份'**
  String get exportShareSubject;

  /// No description provided for @exportSaved.
  ///
  /// In zh, this message translates to:
  /// **'备份已保存'**
  String get exportSaved;

  /// No description provided for @exportSaveCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消保存'**
  String get exportSaveCancelled;

  /// No description provided for @exportShared.
  ///
  /// In zh, this message translates to:
  /// **'备份已分享'**
  String get exportShared;

  /// No description provided for @exportShareCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消分享'**
  String get exportShareCancelled;

  /// No description provided for @exportShareOpened.
  ///
  /// In zh, this message translates to:
  /// **'已打开分享面板'**
  String get exportShareOpened;

  /// No description provided for @exportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败，请重试'**
  String get exportFailed;

  /// No description provided for @importPasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'输入备份密码'**
  String get importPasswordTitle;

  /// No description provided for @importPasswordMessage.
  ///
  /// In zh, this message translates to:
  /// **'这份备份已加密，请输入导出时设置的密码。'**
  String get importPasswordMessage;

  /// No description provided for @importDecrypt.
  ///
  /// In zh, this message translates to:
  /// **'解密'**
  String get importDecrypt;

  /// No description provided for @importDecrypting.
  ///
  /// In zh, this message translates to:
  /// **'正在解密…'**
  String get importDecrypting;

  /// No description provided for @importFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败，现有数据未做任何修改'**
  String get importFailed;

  /// No description provided for @importDoneTitle.
  ///
  /// In zh, this message translates to:
  /// **'导入完成'**
  String get importDoneTitle;

  /// No description provided for @importSkippedRecords.
  ///
  /// In zh, this message translates to:
  /// **'以下记录无法解析，已跳过：'**
  String get importSkippedRecords;

  /// No description provided for @commonGotIt.
  ///
  /// In zh, this message translates to:
  /// **'知道了'**
  String get commonGotIt;

  /// No description provided for @importSummary.
  ///
  /// In zh, this message translates to:
  /// **'导入完成：{details}'**
  String importSummary(String details);

  /// Separator between items of an inline list.
  ///
  /// In zh, this message translates to:
  /// **'，'**
  String get listSeparator;

  /// No description provided for @importSummaryCards.
  ///
  /// In zh, this message translates to:
  /// **'新增 {count} 张卡片'**
  String importSummaryCards(int count);

  /// No description provided for @importSummaryOverwritten.
  ///
  /// In zh, this message translates to:
  /// **'覆盖 {count} 张'**
  String importSummaryOverwritten(int count);

  /// No description provided for @importSummarySkipped.
  ///
  /// In zh, this message translates to:
  /// **'跳过 {count} 张重复卡片'**
  String importSummarySkipped(int count);

  /// No description provided for @importSummaryTags.
  ///
  /// In zh, this message translates to:
  /// **'新增 {count} 个标签'**
  String importSummaryTags(int count);

  /// No description provided for @importSummaryFailed.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条记录无法解析'**
  String importSummaryFailed(int count);

  /// No description provided for @importExportedAt.
  ///
  /// In zh, this message translates to:
  /// **'导出时间：{time}'**
  String importExportedAt(String time);

  /// No description provided for @importCards.
  ///
  /// In zh, this message translates to:
  /// **'卡片：{count} 张'**
  String importCards(int count);

  /// No description provided for @importDuplicates.
  ///
  /// In zh, this message translates to:
  /// **'其中 {count} 张与本机已有卡片相同（UUID 一致）'**
  String importDuplicates(int count);

  /// No description provided for @importTags.
  ///
  /// In zh, this message translates to:
  /// **'标签：{count} 个（同名标签会自动合并）'**
  String importTags(int count);

  /// No description provided for @importLegacy.
  ///
  /// In zh, this message translates to:
  /// **'此备份来自 SIMer 1.0，导入时会自动转换格式。'**
  String get importLegacy;

  /// No description provided for @importWasEncrypted.
  ///
  /// In zh, this message translates to:
  /// **'这是一份加密备份，已用你输入的密码解密。'**
  String get importWasEncrypted;

  /// No description provided for @importUnreadableRecords.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条记录无法解析，将被跳过：'**
  String importUnreadableRecords(int count);

  /// No description provided for @importMoreErrors.
  ///
  /// In zh, this message translates to:
  /// **'…等共 {count} 条'**
  String importMoreErrors(int count);

  /// No description provided for @importNothing.
  ///
  /// In zh, this message translates to:
  /// **'备份中没有可导入的数据。'**
  String get importNothing;

  /// No description provided for @importOverwrite.
  ///
  /// In zh, this message translates to:
  /// **'覆盖重复'**
  String get importOverwrite;

  /// No description provided for @importSkip.
  ///
  /// In zh, this message translates to:
  /// **'跳过重复'**
  String get importSkip;

  /// No description provided for @importButton.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get importButton;

  /// No description provided for @recordErrorCard.
  ///
  /// In zh, this message translates to:
  /// **'第 {index} 张卡片：{detail}'**
  String recordErrorCard(int index, String detail);

  /// No description provided for @recordErrorTag.
  ///
  /// In zh, this message translates to:
  /// **'第 {index} 个标签：{detail}'**
  String recordErrorTag(int index, String detail);

  /// No description provided for @fieldErrorMissing.
  ///
  /// In zh, this message translates to:
  /// **'缺少字段 \"{field}\"'**
  String fieldErrorMissing(String field);

  /// No description provided for @fieldErrorNotText.
  ///
  /// In zh, this message translates to:
  /// **'字段 \"{field}\" 应为文本'**
  String fieldErrorNotText(String field);

  /// No description provided for @fieldErrorNotInteger.
  ///
  /// In zh, this message translates to:
  /// **'字段 \"{field}\" 应为整数'**
  String fieldErrorNotInteger(String field);

  /// No description provided for @fieldErrorNotNumber.
  ///
  /// In zh, this message translates to:
  /// **'字段 \"{field}\" 应为数字'**
  String fieldErrorNotNumber(String field);

  /// No description provided for @fieldErrorNotBoolean.
  ///
  /// In zh, this message translates to:
  /// **'字段 \"{field}\" 应为布尔值'**
  String fieldErrorNotBoolean(String field);

  /// No description provided for @fieldErrorInvalidDate.
  ///
  /// In zh, this message translates to:
  /// **'字段 \"{field}\" 不是有效的日期'**
  String fieldErrorInvalidDate(String field);

  /// No description provided for @fieldErrorNotObject.
  ///
  /// In zh, this message translates to:
  /// **'字段 \"{field}\" 应为对象'**
  String fieldErrorNotObject(String field);

  /// No description provided for @fieldErrorNotTextList.
  ///
  /// In zh, this message translates to:
  /// **'字段 \"{field}\" 应为文本列表'**
  String fieldErrorNotTextList(String field);

  /// No description provided for @fieldErrorNotIntegerList.
  ///
  /// In zh, this message translates to:
  /// **'字段 \"{field}\" 应为整数列表'**
  String fieldErrorNotIntegerList(String field);

  /// No description provided for @recordErrorInvalid.
  ///
  /// In zh, this message translates to:
  /// **'记录格式错误'**
  String get recordErrorInvalid;

  /// No description provided for @backupErrorFileTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'文件过大（超过 10 MB），不是有效的 SIMer 备份'**
  String get backupErrorFileTooLarge;

  /// No description provided for @backupErrorNotUtf8.
  ///
  /// In zh, this message translates to:
  /// **'文件编码不是 UTF-8，不是有效的 SIMer 备份'**
  String get backupErrorNotUtf8;

  /// No description provided for @backupErrorUnreadable.
  ///
  /// In zh, this message translates to:
  /// **'无法读取所选文件'**
  String get backupErrorUnreadable;

  /// No description provided for @backupErrorNotJson.
  ///
  /// In zh, this message translates to:
  /// **'文件不是有效的 JSON，可能不是 SIMer 备份文件'**
  String get backupErrorNotJson;

  /// No description provided for @backupErrorUnrecognized.
  ///
  /// In zh, this message translates to:
  /// **'无法识别的备份文件'**
  String get backupErrorUnrecognized;

  /// No description provided for @backupErrorNewerVersion.
  ///
  /// In zh, this message translates to:
  /// **'该备份由更新版本的 SIMer 导出，请先升级应用后再导入'**
  String get backupErrorNewerVersion;

  /// No description provided for @backupErrorUnsupportedVersion.
  ///
  /// In zh, this message translates to:
  /// **'无法识别的备份格式版本'**
  String get backupErrorUnsupportedVersion;

  /// No description provided for @backupErrorMissingVersion.
  ///
  /// In zh, this message translates to:
  /// **'无法识别的备份文件（缺少格式版本信息）'**
  String get backupErrorMissingVersion;

  /// No description provided for @backupErrorCorrupted.
  ///
  /// In zh, this message translates to:
  /// **'备份文件已损坏'**
  String get backupErrorCorrupted;

  /// No description provided for @backupErrorWrongPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码不正确，或文件已损坏'**
  String get backupErrorWrongPassword;

  /// No description provided for @backupErrorUnsupportedEncryption.
  ///
  /// In zh, this message translates to:
  /// **'这份加密备份使用了当前版本不支持的加密方式，请先升级应用'**
  String get backupErrorUnsupportedEncryption;

  /// No description provided for @qrErrorEmpty.
  ///
  /// In zh, this message translates to:
  /// **'内容为空'**
  String get qrErrorEmpty;

  /// No description provided for @qrErrorNotActivationCode.
  ///
  /// In zh, this message translates to:
  /// **'不是 eSIM 激活码（应以 LPA:1\$ 开头）'**
  String get qrErrorNotActivationCode;

  /// No description provided for @qrErrorUnsupportedFormat.
  ///
  /// In zh, this message translates to:
  /// **'不支持的激活码格式版本「{version}」'**
  String qrErrorUnsupportedFormat(String version);

  /// No description provided for @qrErrorIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'激活码不完整，缺少 SM-DP+ 地址或匹配 ID'**
  String get qrErrorIncomplete;

  /// No description provided for @qrErrorEmptySmdp.
  ///
  /// In zh, this message translates to:
  /// **'SM-DP+ 地址为空'**
  String get qrErrorEmptySmdp;

  /// No description provided for @qrErrorInvalidSmdp.
  ///
  /// In zh, this message translates to:
  /// **'SM-DP+ 地址格式不正确：{address}'**
  String qrErrorInvalidSmdp(String address);

  /// No description provided for @qrErrorEmptyMatchingId.
  ///
  /// In zh, this message translates to:
  /// **'匹配 ID 为空'**
  String get qrErrorEmptyMatchingId;

  /// No description provided for @scanHint.
  ///
  /// In zh, this message translates to:
  /// **'将 eSIM 二维码放入框内'**
  String get scanHint;

  /// No description provided for @scanTitle.
  ///
  /// In zh, this message translates to:
  /// **'扫描 eSIM 二维码'**
  String get scanTitle;

  /// No description provided for @scanTorch.
  ///
  /// In zh, this message translates to:
  /// **'闪光灯'**
  String get scanTorch;

  /// No description provided for @scanFromImage.
  ///
  /// In zh, this message translates to:
  /// **'相册识别'**
  String get scanFromImage;

  /// No description provided for @scanPaste.
  ///
  /// In zh, this message translates to:
  /// **'粘贴激活码'**
  String get scanPaste;

  /// No description provided for @scanSwitchCamera.
  ///
  /// In zh, this message translates to:
  /// **'切换镜头'**
  String get scanSwitchCamera;

  /// No description provided for @scanPermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'需要相机权限才能扫描二维码'**
  String get scanPermissionDenied;

  /// No description provided for @scanCameraUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'相机无法启动'**
  String get scanCameraUnavailable;

  /// No description provided for @scanAlternatives.
  ///
  /// In zh, this message translates to:
  /// **'也可以使用下方的「相册识别」或「粘贴激活码」。'**
  String get scanAlternatives;

  /// No description provided for @scanOpenSettings.
  ///
  /// In zh, this message translates to:
  /// **'去设置开启相机权限'**
  String get scanOpenSettings;

  /// No description provided for @scanNoQrInImage.
  ///
  /// In zh, this message translates to:
  /// **'图片中没有识别到二维码'**
  String get scanNoQrInImage;

  /// No description provided for @scanImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法识别这张图片'**
  String get scanImageFailed;

  /// No description provided for @scanClipboardEmpty.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板中没有文本'**
  String get scanClipboardEmpty;

  /// No description provided for @scanResultTitle.
  ///
  /// In zh, this message translates to:
  /// **'识别到 eSIM 激活码'**
  String get scanResultTitle;

  /// No description provided for @fieldSmdpAddress.
  ///
  /// In zh, this message translates to:
  /// **'SM-DP+ 地址'**
  String get fieldSmdpAddress;

  /// No description provided for @scanResultMatchingId.
  ///
  /// In zh, this message translates to:
  /// **'激活码（匹配 ID）'**
  String get scanResultMatchingId;

  /// No description provided for @scanNeedsConfirmationCode.
  ///
  /// In zh, this message translates to:
  /// **'此 eSIM 安装时需要确认码。确认码不包含在二维码中，请向运营商获取后在表单中填写。'**
  String get scanNeedsConfirmationCode;

  /// No description provided for @scanAgain.
  ///
  /// In zh, this message translates to:
  /// **'重新扫描'**
  String get scanAgain;

  /// No description provided for @scanUseResult.
  ///
  /// In zh, this message translates to:
  /// **'使用此信息'**
  String get scanUseResult;

  /// No description provided for @formErrorIccid.
  ///
  /// In zh, this message translates to:
  /// **'ICCID 应为 18-22 位数字'**
  String get formErrorIccid;

  /// No description provided for @formErrorNumber.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的数字'**
  String get formErrorNumber;

  /// No description provided for @formErrorNegative.
  ///
  /// In zh, this message translates to:
  /// **'不能为负数'**
  String get formErrorNegative;

  /// No description provided for @formErrorInteger.
  ///
  /// In zh, this message translates to:
  /// **'请输入整数'**
  String get formErrorInteger;

  /// No description provided for @formErrorDaysRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入天数'**
  String get formErrorDaysRequired;

  /// No description provided for @formErrorDaysInteger.
  ///
  /// In zh, this message translates to:
  /// **'请输入整数天数'**
  String get formErrorDaysInteger;

  /// No description provided for @formErrorDaysRange.
  ///
  /// In zh, this message translates to:
  /// **'天数应在 {min}-{max} 之间'**
  String formErrorDaysRange(int min, int max);

  /// No description provided for @formErrorDateInFuture.
  ///
  /// In zh, this message translates to:
  /// **'不能晚于今天'**
  String get formErrorDateInFuture;

  /// No description provided for @formErrorExpirationRequired.
  ///
  /// In zh, this message translates to:
  /// **'请选择到期日期'**
  String get formErrorExpirationRequired;

  /// No description provided for @formSectionUsage.
  ///
  /// In zh, this message translates to:
  /// **'用量记录'**
  String get formSectionUsage;

  /// No description provided for @formSectionEsim.
  ///
  /// In zh, this message translates to:
  /// **'eSIM 信息'**
  String get formSectionEsim;

  /// No description provided for @formSectionAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观与分类'**
  String get formSectionAppearance;

  /// No description provided for @formSectionHasErrors.
  ///
  /// In zh, this message translates to:
  /// **'此分区有需要修改的内容'**
  String get formSectionHasErrors;

  /// No description provided for @formClearDate.
  ///
  /// In zh, this message translates to:
  /// **'清除日期'**
  String get formClearDate;

  /// No description provided for @formEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑SIM卡'**
  String get formEditTitle;

  /// No description provided for @formAddTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加SIM/eSIM信息'**
  String get formAddTitle;

  /// No description provided for @formCheckErrors.
  ///
  /// In zh, this message translates to:
  /// **'请检查标红的内容'**
  String get formCheckErrors;

  /// No description provided for @formSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，请重试'**
  String get formSaveFailed;

  /// No description provided for @formDiscardTitle.
  ///
  /// In zh, this message translates to:
  /// **'放弃未保存的修改？'**
  String get formDiscardTitle;

  /// No description provided for @formDiscardMessage.
  ///
  /// In zh, this message translates to:
  /// **'离开后，本次填写的内容不会保存。'**
  String get formDiscardMessage;

  /// No description provided for @formKeepEditing.
  ///
  /// In zh, this message translates to:
  /// **'继续编辑'**
  String get formKeepEditing;

  /// No description provided for @formDiscard.
  ///
  /// In zh, this message translates to:
  /// **'放弃'**
  String get formDiscard;

  /// No description provided for @formSimType.
  ///
  /// In zh, this message translates to:
  /// **'SIM 卡类型'**
  String get formSimType;

  /// No description provided for @formActivationStatus.
  ///
  /// In zh, this message translates to:
  /// **'激活状态'**
  String get formActivationStatus;

  /// No description provided for @formCarrierHint.
  ///
  /// In zh, this message translates to:
  /// **'选择或输入运营商'**
  String get formCarrierHint;

  /// No description provided for @formCarrierRequired.
  ///
  /// In zh, this message translates to:
  /// **'请选择或输入运营商'**
  String get formCarrierRequired;

  /// No description provided for @formIccidHint.
  ///
  /// In zh, this message translates to:
  /// **'18-22 位数字，可含空格'**
  String get formIccidHint;

  /// No description provided for @formPhoneNumbers.
  ///
  /// In zh, this message translates to:
  /// **'电话号码'**
  String get formPhoneNumbers;

  /// No description provided for @formRemoveNumber.
  ///
  /// In zh, this message translates to:
  /// **'删除此号码'**
  String get formRemoveNumber;

  /// No description provided for @formAddNumber.
  ///
  /// In zh, this message translates to:
  /// **'添加号码'**
  String get formAddNumber;

  /// No description provided for @formValidityType.
  ///
  /// In zh, this message translates to:
  /// **'有效期类型'**
  String get formValidityType;

  /// No description provided for @formActivationDate.
  ///
  /// In zh, this message translates to:
  /// **'激活日期'**
  String get formActivationDate;

  /// No description provided for @formActivationDateHint.
  ///
  /// In zh, this message translates to:
  /// **'选择激活日期（可选）'**
  String get formActivationDateHint;

  /// No description provided for @formExpirationDate.
  ///
  /// In zh, this message translates to:
  /// **'到期日期'**
  String get formExpirationDate;

  /// No description provided for @formExpirationDateHint.
  ///
  /// In zh, this message translates to:
  /// **'选择到期日期'**
  String get formExpirationDateHint;

  /// No description provided for @formExpirationHelper.
  ///
  /// In zh, this message translates to:
  /// **'到期日当天仍然有效'**
  String get formExpirationHelper;

  /// No description provided for @formRollingDays.
  ///
  /// In zh, this message translates to:
  /// **'滚动天数'**
  String get formRollingDays;

  /// No description provided for @formRollingDaysHint.
  ///
  /// In zh, this message translates to:
  /// **'例如 180'**
  String get formRollingDaysHint;

  /// No description provided for @formDaysSuffix.
  ///
  /// In zh, this message translates to:
  /// **'天'**
  String get formDaysSuffix;

  /// No description provided for @formRollingDaysHelper.
  ///
  /// In zh, this message translates to:
  /// **'每次使用后，有效期从使用当天起重新计算这么多天'**
  String get formRollingDaysHelper;

  /// No description provided for @formLastUsedDate.
  ///
  /// In zh, this message translates to:
  /// **'上次使用日期'**
  String get formLastUsedDate;

  /// No description provided for @formLastUsedHint.
  ///
  /// In zh, this message translates to:
  /// **'未填写'**
  String get formLastUsedHint;

  /// No description provided for @formLastUsedHelper.
  ///
  /// In zh, this message translates to:
  /// **'未填写时按激活日期计算；激活日期也未填写时按添加日期计算'**
  String get formLastUsedHelper;

  /// No description provided for @formReminderDays.
  ///
  /// In zh, this message translates to:
  /// **'提前提醒天数'**
  String get formReminderDays;

  /// No description provided for @formReminderDaysHint.
  ///
  /// In zh, this message translates to:
  /// **'例如 7'**
  String get formReminderDaysHint;

  /// No description provided for @formReminderDaysHelper.
  ///
  /// In zh, this message translates to:
  /// **'到期前这么多天开始提醒，并显示为「即将到期」'**
  String get formReminderDaysHelper;

  /// No description provided for @formExpirationPreview.
  ///
  /// In zh, this message translates to:
  /// **'到期日：{date}（{status}）'**
  String formExpirationPreview(String date, String status);

  /// No description provided for @formDataRemaining.
  ///
  /// In zh, this message translates to:
  /// **'流量剩余 (MB)'**
  String get formDataRemaining;

  /// No description provided for @formDataTotal.
  ///
  /// In zh, this message translates to:
  /// **'流量总量 (MB)'**
  String get formDataTotal;

  /// No description provided for @formDataRemainingHint.
  ///
  /// In zh, this message translates to:
  /// **'例如 1024'**
  String get formDataRemainingHint;

  /// No description provided for @formDataTotalHint.
  ///
  /// In zh, this message translates to:
  /// **'例如 5120'**
  String get formDataTotalHint;

  /// No description provided for @formVoiceRemaining.
  ///
  /// In zh, this message translates to:
  /// **'通话剩余（分钟）'**
  String get formVoiceRemaining;

  /// No description provided for @formVoiceTotal.
  ///
  /// In zh, this message translates to:
  /// **'通话总量（分钟）'**
  String get formVoiceTotal;

  /// No description provided for @formSmsRemaining.
  ///
  /// In zh, this message translates to:
  /// **'短信剩余'**
  String get formSmsRemaining;

  /// No description provided for @formSmsTotal.
  ///
  /// In zh, this message translates to:
  /// **'短信总量'**
  String get formSmsTotal;

  /// No description provided for @formBalance.
  ///
  /// In zh, this message translates to:
  /// **'话费余额'**
  String get formBalance;

  /// No description provided for @formCurrency.
  ///
  /// In zh, this message translates to:
  /// **'币种'**
  String get formCurrency;

  /// No description provided for @formSmdpAddress.
  ///
  /// In zh, this message translates to:
  /// **'SM-DP+ 服务器地址'**
  String get formSmdpAddress;

  /// No description provided for @formSmdpHint.
  ///
  /// In zh, this message translates to:
  /// **'例如 rsp.example.com'**
  String get formSmdpHint;

  /// No description provided for @formConfirmationHint.
  ///
  /// In zh, this message translates to:
  /// **'如运营商提供'**
  String get formConfirmationHint;

  /// No description provided for @formConfirmationRequired.
  ///
  /// In zh, this message translates to:
  /// **'此 eSIM 的激活码标明安装时需要确认码（不在二维码中，由运营商另行提供）'**
  String get formConfirmationRequired;

  /// No description provided for @formScanQr.
  ///
  /// In zh, this message translates to:
  /// **'扫描/识别二维码'**
  String get formScanQr;

  /// No description provided for @formCopiedActivationCode.
  ///
  /// In zh, this message translates to:
  /// **'已复制完整激活码'**
  String get formCopiedActivationCode;

  /// No description provided for @formCopyActivationCode.
  ///
  /// In zh, this message translates to:
  /// **'复制完整激活码'**
  String get formCopyActivationCode;

  /// No description provided for @formCardColor.
  ///
  /// In zh, this message translates to:
  /// **'卡片颜色'**
  String get formCardColor;

  /// No description provided for @formChangeColor.
  ///
  /// In zh, this message translates to:
  /// **'更改颜色'**
  String get formChangeColor;

  /// No description provided for @formTags.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get formTags;

  /// No description provided for @formNoTags.
  ///
  /// In zh, this message translates to:
  /// **'还没有标签，可在「设置 → 标签管理」中添加'**
  String get formNoTags;

  /// No description provided for @formSource.
  ///
  /// In zh, this message translates to:
  /// **'来源渠道'**
  String get formSource;

  /// No description provided for @formSourceHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：官网、线下门店、朋友转让'**
  String get formSourceHint;

  /// No description provided for @formNotesHint.
  ///
  /// In zh, this message translates to:
  /// **'其他备忘信息'**
  String get formNotesHint;

  /// No description provided for @reminderUpcomingTitle.
  ///
  /// In zh, this message translates to:
  /// **'📅 {carrier} 将在 {days} 天后到期'**
  String reminderUpcomingTitle(String carrier, int days);

  /// No description provided for @reminderUpcomingBodyRolling.
  ///
  /// In zh, this message translates to:
  /// **'请在 {date} 前使用一次以保号'**
  String reminderUpcomingBodyRolling(String date);

  /// No description provided for @reminderUpcomingBodyFixed.
  ///
  /// In zh, this message translates to:
  /// **'到期日：{date}'**
  String reminderUpcomingBodyFixed(String date);

  /// No description provided for @reminderDueTodayTitle.
  ///
  /// In zh, this message translates to:
  /// **'⏰ {carrier} 今天到期'**
  String reminderDueTodayTitle(String carrier);

  /// No description provided for @reminderDueTodayBodyRolling.
  ///
  /// In zh, this message translates to:
  /// **'今天是最后期限，请使用一次以续期'**
  String get reminderDueTodayBodyRolling;

  /// No description provided for @reminderDueTodayBodyFixed.
  ///
  /// In zh, this message translates to:
  /// **'请及时续费或处理'**
  String get reminderDueTodayBodyFixed;

  /// No description provided for @reminderExpiredTitle.
  ///
  /// In zh, this message translates to:
  /// **'⚠️ {carrier} 已过期'**
  String reminderExpiredTitle(String carrier);

  /// No description provided for @reminderExpiredBodyRolling.
  ///
  /// In zh, this message translates to:
  /// **'已超过保号期限 {date}，请尽快确认号码状态'**
  String reminderExpiredBodyRolling(String date);

  /// No description provided for @reminderExpiredBodyFixed.
  ///
  /// In zh, this message translates to:
  /// **'已于 {date} 到期'**
  String reminderExpiredBodyFixed(String date);

  /// No description provided for @notificationChannelName.
  ///
  /// In zh, this message translates to:
  /// **'到期提醒'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In zh, this message translates to:
  /// **'SIM 卡即将到期、今天到期或已过期时提醒'**
  String get notificationChannelDescription;

  /// No description provided for @settingsMaskSensitive.
  ///
  /// In zh, this message translates to:
  /// **'隐藏敏感信息'**
  String get settingsMaskSensitive;

  /// No description provided for @settingsMaskSensitiveSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'ICCID、eSIM 激活码与确认码默认部分隐藏，点击眼睛图标查看'**
  String get settingsMaskSensitiveSubtitle;

  /// No description provided for @sensitiveShow.
  ///
  /// In zh, this message translates to:
  /// **'显示{field}'**
  String sensitiveShow(String field);

  /// No description provided for @sensitiveHide.
  ///
  /// In zh, this message translates to:
  /// **'隐藏{field}'**
  String sensitiveHide(String field);

  /// No description provided for @copyField.
  ///
  /// In zh, this message translates to:
  /// **'复制{field}'**
  String copyField(String field);

  /// No description provided for @esimQrShow.
  ///
  /// In zh, this message translates to:
  /// **'显示二维码'**
  String get esimQrShow;

  /// No description provided for @esimQrTitle.
  ///
  /// In zh, this message translates to:
  /// **'eSIM 二维码'**
  String get esimQrTitle;

  /// No description provided for @esimQrSemantics.
  ///
  /// In zh, this message translates to:
  /// **'eSIM 激活码二维码'**
  String get esimQrSemantics;

  /// No description provided for @esimQrHint.
  ///
  /// In zh, this message translates to:
  /// **'在另一台设备上扫描此二维码安装 eSIM。大多数激活码只能使用一次：已经安装过的 eSIM 通常无法再次下载。'**
  String get esimQrHint;

  /// No description provided for @esimQrNeedsConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'安装时还需要输入确认码（见卡片详情中的「确认码」）。'**
  String get esimQrNeedsConfirmation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
