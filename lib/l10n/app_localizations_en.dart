// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SIMer';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonFollowSystem => 'System default';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get simTypePhysical => 'Physical SIM';

  @override
  String get simTypeEsim => 'eSIM';

  @override
  String get activationActive => 'Active';

  @override
  String get activationInactive => 'Inactive';

  @override
  String get validityUnlimited => 'No expiry';

  @override
  String get validityUnknown => 'Not set';

  @override
  String get validityValid => 'Valid';

  @override
  String get validityExpiringSoon => 'Expiring soon';

  @override
  String get validityExpired => 'Expired';

  @override
  String get validityTypeFixedDate => 'Fixed expiry date';

  @override
  String get validityTypeRolling => 'Rolling validity';

  @override
  String get validityTypeNoExpiration => 'No expiry';

  @override
  String get validityTypeFixedDateDesc =>
      'Set a specific expiry date. The card is still valid on that day.';

  @override
  String get validityTypeRollingDesc =>
      'The card must be used every N days. Each use renews it.';

  @override
  String get validityTypeNoExpirationDesc => 'This SIM card does not expire.';

  @override
  String get sortByCreatedAt => 'Date added';

  @override
  String get sortByExpirationDate => 'Expiry date';

  @override
  String get sortByCarrierName => 'Carrier';

  @override
  String get sortByCountryCode => 'Country/region';

  @override
  String get sortOrderAscending => 'Ascending';

  @override
  String get sortOrderDescending => 'Descending';

  @override
  String get featureVoice => 'Voice calls';

  @override
  String get featureSms => 'SMS';

  @override
  String get featureData => 'Mobile data';

  @override
  String get featureWifiCalling => 'Wi-Fi Calling';

  @override
  String get featureVolte => 'VoLTE';

  @override
  String get featureHotspot => 'Hotspot';

  @override
  String get featureEsimTransfer => 'eSIM transfer';

  @override
  String get featureIntlRoaming => 'International roaming';

  @override
  String get lockTimeoutImmediately => 'Immediately';

  @override
  String get lockTimeoutSeconds30 => 'After 30 seconds';

  @override
  String get lockTimeoutMinute1 => 'After 1 minute';

  @override
  String get lockTimeoutMinutes5 => 'After 5 minutes';

  @override
  String get authPromptTitle => 'Verify your identity';

  @override
  String get authPromptReason => 'Verify your identity to access SIMer';

  @override
  String get authNoticeLockDisabled =>
      'This device no longer has a screen lock or biometrics, so the app lock was turned off.';

  @override
  String get authErrorLockedOut =>
      'Too many attempts. Try again later or use your device PIN, pattern or password.';

  @override
  String get authErrorFailed => 'Verification failed. Please try again.';

  @override
  String get lockToggleNeedsDeviceLock =>
      'Set up a screen lock or biometrics in system settings first.';

  @override
  String get lockToggleAuthFailed => 'Verification failed';

  @override
  String get countryPickerTitle => 'Choose country/region';

  @override
  String get countryPickerSearchHint => 'Search countries/regions…';

  @override
  String get carrierPickerTitle => 'Choose carrier';

  @override
  String get carrierPickerSearchHint =>
      'Search carriers or countries, or type a custom name';

  @override
  String carrierPickerUseCustom(String name) {
    return 'Use “$name” as a custom carrier';
  }

  @override
  String get carrierPickerEmpty => 'No preset carriers';

  @override
  String get filterAll => 'All';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get cardFlipHintToFront => 'show the front of the card';

  @override
  String get cardFlipHintToDetails => 'show card details';

  @override
  String get featureNoteHint => 'Note (optional)';

  @override
  String get cardDetailDeleted => 'This card has been deleted.';

  @override
  String get cardArchivedBadge => 'Archived';

  @override
  String get cardMarkUsed => 'Mark as used';

  @override
  String countdownExpiredDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expired $days days ago',
      one: 'Expired 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String countdownDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get countdownDueToday => 'Expires today';

  @override
  String countdownRollingCycle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'use every $days days',
      one: 'use every day',
    );
    return '$_temp0';
  }

  @override
  String get colorPickerTitle => 'Choose card color';

  @override
  String colorPickerCarrierSuggested(String carrier) {
    return 'Suggested for $carrier';
  }

  @override
  String get colorPickerCarrierSuggestedGeneric => 'Carrier color';

  @override
  String get colorPickerPresets => 'Preset colors';

  @override
  String get colorPickerCustom => 'Custom color';

  @override
  String get lockScreenTitle => 'SIMer is locked';

  @override
  String get lockScreenPrompt => 'Verify your identity to continue';

  @override
  String get lockScreenUnlock => 'Unlock';

  @override
  String get backSectionBasic => 'Basic info';

  @override
  String get fieldCarrier => 'Carrier';

  @override
  String get fieldCountry => 'Country/region';

  @override
  String get fieldPrimaryNumber => 'Main number';

  @override
  String fieldNumberN(int index) {
    return 'Number $index';
  }

  @override
  String get fieldSimType => 'SIM type';

  @override
  String get backSectionValidity => 'Validity';

  @override
  String get fieldValidityType => 'Type';

  @override
  String get fieldActivationDate => 'Activated';

  @override
  String get fieldExpirationDate => 'Expires';

  @override
  String get fieldRollingCycle => 'Cycle';

  @override
  String get fieldLastUsed => 'Last used';

  @override
  String daysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get backSectionUsage => 'Usage';

  @override
  String get backSectionFeatures => 'Features';

  @override
  String get backSectionEsim => 'eSIM';

  @override
  String get fieldMatchingId => 'Matching ID';

  @override
  String get fieldConfirmationCode => 'Confirmation code';

  @override
  String get backSectionOther => 'Other';

  @override
  String get fieldSource => 'Source';

  @override
  String get fieldNotes => 'Notes';

  @override
  String copiedField(String field) {
    return 'Copied $field';
  }

  @override
  String get usageData => 'Data';

  @override
  String get usageVoice => 'Calls';

  @override
  String get usageSms => 'SMS';

  @override
  String get usageBalance => 'Balance';

  @override
  String usageRemaining(String amount) {
    return '$amount left';
  }

  @override
  String usageTotal(String amount) {
    return '$amount total';
  }

  @override
  String usageMinutes(String amount) {
    return '$amount min';
  }

  @override
  String usageMessages(String amount) {
    return '$amount texts';
  }

  @override
  String get cardArchive => 'Archive';

  @override
  String get cardUnarchive => 'Unarchive';

  @override
  String get actionFailed => 'Something went wrong. Please try again.';

  @override
  String get markUsedDone => 'Marked as used today';

  @override
  String markUsedDoneExtended(String date) {
    return 'Marked as used today. Now valid until $date.';
  }

  @override
  String get archiveDialogTitle => 'Archive SIM card';

  @override
  String archiveDialogMessage(String carrier) {
    return 'Archive the $carrier SIM card? You can restore it from Settings → Archive.';
  }

  @override
  String get archiveFailed => 'Couldn\'t archive the card. Please try again.';

  @override
  String archiveDone(String carrier) {
    return 'Archived $carrier';
  }

  @override
  String get archiveTitle => 'Archive';

  @override
  String get archiveEmptyTitle => 'No archived SIM cards';

  @override
  String get archiveEmptySubtitle => 'Archived SIM cards will appear here.';

  @override
  String get archiveRestore => 'Restore';

  @override
  String archiveRestored(String carrier) {
    return 'Restored $carrier';
  }

  @override
  String get archiveRestoreFailed =>
      'Couldn\'t restore the card. Please try again.';

  @override
  String get archiveDeleteForever => 'Delete permanently';

  @override
  String archiveDeleteMessage(String carrier) {
    return 'Permanently delete the $carrier SIM card?\n\nThis can\'t be undone.';
  }

  @override
  String archiveDeleted(String carrier) {
    return 'Deleted $carrier';
  }

  @override
  String get archiveDeleteFailed =>
      'Couldn\'t delete the card. Please try again.';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get tagsAdd => 'Add tag';

  @override
  String get tagsEmptyTitle => 'No tags yet';

  @override
  String get tagsEmptySubtitle =>
      'Tap + in the top right corner to add your first tag.';

  @override
  String tagsUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Used by $count SIM cards',
      one: 'Used by 1 SIM card',
    );
    return '$_temp0';
  }

  @override
  String get tagsEdit => 'Edit tag';

  @override
  String get tagsNameHint => 'Tag name';

  @override
  String get tagsColor => 'Tag color';

  @override
  String tagsNameTaken(String name) {
    return 'A tag named “$name” already exists.';
  }

  @override
  String get commonAdd => 'Add';

  @override
  String get tagsSaveFailed => 'Couldn\'t save the tag. Please try again.';

  @override
  String get tagsDeleteTitle => 'Delete tag';

  @override
  String tagsDeleteInUse(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count SIM cards',
      one: '1 SIM card',
    );
    return 'The tag “$name” is used by $_temp0. Deleting it removes it from those cards. Delete it?';
  }

  @override
  String tagsDeleteConfirm(String name) {
    return 'Delete the tag “$name”?';
  }

  @override
  String get homeSearchClose => 'Close search';

  @override
  String get homeSearchHint => 'Search carriers, numbers, countries, tags…';

  @override
  String get homeSearch => 'Search';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get homeEmptyFiltered => 'No matching SIM cards';

  @override
  String get homeEmpty => 'No SIM cards yet';

  @override
  String get homeEmptyFilteredHint => 'Try changing the filters.';

  @override
  String get homeEmptyHint =>
      'Tap the button below to add your first SIM card.';

  @override
  String get homeClearFilters => 'Clear filters';

  @override
  String get homeAddCard => 'Add SIM/eSIM';

  @override
  String get settingsSectionTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language / 语言';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockOn =>
      'Verify with fingerprint, face or device PIN when opening the app';

  @override
  String get settingsAppLockNeedsDeviceLock =>
      'Set up a screen lock in system settings first';

  @override
  String get settingsAutoLock => 'Auto-lock';

  @override
  String get settingsAutoLockSubtitle =>
      'How long you can leave the app before verifying again';

  @override
  String get autoLockOptionImmediately => 'Immediately after leaving the app';

  @override
  String get autoLockOptionSeconds30 => '30 seconds after leaving the app';

  @override
  String get autoLockOptionMinute1 => '1 minute after leaving the app';

  @override
  String get autoLockOptionMinutes5 => '5 minutes after leaving the app';

  @override
  String get settingsPrivacyScreen => 'Privacy screen';

  @override
  String get settingsPrivacyScreenSubtitle =>
      'Hide app content in Recents. On Android 12 and earlier, screenshots are blocked too.';

  @override
  String get settingsSectionReminders => 'Reminders';

  @override
  String get settingsExpiryReminders => 'Expiry reminders';

  @override
  String get settingsExpiryRemindersSubtitle =>
      'One reminder each on the card\'s advance-notice day, on its expiry date and the day after';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsNotificationsOff => 'Notifications are off';

  @override
  String get settingsNotificationsOffSubtitle =>
      'Reminders won\'t appear until notifications are allowed. Tap to allow.';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsExport => 'Export backup';

  @override
  String get settingsExportSubtitle =>
      'Export all data manually, for example to move to a new device';

  @override
  String get settingsImport => 'Import backup';

  @override
  String get settingsImportSubtitle => 'Restore data from a SIMer backup file';

  @override
  String get settingsSectionManage => 'Manage';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutDescription =>
      'Keep track of your SIM and eSIM cards, stored securely and offline on your device.';

  @override
  String get settingsLicenses => 'Open-source licenses';

  @override
  String get exportIntro =>
      'The backup contains all SIM cards and tags, including sensitive details such as ICCIDs, phone numbers, eSIM activation codes and confirmation codes.';

  @override
  String get exportEncrypt => 'Encrypt backup (recommended)';

  @override
  String get exportPassword => 'Password';

  @override
  String get exportPasswordConfirm => 'Confirm password';

  @override
  String exportPasswordTooShort(int min) {
    return 'Use at least $min characters';
  }

  @override
  String get exportPasswordMismatch => 'Passwords don\'t match';

  @override
  String get exportPasswordWarning =>
      'Remember this password. Without it, the backup can\'t be restored.';

  @override
  String get exportPlainWarning =>
      'An unencrypted backup is a plain JSON file. Only keep it somewhere you trust or send it straight to your own new device, and delete it after importing.';

  @override
  String get exportShare => 'Share';

  @override
  String get exportSaveToFile => 'Save to file';

  @override
  String get exportEncrypting => 'Encrypting…';

  @override
  String get exportSaveDialogTitle => 'Save SIMer backup';

  @override
  String get exportShareSubject => 'SIMer backup';

  @override
  String get exportSaved => 'Backup saved';

  @override
  String get exportSaveCancelled => 'Save cancelled';

  @override
  String get exportShared => 'Backup shared';

  @override
  String get exportShareCancelled => 'Sharing cancelled';

  @override
  String get exportShareOpened => 'Share sheet opened';

  @override
  String get exportFailed => 'Export failed. Please try again.';

  @override
  String get importPasswordTitle => 'Enter backup password';

  @override
  String get importPasswordMessage =>
      'This backup is encrypted. Enter the password that was set when it was exported.';

  @override
  String get importDecrypt => 'Decrypt';

  @override
  String get importDecrypting => 'Decrypting…';

  @override
  String get importFailed =>
      'Import failed. Your existing data was not changed.';

  @override
  String get importDoneTitle => 'Import complete';

  @override
  String get importSkippedRecords =>
      'These records couldn\'t be read and were skipped:';

  @override
  String get commonGotIt => 'Got it';

  @override
  String importSummary(String details) {
    return 'Import complete: $details';
  }

  @override
  String get listSeparator => ', ';

  @override
  String importSummaryCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards added',
      one: '1 card added',
    );
    return '$_temp0';
  }

  @override
  String importSummaryOverwritten(int count) {
    return '$count overwritten';
  }

  @override
  String importSummarySkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count duplicates skipped',
      one: '1 duplicate skipped',
    );
    return '$_temp0';
  }

  @override
  String importSummaryTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags added',
      one: '1 tag added',
    );
    return '$_temp0';
  }

  @override
  String importSummaryFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records unreadable',
      one: '1 record unreadable',
    );
    return '$_temp0';
  }

  @override
  String importExportedAt(String time) {
    return 'Exported: $time';
  }

  @override
  String importCards(int count) {
    return 'Cards: $count';
  }

  @override
  String importDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of them are already on this device (same UUID)',
      one: '1 of them is already on this device (same UUID)',
    );
    return '$_temp0';
  }

  @override
  String importTags(int count) {
    return 'Tags: $count (tags with the same name are merged)';
  }

  @override
  String get importLegacy =>
      'This backup is from SIMer 1.0 and will be converted automatically.';

  @override
  String get importWasEncrypted =>
      'This encrypted backup was decrypted with your password.';

  @override
  String importUnreadableRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records can\'t be read and will be skipped:',
      one: '1 record can\'t be read and will be skipped:',
    );
    return '$_temp0';
  }

  @override
  String importMoreErrors(int count) {
    return '…$count in total';
  }

  @override
  String get importNothing => 'There is nothing to import in this backup.';

  @override
  String get importOverwrite => 'Overwrite duplicates';

  @override
  String get importSkip => 'Skip duplicates';

  @override
  String get importButton => 'Import';

  @override
  String recordErrorCard(int index, String detail) {
    return 'Card $index: $detail';
  }

  @override
  String recordErrorTag(int index, String detail) {
    return 'Tag $index: $detail';
  }

  @override
  String fieldErrorMissing(String field) {
    return 'missing field \"$field\"';
  }

  @override
  String fieldErrorNotText(String field) {
    return 'field \"$field\" must be text';
  }

  @override
  String fieldErrorNotInteger(String field) {
    return 'field \"$field\" must be a whole number';
  }

  @override
  String fieldErrorNotNumber(String field) {
    return 'field \"$field\" must be a number';
  }

  @override
  String fieldErrorNotBoolean(String field) {
    return 'field \"$field\" must be true or false';
  }

  @override
  String fieldErrorInvalidDate(String field) {
    return 'field \"$field\" is not a valid date';
  }

  @override
  String fieldErrorNotObject(String field) {
    return 'field \"$field\" must be an object';
  }

  @override
  String fieldErrorNotTextList(String field) {
    return 'field \"$field\" must be a list of text';
  }

  @override
  String fieldErrorNotIntegerList(String field) {
    return 'field \"$field\" must be a list of whole numbers';
  }

  @override
  String get recordErrorInvalid => 'invalid record';

  @override
  String get backupErrorFileTooLarge =>
      'The file is larger than 10 MB and isn\'t a valid SIMer backup.';

  @override
  String get backupErrorNotUtf8 =>
      'The file isn\'t UTF-8 text and isn\'t a valid SIMer backup.';

  @override
  String get backupErrorUnreadable => 'Couldn\'t read the selected file.';

  @override
  String get backupErrorNotJson =>
      'The file isn\'t valid JSON. It may not be a SIMer backup.';

  @override
  String get backupErrorUnrecognized => 'Unrecognized backup file.';

  @override
  String get backupErrorNewerVersion =>
      'This backup was exported by a newer version of SIMer. Update the app, then import it.';

  @override
  String get backupErrorUnsupportedVersion =>
      'Unsupported backup format version.';

  @override
  String get backupErrorMissingVersion =>
      'Unrecognized backup file (the format version is missing).';

  @override
  String get backupErrorCorrupted => 'The backup file is damaged.';

  @override
  String get backupErrorWrongPassword =>
      'Wrong password, or the file is damaged.';

  @override
  String get backupErrorUnsupportedEncryption =>
      'This encrypted backup uses an encryption method this version doesn\'t support. Update the app first.';

  @override
  String get qrErrorEmpty => 'The text is empty.';

  @override
  String get qrErrorNotActivationCode =>
      'Not an eSIM activation code (it should start with LPA:1\$).';

  @override
  String qrErrorUnsupportedFormat(String version) {
    return 'Unsupported activation code format “$version”.';
  }

  @override
  String get qrErrorIncomplete =>
      'The activation code is incomplete: the SM-DP+ address or Matching ID is missing.';

  @override
  String get qrErrorEmptySmdp => 'The SM-DP+ address is empty.';

  @override
  String qrErrorInvalidSmdp(String address) {
    return 'Invalid SM-DP+ address: $address';
  }

  @override
  String get qrErrorEmptyMatchingId => 'The Matching ID is empty.';

  @override
  String get scanHint => 'Place the eSIM QR code inside the frame';

  @override
  String get scanTitle => 'Scan eSIM QR code';

  @override
  String get scanTorch => 'Flash';

  @override
  String get scanFromImage => 'From photo';

  @override
  String get scanPaste => 'Paste code';

  @override
  String get scanSwitchCamera => 'Switch camera';

  @override
  String get scanPermissionDenied => 'Camera access is needed to scan QR codes';

  @override
  String get scanCameraUnavailable => 'The camera couldn\'t start';

  @override
  String get scanAlternatives =>
      'You can also use “From photo” or “Paste code” below.';

  @override
  String get scanOpenSettings => 'Allow camera access in Settings';

  @override
  String get scanNoQrInImage => 'No QR code found in the image';

  @override
  String get scanImageFailed => 'Couldn\'t read this image';

  @override
  String get scanClipboardEmpty => 'There is no text on the clipboard';

  @override
  String get scanResultTitle => 'eSIM activation code found';

  @override
  String get fieldSmdpAddress => 'SM-DP+ address';

  @override
  String get scanResultMatchingId => 'Matching ID';

  @override
  String get scanNeedsConfirmationCode =>
      'Installing this eSIM requires a confirmation code. It isn\'t part of the QR code, so get it from your carrier and enter it in the form.';

  @override
  String get scanAgain => 'Scan again';

  @override
  String get scanUseResult => 'Use this code';

  @override
  String get formErrorIccid => 'ICCID must be 18–22 digits';

  @override
  String get formErrorNumber => 'Enter a valid number';

  @override
  String get formErrorNegative => 'Can\'t be negative';

  @override
  String get formErrorInteger => 'Enter a whole number';

  @override
  String get formErrorDaysRequired => 'Enter the number of days';

  @override
  String get formErrorDaysInteger => 'Enter a whole number of days';

  @override
  String formErrorDaysRange(int min, int max) {
    return 'Enter a number from $min to $max';
  }

  @override
  String get formErrorDateInFuture => 'Can\'t be later than today';

  @override
  String get formErrorExpirationRequired => 'Choose an expiry date';

  @override
  String get formSectionUsage => 'Usage';

  @override
  String get formSectionEsim => 'eSIM';

  @override
  String get formSectionAppearance => 'Appearance & tags';

  @override
  String get formSectionHasErrors => 'This section has fields to fix';

  @override
  String get formClearDate => 'Clear date';

  @override
  String get formEditTitle => 'Edit SIM card';

  @override
  String get formAddTitle => 'Add SIM/eSIM';

  @override
  String get formCheckErrors => 'Check the fields marked in red';

  @override
  String get formSaveFailed => 'Couldn\'t save. Please try again.';

  @override
  String get formDiscardTitle => 'Discard unsaved changes?';

  @override
  String get formDiscardMessage =>
      'If you leave now, your changes won\'t be saved.';

  @override
  String get formKeepEditing => 'Keep editing';

  @override
  String get formDiscard => 'Discard';

  @override
  String get formSimType => 'SIM type';

  @override
  String get formActivationStatus => 'Activation status';

  @override
  String get formCarrierHint => 'Choose or enter a carrier';

  @override
  String get formCarrierRequired => 'Choose or enter a carrier';

  @override
  String get formIccidHint => '18–22 digits, spaces allowed';

  @override
  String get formPhoneNumbers => 'Phone numbers';

  @override
  String get formRemoveNumber => 'Remove this number';

  @override
  String get formAddNumber => 'Add number';

  @override
  String get formValidityType => 'Validity type';

  @override
  String get formActivationDate => 'Activation date';

  @override
  String get formActivationDateHint => 'Choose the activation date (optional)';

  @override
  String get formExpirationDate => 'Expiry date';

  @override
  String get formExpirationDateHint => 'Choose the expiry date';

  @override
  String get formExpirationHelper => 'The card is still valid on this day';

  @override
  String get formRollingDays => 'Rolling period';

  @override
  String get formRollingDaysHint => 'e.g. 180';

  @override
  String get formDaysSuffix => 'days';

  @override
  String get formRollingDaysHelper =>
      'After each use, the card stays valid for this many days from that day';

  @override
  String get formLastUsedDate => 'Last used';

  @override
  String get formLastUsedHint => 'Not set';

  @override
  String get formLastUsedHelper =>
      'If empty, the activation date is used, or the date the card was added if that is empty too';

  @override
  String get formReminderDays => 'Remind me this many days before';

  @override
  String get formReminderDaysHint => 'e.g. 7';

  @override
  String get formReminderDaysHelper =>
      'Reminders start this many days before the card expires, and it shows as “Expiring soon”';

  @override
  String formExpirationPreview(String date, String status) {
    return 'Expires on $date ($status)';
  }

  @override
  String get formDataRemaining => 'Data left (MB)';

  @override
  String get formDataTotal => 'Data total (MB)';

  @override
  String get formDataRemainingHint => 'e.g. 1024';

  @override
  String get formDataTotalHint => 'e.g. 5120';

  @override
  String get formVoiceRemaining => 'Minutes left';

  @override
  String get formVoiceTotal => 'Minutes total';

  @override
  String get formSmsRemaining => 'Texts left';

  @override
  String get formSmsTotal => 'Texts total';

  @override
  String get formBalance => 'Credit balance';

  @override
  String get formCurrency => 'Currency';

  @override
  String get formSmdpAddress => 'SM-DP+ server address';

  @override
  String get formSmdpHint => 'e.g. rsp.example.com';

  @override
  String get formConfirmationHint => 'If your carrier provided one';

  @override
  String get formConfirmationRequired =>
      'This eSIM\'s activation code says a confirmation code is required. It isn\'t in the QR code; your carrier provides it separately.';

  @override
  String get formScanQr => 'Scan QR code';

  @override
  String get formCopiedActivationCode => 'Full activation code copied';

  @override
  String get formCopyActivationCode => 'Copy full activation code';

  @override
  String get formCardColor => 'Card color';

  @override
  String get formChangeColor => 'Change color';

  @override
  String get formTags => 'Tags';

  @override
  String get formNoTags => 'No tags yet. You can add them in Settings → Tags.';

  @override
  String get formSource => 'Where you got it';

  @override
  String get formSourceHint => 'e.g. online store, retail shop, from a friend';

  @override
  String get formNotesHint => 'Anything else to remember';

  @override
  String reminderUpcomingTitle(String carrier, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '📅 $carrier expires in $_temp0';
  }

  @override
  String reminderUpcomingBodyRolling(String date) {
    return 'Use it once before $date to keep the number.';
  }

  @override
  String reminderUpcomingBodyFixed(String date) {
    return 'Expiry date: $date';
  }

  @override
  String reminderDueTodayTitle(String carrier) {
    return '⏰ $carrier expires today';
  }

  @override
  String get reminderDueTodayBodyRolling =>
      'Today is the deadline. Use it once to renew it.';

  @override
  String get reminderDueTodayBodyFixed => 'Renew it or take care of it today.';

  @override
  String reminderExpiredTitle(String carrier) {
    return '⚠️ $carrier has expired';
  }

  @override
  String reminderExpiredBodyRolling(String date) {
    return 'The keep-alive deadline ($date) has passed. Check the number\'s status soon.';
  }

  @override
  String reminderExpiredBodyFixed(String date) {
    return 'Expired on $date.';
  }

  @override
  String get notificationChannelName => 'Expiry reminders';

  @override
  String get notificationChannelDescription =>
      'Reminders when a SIM card is about to expire, expires today or has expired';

  @override
  String get settingsMaskSensitive => 'Hide sensitive details';

  @override
  String get settingsMaskSensitiveSubtitle =>
      'ICCIDs, eSIM activation codes and confirmation codes stay partly hidden until you tap the eye icon';

  @override
  String sensitiveShow(String field) {
    return 'Show $field';
  }

  @override
  String sensitiveHide(String field) {
    return 'Hide $field';
  }

  @override
  String copyField(String field) {
    return 'Copy $field';
  }
}
