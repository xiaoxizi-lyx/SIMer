// 界面文案的访问入口与枚举 / 错误码的本地化。
//
// 文案本身在 app_zh.arb（模板）与 app_en.arb 中；app_localizations*.dart 由 `flutter gen-l10n` 生成。
// 模型、服务层不包含界面文字，只返回枚举或错误码，由这里转换为当前语言的文字。

import 'package:flutter/widgets.dart';

import '../data/carriers.dart';
import '../database/database_helper.dart';
import '../models/enums.dart';
import '../models/feature_set.dart';
import '../models/json_utils.dart';
import '../models/sim_card.dart';
import '../providers/auth_provider.dart';
import '../screens/sim_form/sim_form_draft.dart';
import '../screens/sim_form/sim_form_validators.dart';
import '../services/backup_codec.dart';
import '../services/qr_parser_service.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// 当前界面语言的文案。
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension SimCardLabels on SimCard {
  /// 按界面语言显示的运营商名称（预置运营商有英文名，自定义运营商原样显示）。
  String carrierLabel(AppLocalizations l) => CarrierData.displayName(
    carrierCode: carrierCode,
    storedName: carrierName,
    languageCode: l.localeName,
  );
}

extension SimTypeLabel on SimType {
  String label(AppLocalizations l) => switch (this) {
    SimType.physicalSim => l.simTypePhysical,
    SimType.esim => l.simTypeEsim,
  };
}

extension ActivationStatusLabel on ActivationStatus {
  String label(AppLocalizations l) => switch (this) {
    ActivationStatus.active => l.activationActive,
    ActivationStatus.inactive => l.activationInactive,
  };
}

extension ValidityStateLabel on ValidityState {
  String label(AppLocalizations l) => switch (this) {
    ValidityState.unlimited => l.validityUnlimited,
    ValidityState.unknown => l.validityUnknown,
    ValidityState.valid => l.validityValid,
    ValidityState.expiringSoon => l.validityExpiringSoon,
    ValidityState.expired => l.validityExpired,
  };
}

extension ValidityTypeLabel on ValidityType {
  String label(AppLocalizations l) => switch (this) {
    ValidityType.fixedDate => l.validityTypeFixedDate,
    ValidityType.rolling => l.validityTypeRolling,
    ValidityType.noExpiration => l.validityTypeNoExpiration,
  };

  String description(AppLocalizations l) => switch (this) {
    ValidityType.fixedDate => l.validityTypeFixedDateDesc,
    ValidityType.rolling => l.validityTypeRollingDesc,
    ValidityType.noExpiration => l.validityTypeNoExpirationDesc,
  };
}

extension StatusFilterLabel on StatusFilter {
  String label(AppLocalizations l) => switch (this) {
    StatusFilter.active => l.activationActive,
    StatusFilter.inactive => l.activationInactive,
    StatusFilter.expiringSoon => l.validityExpiringSoon,
    StatusFilter.expired => l.validityExpired,
  };
}

extension SortByLabel on SortBy {
  String label(AppLocalizations l) => switch (this) {
    SortBy.createdAt => l.sortByCreatedAt,
    SortBy.expirationDate => l.sortByExpirationDate,
    SortBy.carrierName => l.sortByCarrierName,
    SortBy.countryCode => l.sortByCountryCode,
  };
}

extension SortOrderLabel on SortOrder {
  String label(AppLocalizations l) => switch (this) {
    SortOrder.ascending => l.sortOrderAscending,
    SortOrder.descending => l.sortOrderDescending,
  };
}

extension FeatureLabel on Feature {
  String label(AppLocalizations l) => switch (this) {
    Feature.voice => l.featureVoice,
    Feature.sms => l.featureSms,
    Feature.data => l.featureData,
    Feature.wifiCalling => l.featureWifiCalling,
    Feature.volte => l.featureVolte,
    Feature.hotspot => l.featureHotspot,
    Feature.esimTransfer => l.featureEsimTransfer,
    Feature.intlRoaming => l.featureIntlRoaming,
  };
}

extension LockTimeoutLabel on LockTimeout {
  String label(AppLocalizations l) => switch (this) {
    LockTimeout.immediately => l.lockTimeoutImmediately,
    LockTimeout.seconds30 => l.lockTimeoutSeconds30,
    LockTimeout.minute1 => l.lockTimeoutMinute1,
    LockTimeout.minutes5 => l.lockTimeoutMinutes5,
  };
}

extension LockTimeoutOption on LockTimeout {
  /// 自动锁定选项中的完整说明，例如「离开应用 30 秒后」。
  String optionLabel(AppLocalizations l) => switch (this) {
    LockTimeout.immediately => l.autoLockOptionImmediately,
    LockTimeout.seconds30 => l.autoLockOptionSeconds30,
    LockTimeout.minute1 => l.autoLockOptionMinute1,
    LockTimeout.minutes5 => l.autoLockOptionMinutes5,
  };
}

extension AuthNoticeMessage on AuthNotice {
  String message(AppLocalizations l) => switch (this) {
    AuthNotice.lockDisabledNoCredentials => l.authNoticeLockDisabled,
  };
}

extension AuthErrorMessage on AuthError {
  String message(AppLocalizations l) => switch (this) {
    AuthError.lockedOut => l.authErrorLockedOut,
    AuthError.failed => l.authErrorFailed,
  };
}

extension LockToggleErrorMessage on LockToggleError {
  String message(AppLocalizations l) => switch (this) {
    LockToggleError.deviceNotSecure => l.lockToggleNeedsDeviceLock,
    LockToggleError.authenticationFailed => l.lockToggleAuthFailed,
  };
}

extension BackupErrorMessage on BackupError {
  String message(AppLocalizations l) => switch (this) {
    BackupError.fileTooLarge => l.backupErrorFileTooLarge,
    BackupError.notUtf8 => l.backupErrorNotUtf8,
    BackupError.unreadable => l.backupErrorUnreadable,
    BackupError.notJson => l.backupErrorNotJson,
    BackupError.unrecognized => l.backupErrorUnrecognized,
    BackupError.newerVersion => l.backupErrorNewerVersion,
    BackupError.unsupportedVersion => l.backupErrorUnsupportedVersion,
    BackupError.missingVersion => l.backupErrorMissingVersion,
    BackupError.corrupted => l.backupErrorCorrupted,
    BackupError.wrongPassword => l.backupErrorWrongPassword,
    BackupError.unsupportedEncryption => l.backupErrorUnsupportedEncryption,
  };
}

extension BackupRecordErrorMessage on BackupRecordError {
  /// 例如「第 3 张卡片：缺少字段 "uuid"」。
  String message(AppLocalizations l) {
    final field = this.field;
    final problem = this.problem;
    final detail = field == null || problem == null
        ? l.recordErrorInvalid
        : switch (problem) {
            JsonFieldProblem.missing => l.fieldErrorMissing(field),
            JsonFieldProblem.notText => l.fieldErrorNotText(field),
            JsonFieldProblem.notInteger => l.fieldErrorNotInteger(field),
            JsonFieldProblem.notNumber => l.fieldErrorNotNumber(field),
            JsonFieldProblem.notBoolean => l.fieldErrorNotBoolean(field),
            JsonFieldProblem.invalidDate => l.fieldErrorInvalidDate(field),
            JsonFieldProblem.notObject => l.fieldErrorNotObject(field),
            JsonFieldProblem.notTextList => l.fieldErrorNotTextList(field),
            JsonFieldProblem.notIntegerList => l.fieldErrorNotIntegerList(
              field,
            ),
          };
    return switch (kind) {
      BackupRecordKind.card => l.recordErrorCard(index, detail),
      BackupRecordKind.tag => l.recordErrorTag(index, detail),
    };
  }
}

extension ImportResultSummary on ImportResult {
  /// 例如「导入完成：新增 3 张卡片，新增 1 个标签」。
  String summary(AppLocalizations l) {
    final parts = <String>[
      l.importSummaryCards(importedCards),
      if (overwrittenCards > 0) l.importSummaryOverwritten(overwrittenCards),
      if (skippedCards > 0) l.importSummarySkipped(skippedCards),
      if (importedTags > 0) l.importSummaryTags(importedTags),
      if (failedRecords.isNotEmpty) l.importSummaryFailed(failedRecords.length),
    ];
    return l.importSummary(parts.join(l.listSeparator));
  }
}

extension QrParseResultMessage on QrParseResult {
  /// 解析失败的原因；解析成功时为 null。
  String? errorMessage(AppLocalizations l) => switch (error) {
    null => null,
    QrParseError.empty => l.qrErrorEmpty,
    QrParseError.notActivationCode => l.qrErrorNotActivationCode,
    QrParseError.unsupportedFormat => l.qrErrorUnsupportedFormat(
      errorDetail ?? '',
    ),
    QrParseError.incomplete => l.qrErrorIncomplete,
    QrParseError.emptySmdp => l.qrErrorEmptySmdp,
    QrParseError.invalidSmdp => l.qrErrorInvalidSmdp(errorDetail ?? ''),
    QrParseError.emptyMatchingId => l.qrErrorEmptyMatchingId,
  };
}

extension FieldErrorMessage on FieldError {
  String message(AppLocalizations l) => switch (this) {
    FieldError.invalidIccid => l.formErrorIccid,
    FieldError.notANumber => l.formErrorNumber,
    FieldError.negative => l.formErrorNegative,
    FieldError.notAnInteger => l.formErrorInteger,
    FieldError.daysRequired => l.formErrorDaysRequired,
    FieldError.daysNotInteger => l.formErrorDaysInteger,
    FieldError.rollingDaysOutOfRange => l.formErrorDaysRange(
      1,
      SimFormValidators.maxRollingDays,
    ),
    FieldError.reminderDaysOutOfRange => l.formErrorDaysRange(
      0,
      SimFormValidators.maxReminderDays,
    ),
    FieldError.dateInFuture => l.formErrorDateInFuture,
    FieldError.expirationRequired => l.formErrorExpirationRequired,
  };
}

extension SimFormSectionTitle on SimFormSection {
  String title(AppLocalizations l) => switch (this) {
    SimFormSection.basic => l.backSectionBasic,
    SimFormSection.validity => l.backSectionValidity,
    SimFormSection.usage => l.formSectionUsage,
    SimFormSection.features => l.backSectionFeatures,
    SimFormSection.esim => l.formSectionEsim,
    SimFormSection.appearance => l.formSectionAppearance,
  };
}
