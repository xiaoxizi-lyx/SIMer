// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'SIMer';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确定';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonClose => '关闭';

  @override
  String get commonCopy => '复制';

  @override
  String get commonUndo => '撤销';

  @override
  String get commonRetry => '重试';

  @override
  String get commonFollowSystem => '跟随系统';

  @override
  String get commonNotSet => '未设置';

  @override
  String get simTypePhysical => '实体SIM卡';

  @override
  String get simTypeEsim => 'eSIM';

  @override
  String get activationActive => '激活';

  @override
  String get activationInactive => '未激活';

  @override
  String get validityUnlimited => '无期限';

  @override
  String get validityUnknown => '未设定';

  @override
  String get validityValid => '有效';

  @override
  String get validityExpiringSoon => '即将到期';

  @override
  String get validityExpired => '已过期';

  @override
  String get validityTypeFixedDate => '固定到期日';

  @override
  String get validityTypeRolling => '滚动有效期';

  @override
  String get validityTypeNoExpiration => '无期限';

  @override
  String get validityTypeFixedDateDesc => '设定一个具体的到期日期，当天仍然有效';

  @override
  String get validityTypeRollingDesc => '每隔N天需使用一次，使用后自动续期';

  @override
  String get validityTypeNoExpirationDesc => '此SIM卡没有有效期限制';

  @override
  String get sortByCreatedAt => '添加时间';

  @override
  String get sortByExpirationDate => '到期时间';

  @override
  String get sortByCarrierName => '运营商';

  @override
  String get sortByCountryCode => '国家/地区';

  @override
  String get sortOrderAscending => '升序';

  @override
  String get sortOrderDescending => '降序';

  @override
  String get featureVoice => '通话';

  @override
  String get featureSms => '短信';

  @override
  String get featureData => '数据流量';

  @override
  String get featureWifiCalling => 'Wi-Fi Calling';

  @override
  String get featureVolte => 'VoLTE';

  @override
  String get featureHotspot => '热点共享';

  @override
  String get featureEsimTransfer => 'eSIM转移';

  @override
  String get featureIntlRoaming => '国际漫游';

  @override
  String get lockTimeoutImmediately => '立即';

  @override
  String get lockTimeoutSeconds30 => '30 秒后';

  @override
  String get lockTimeoutMinute1 => '1 分钟后';

  @override
  String get lockTimeoutMinutes5 => '5 分钟后';

  @override
  String get authPromptTitle => '验证身份';

  @override
  String get authPromptReason => '请验证身份以访问 SIMer';

  @override
  String get authNoticeLockDisabled => '设备已不再设置锁屏密码或生物识别，应用锁已自动关闭';

  @override
  String get authErrorLockedOut => '尝试次数过多，请稍后再试或使用设备密码';

  @override
  String get authErrorFailed => '验证失败，请重试';

  @override
  String get lockToggleNeedsDeviceLock => '请先在系统设置中设置锁屏密码或生物识别';

  @override
  String get lockToggleAuthFailed => '身份验证失败';

  @override
  String get countryPickerTitle => '选择国家/地区';

  @override
  String get countryPickerSearchHint => '搜索国家/地区…';

  @override
  String get carrierPickerTitle => '选择运营商';

  @override
  String get carrierPickerSearchHint => '搜索运营商或国家，或输入自定义名称';

  @override
  String carrierPickerUseCustom(String name) {
    return '使用「$name」作为自定义运营商';
  }

  @override
  String get carrierPickerEmpty => '没有预置运营商';

  @override
  String get filterAll => '全部';

  @override
  String get sortTooltip => '排序';

  @override
  String get cardFlipHintToFront => '返回卡片正面';

  @override
  String get cardFlipHintToDetails => '查看卡片详情';

  @override
  String get featureNoteHint => '备注（可选）';

  @override
  String get cardDetailDeleted => '这张卡片已被删除';

  @override
  String get cardArchivedBadge => '已归档';

  @override
  String get cardMarkUsed => '我已使用';

  @override
  String countdownExpiredDays(int days) {
    return '已过期 $days 天';
  }

  @override
  String countdownDaysLeft(int days) {
    return '剩余 $days 天';
  }

  @override
  String get countdownDueToday => '今天到期';

  @override
  String countdownRollingCycle(int days) {
    return '$days天一用';
  }

  @override
  String get colorPickerTitle => '选择卡片颜色';

  @override
  String colorPickerCarrierSuggested(String carrier) {
    return '$carrier推荐';
  }

  @override
  String get colorPickerCarrierSuggestedGeneric => '运营商推荐';

  @override
  String get colorPickerPresets => '预设颜色';

  @override
  String get colorPickerCustom => '自定义颜色';

  @override
  String get lockScreenTitle => 'SIMer 已锁定';

  @override
  String get lockScreenPrompt => '请验证身份后继续';

  @override
  String get lockScreenUnlock => '解锁';

  @override
  String get backSectionBasic => '基本信息';

  @override
  String get fieldCarrier => '运营商';

  @override
  String get fieldCountry => '国家/地区';

  @override
  String get fieldPrimaryNumber => '主号码';

  @override
  String fieldNumberN(int index) {
    return '号码$index';
  }

  @override
  String get fieldSimType => 'SIM类型';

  @override
  String get backSectionValidity => '有效期';

  @override
  String get fieldValidityType => '类型';

  @override
  String get fieldActivationDate => '激活日期';

  @override
  String get fieldExpirationDate => '到期日期';

  @override
  String get fieldRollingCycle => '滚动周期';

  @override
  String get fieldLastUsed => '上次使用';

  @override
  String daysCount(int days) {
    return '$days 天';
  }

  @override
  String get backSectionUsage => '用量';

  @override
  String get backSectionFeatures => '功能支持';

  @override
  String get backSectionEsim => 'eSIM信息';

  @override
  String get fieldMatchingId => '激活码';

  @override
  String get fieldConfirmationCode => '确认码';

  @override
  String get backSectionOther => '其他';

  @override
  String get fieldSource => '来源';

  @override
  String get fieldNotes => '备注';

  @override
  String copiedField(String field) {
    return '已复制 $field';
  }

  @override
  String get usageData => '流量';

  @override
  String get usageVoice => '通话';

  @override
  String get usageSms => '短信';

  @override
  String get usageBalance => '余额';

  @override
  String usageRemaining(String amount) {
    return '剩余 $amount';
  }

  @override
  String usageTotal(String amount) {
    return '总量 $amount';
  }

  @override
  String usageMinutes(String amount) {
    return '$amount 分钟';
  }

  @override
  String usageMessages(String amount) {
    return '$amount 条';
  }

  @override
  String get cardArchive => '归档';

  @override
  String get cardUnarchive => '取消归档';

  @override
  String get actionFailed => '操作失败，请重试';

  @override
  String get markUsedDone => '已记录今天使用';

  @override
  String markUsedDoneExtended(String date) {
    return '已记录今天使用，有效期顺延至 $date';
  }

  @override
  String get archiveDialogTitle => '归档SIM卡';

  @override
  String archiveDialogMessage(String carrier) {
    return '确定要将 $carrier 的SIM卡归档吗？归档后可在「设置 → 归档」中恢复。';
  }

  @override
  String get archiveFailed => '归档失败，请重试';

  @override
  String archiveDone(String carrier) {
    return '已归档 $carrier';
  }

  @override
  String get archiveTitle => '归档';

  @override
  String get archiveEmptyTitle => '没有已归档的SIM卡';

  @override
  String get archiveEmptySubtitle => '已归档的SIM卡会显示在这里';

  @override
  String get archiveRestore => '恢复';

  @override
  String archiveRestored(String carrier) {
    return '已恢复 $carrier';
  }

  @override
  String get archiveRestoreFailed => '恢复失败，请重试';

  @override
  String get archiveDeleteForever => '永久删除';

  @override
  String archiveDeleteMessage(String carrier) {
    return '确定要永久删除 $carrier 的SIM卡吗？\n\n此操作不可恢复。';
  }

  @override
  String archiveDeleted(String carrier) {
    return '已永久删除 $carrier';
  }

  @override
  String get archiveDeleteFailed => '删除失败，请重试';

  @override
  String get tagsTitle => '标签管理';

  @override
  String get tagsAdd => '添加标签';

  @override
  String get tagsEmptyTitle => '还没有标签';

  @override
  String get tagsEmptySubtitle => '点击右上角添加你的第一个标签';

  @override
  String tagsUsage(int count) {
    return '已关联 $count 张SIM卡';
  }

  @override
  String get tagsEdit => '编辑标签';

  @override
  String get tagsNameHint => '标签名称';

  @override
  String get tagsColor => '标签颜色';

  @override
  String tagsNameTaken(String name) {
    return '已有名为「$name」的标签';
  }

  @override
  String get commonAdd => '添加';

  @override
  String get tagsSaveFailed => '保存标签失败，请重试';

  @override
  String get tagsDeleteTitle => '删除标签';

  @override
  String tagsDeleteInUse(String name, int count) {
    return '标签\"$name\"已被 $count 张SIM卡使用。删除后将从这些卡中移除该标签。确定要删除吗？';
  }

  @override
  String tagsDeleteConfirm(String name) {
    return '确定要删除标签\"$name\"吗？';
  }

  @override
  String get homeSearchClose => '关闭搜索';

  @override
  String get homeSearchHint => '搜索运营商、号码、国家、标签…';

  @override
  String get homeSearch => '搜索';

  @override
  String get settingsTitle => '设置';

  @override
  String get homeEmptyFiltered => '没有匹配的SIM卡';

  @override
  String get homeEmpty => '还没有SIM卡记录';

  @override
  String get homeEmptyFilteredHint => '试试调整筛选条件';

  @override
  String get homeEmptyHint => '点击下方按钮添加你的第一张SIM卡';

  @override
  String get homeClearFilters => '清除筛选';

  @override
  String get homeAddCard => '添加SIM/eSIM信息';

  @override
  String get settingsSectionTheme => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get settingsLanguage => '语言 / Language';

  @override
  String get settingsSectionSecurity => '安全';

  @override
  String get settingsAppLock => '应用锁';

  @override
  String get settingsAppLockOn => '打开应用时验证指纹、面容或设备密码';

  @override
  String get settingsAppLockNeedsDeviceLock => '需要先在系统设置中设置锁屏密码';

  @override
  String get settingsAutoLock => '自动锁定';

  @override
  String get settingsAutoLockSubtitle => '离开应用多久后需要重新验证';

  @override
  String get autoLockOptionImmediately => '离开应用后立即';

  @override
  String get autoLockOptionSeconds30 => '离开应用 30 秒后';

  @override
  String get autoLockOptionMinute1 => '离开应用 1 分钟后';

  @override
  String get autoLockOptionMinutes5 => '离开应用 5 分钟后';

  @override
  String get settingsPrivacyScreen => '防窥保护';

  @override
  String get settingsPrivacyScreenSubtitle =>
      '在「最近任务」中隐藏应用内容；Android 12 及以下会同时禁止截屏';

  @override
  String get settingsSectionReminders => '提醒';

  @override
  String get settingsExpiryReminders => '到期提醒';

  @override
  String get settingsExpiryRemindersSubtitle => '在卡片提前提醒日、到期当天与过期次日各提醒一次';

  @override
  String get settingsReminderTime => '提醒时间';

  @override
  String get settingsNotificationsOff => '通知权限未开启';

  @override
  String get settingsNotificationsOffSubtitle => '未开启时提醒不会显示，点击授权';

  @override
  String get settingsSectionData => '数据';

  @override
  String get settingsExport => '导出备份';

  @override
  String get settingsExportSubtitle => '手动导出全部数据，用于迁移到新设备';

  @override
  String get settingsImport => '导入备份';

  @override
  String get settingsImportSubtitle => '从 SIMer 备份文件恢复数据';

  @override
  String get settingsSectionManage => '管理';

  @override
  String get settingsSectionAbout => '关于';

  @override
  String settingsVersion(String version) {
    return '版本 $version';
  }

  @override
  String get settingsAboutDescription => 'SIM卡信息记录管理，安全存储你的SIM卡与eSIM信息。';

  @override
  String get settingsLicenses => '开源许可';

  @override
  String get exportIntro =>
      '备份包含全部 SIM 卡与标签数据，其中有 ICCID、电话号码、eSIM 激活码与确认码等敏感信息。';

  @override
  String get exportEncrypt => '加密备份（推荐）';

  @override
  String get exportPassword => '密码';

  @override
  String get exportPasswordConfirm => '再次输入密码';

  @override
  String exportPasswordTooShort(int min) {
    return '密码至少 $min 位';
  }

  @override
  String get exportPasswordMismatch => '两次输入的密码不一致';

  @override
  String get exportPasswordWarning => '请牢记密码：忘记密码将无法恢复这份备份。';

  @override
  String get exportPlainWarning =>
      '未加密的备份是明文 JSON 文件。请只保存到你信任的位置，或直接发送到你自己的新设备，导入完成后及时删除。';

  @override
  String get exportShare => '分享';

  @override
  String get exportSaveToFile => '保存到文件';

  @override
  String get exportEncrypting => '正在加密…';

  @override
  String get exportSaveDialogTitle => '保存 SIMer 备份';

  @override
  String get exportShareSubject => 'SIMer 数据备份';

  @override
  String get exportSaved => '备份已保存';

  @override
  String get exportSaveCancelled => '已取消保存';

  @override
  String get exportShared => '备份已分享';

  @override
  String get exportShareCancelled => '已取消分享';

  @override
  String get exportShareOpened => '已打开分享面板';

  @override
  String get exportFailed => '导出失败，请重试';

  @override
  String get importPasswordTitle => '输入备份密码';

  @override
  String get importPasswordMessage => '这份备份已加密，请输入导出时设置的密码。';

  @override
  String get importDecrypt => '解密';

  @override
  String get importDecrypting => '正在解密…';

  @override
  String get importFailed => '导入失败，现有数据未做任何修改';

  @override
  String get importDoneTitle => '导入完成';

  @override
  String get importSkippedRecords => '以下记录无法解析，已跳过：';

  @override
  String get commonGotIt => '知道了';

  @override
  String importSummary(String details) {
    return '导入完成：$details';
  }

  @override
  String get listSeparator => '，';

  @override
  String importSummaryCards(int count) {
    return '新增 $count 张卡片';
  }

  @override
  String importSummaryOverwritten(int count) {
    return '覆盖 $count 张';
  }

  @override
  String importSummarySkipped(int count) {
    return '跳过 $count 张重复卡片';
  }

  @override
  String importSummaryTags(int count) {
    return '新增 $count 个标签';
  }

  @override
  String importSummaryFailed(int count) {
    return '$count 条记录无法解析';
  }

  @override
  String importExportedAt(String time) {
    return '导出时间：$time';
  }

  @override
  String importCards(int count) {
    return '卡片：$count 张';
  }

  @override
  String importDuplicates(int count) {
    return '其中 $count 张与本机已有卡片相同（UUID 一致）';
  }

  @override
  String importTags(int count) {
    return '标签：$count 个（同名标签会自动合并）';
  }

  @override
  String get importLegacy => '此备份来自 SIMer 1.0，导入时会自动转换格式。';

  @override
  String get importWasEncrypted => '这是一份加密备份，已用你输入的密码解密。';

  @override
  String importUnreadableRecords(int count) {
    return '$count 条记录无法解析，将被跳过：';
  }

  @override
  String importMoreErrors(int count) {
    return '…等共 $count 条';
  }

  @override
  String get importNothing => '备份中没有可导入的数据。';

  @override
  String get importOverwrite => '覆盖重复';

  @override
  String get importSkip => '跳过重复';

  @override
  String get importButton => '导入';

  @override
  String recordErrorCard(int index, String detail) {
    return '第 $index 张卡片：$detail';
  }

  @override
  String recordErrorTag(int index, String detail) {
    return '第 $index 个标签：$detail';
  }

  @override
  String fieldErrorMissing(String field) {
    return '缺少字段 \"$field\"';
  }

  @override
  String fieldErrorNotText(String field) {
    return '字段 \"$field\" 应为文本';
  }

  @override
  String fieldErrorNotInteger(String field) {
    return '字段 \"$field\" 应为整数';
  }

  @override
  String fieldErrorNotNumber(String field) {
    return '字段 \"$field\" 应为数字';
  }

  @override
  String fieldErrorNotBoolean(String field) {
    return '字段 \"$field\" 应为布尔值';
  }

  @override
  String fieldErrorInvalidDate(String field) {
    return '字段 \"$field\" 不是有效的日期';
  }

  @override
  String fieldErrorNotObject(String field) {
    return '字段 \"$field\" 应为对象';
  }

  @override
  String fieldErrorNotTextList(String field) {
    return '字段 \"$field\" 应为文本列表';
  }

  @override
  String fieldErrorNotIntegerList(String field) {
    return '字段 \"$field\" 应为整数列表';
  }

  @override
  String get recordErrorInvalid => '记录格式错误';

  @override
  String get backupErrorFileTooLarge => '文件过大（超过 10 MB），不是有效的 SIMer 备份';

  @override
  String get backupErrorNotUtf8 => '文件编码不是 UTF-8，不是有效的 SIMer 备份';

  @override
  String get backupErrorUnreadable => '无法读取所选文件';

  @override
  String get backupErrorNotJson => '文件不是有效的 JSON，可能不是 SIMer 备份文件';

  @override
  String get backupErrorUnrecognized => '无法识别的备份文件';

  @override
  String get backupErrorNewerVersion => '该备份由更新版本的 SIMer 导出，请先升级应用后再导入';

  @override
  String get backupErrorUnsupportedVersion => '无法识别的备份格式版本';

  @override
  String get backupErrorMissingVersion => '无法识别的备份文件（缺少格式版本信息）';

  @override
  String get backupErrorCorrupted => '备份文件已损坏';

  @override
  String get backupErrorWrongPassword => '密码不正确，或文件已损坏';

  @override
  String get backupErrorUnsupportedEncryption => '这份加密备份使用了当前版本不支持的加密方式，请先升级应用';

  @override
  String get qrErrorEmpty => '内容为空';

  @override
  String get qrErrorNotActivationCode => '不是 eSIM 激活码（应以 LPA:1\$ 开头）';

  @override
  String qrErrorUnsupportedFormat(String version) {
    return '不支持的激活码格式版本「$version」';
  }

  @override
  String get qrErrorIncomplete => '激活码不完整，缺少 SM-DP+ 地址或匹配 ID';

  @override
  String get qrErrorEmptySmdp => 'SM-DP+ 地址为空';

  @override
  String qrErrorInvalidSmdp(String address) {
    return 'SM-DP+ 地址格式不正确：$address';
  }

  @override
  String get qrErrorEmptyMatchingId => '匹配 ID 为空';

  @override
  String get scanHint => '将 eSIM 二维码放入框内';

  @override
  String get scanTitle => '扫描 eSIM 二维码';

  @override
  String get scanTorch => '闪光灯';

  @override
  String get scanFromImage => '相册识别';

  @override
  String get scanPaste => '粘贴激活码';

  @override
  String get scanSwitchCamera => '切换镜头';

  @override
  String get scanPermissionDenied => '需要相机权限才能扫描二维码';

  @override
  String get scanCameraUnavailable => '相机无法启动';

  @override
  String get scanAlternatives => '也可以使用下方的「相册识别」或「粘贴激活码」。';

  @override
  String get scanOpenSettings => '去设置开启相机权限';

  @override
  String get scanNoQrInImage => '图片中没有识别到二维码';

  @override
  String get scanImageFailed => '无法识别这张图片';

  @override
  String get scanClipboardEmpty => '剪贴板中没有文本';

  @override
  String get scanResultTitle => '识别到 eSIM 激活码';

  @override
  String get fieldSmdpAddress => 'SM-DP+ 地址';

  @override
  String get scanResultMatchingId => '激活码（匹配 ID）';

  @override
  String get scanNeedsConfirmationCode =>
      '此 eSIM 安装时需要确认码。确认码不包含在二维码中，请向运营商获取后在表单中填写。';

  @override
  String get scanAgain => '重新扫描';

  @override
  String get scanUseResult => '使用此信息';

  @override
  String get formErrorIccid => 'ICCID 应为 18-22 位数字';

  @override
  String get formErrorNumber => '请输入有效的数字';

  @override
  String get formErrorNegative => '不能为负数';

  @override
  String get formErrorInteger => '请输入整数';

  @override
  String get formErrorDaysRequired => '请输入天数';

  @override
  String get formErrorDaysInteger => '请输入整数天数';

  @override
  String formErrorDaysRange(int min, int max) {
    return '天数应在 $min-$max 之间';
  }

  @override
  String get formErrorDateInFuture => '不能晚于今天';

  @override
  String get formErrorExpirationRequired => '请选择到期日期';

  @override
  String get formSectionUsage => '用量记录';

  @override
  String get formSectionEsim => 'eSIM 信息';

  @override
  String get formSectionAppearance => '外观与分类';

  @override
  String get formSectionHasErrors => '此分区有需要修改的内容';

  @override
  String get formClearDate => '清除日期';

  @override
  String get formEditTitle => '编辑SIM卡';

  @override
  String get formAddTitle => '添加SIM/eSIM信息';

  @override
  String get formCheckErrors => '请检查标红的内容';

  @override
  String get formSaveFailed => '保存失败，请重试';

  @override
  String get formDiscardTitle => '放弃未保存的修改？';

  @override
  String get formDiscardMessage => '离开后，本次填写的内容不会保存。';

  @override
  String get formKeepEditing => '继续编辑';

  @override
  String get formDiscard => '放弃';

  @override
  String get formSimType => 'SIM 卡类型';

  @override
  String get formActivationStatus => '激活状态';

  @override
  String get formCarrierHint => '选择或输入运营商';

  @override
  String get formCarrierRequired => '请选择或输入运营商';

  @override
  String get formIccidHint => '18-22 位数字，可含空格';

  @override
  String get formPhoneNumbers => '电话号码';

  @override
  String get formRemoveNumber => '删除此号码';

  @override
  String get formAddNumber => '添加号码';

  @override
  String get formValidityType => '有效期类型';

  @override
  String get formActivationDate => '激活日期';

  @override
  String get formActivationDateHint => '选择激活日期（可选）';

  @override
  String get formExpirationDate => '到期日期';

  @override
  String get formExpirationDateHint => '选择到期日期';

  @override
  String get formExpirationHelper => '到期日当天仍然有效';

  @override
  String get formRollingDays => '滚动天数';

  @override
  String get formRollingDaysHint => '例如 180';

  @override
  String get formDaysSuffix => '天';

  @override
  String get formRollingDaysHelper => '每次使用后，有效期从使用当天起重新计算这么多天';

  @override
  String get formLastUsedDate => '上次使用日期';

  @override
  String get formLastUsedHint => '未填写';

  @override
  String get formLastUsedHelper => '未填写时按激活日期计算；激活日期也未填写时按添加日期计算';

  @override
  String get formReminderDays => '提前提醒天数';

  @override
  String get formReminderDaysHint => '例如 7';

  @override
  String get formReminderDaysHelper => '到期前这么多天开始提醒，并显示为「即将到期」';

  @override
  String formExpirationPreview(String date, String status) {
    return '到期日：$date（$status）';
  }

  @override
  String get formDataRemaining => '流量剩余 (MB)';

  @override
  String get formDataTotal => '流量总量 (MB)';

  @override
  String get formDataRemainingHint => '例如 1024';

  @override
  String get formDataTotalHint => '例如 5120';

  @override
  String get formVoiceRemaining => '通话剩余（分钟）';

  @override
  String get formVoiceTotal => '通话总量（分钟）';

  @override
  String get formSmsRemaining => '短信剩余';

  @override
  String get formSmsTotal => '短信总量';

  @override
  String get formBalance => '话费余额';

  @override
  String get formCurrency => '币种';

  @override
  String get formSmdpAddress => 'SM-DP+ 服务器地址';

  @override
  String get formSmdpHint => '例如 rsp.example.com';

  @override
  String get formConfirmationHint => '如运营商提供';

  @override
  String get formConfirmationRequired =>
      '此 eSIM 的激活码标明安装时需要确认码（不在二维码中，由运营商另行提供）';

  @override
  String get formScanQr => '扫描/识别二维码';

  @override
  String get formCopiedActivationCode => '已复制完整激活码';

  @override
  String get formCopyActivationCode => '复制完整激活码';

  @override
  String get formCardColor => '卡片颜色';

  @override
  String get formChangeColor => '更改颜色';

  @override
  String get formTags => '标签';

  @override
  String get formNoTags => '还没有标签，可在「设置 → 标签管理」中添加';

  @override
  String get formSource => '来源渠道';

  @override
  String get formSourceHint => '例如：官网、线下门店、朋友转让';

  @override
  String get formNotesHint => '其他备忘信息';

  @override
  String reminderUpcomingTitle(String carrier, int days) {
    return '📅 $carrier 将在 $days 天后到期';
  }

  @override
  String reminderUpcomingBodyRolling(String date) {
    return '请在 $date 前使用一次以保号';
  }

  @override
  String reminderUpcomingBodyFixed(String date) {
    return '到期日：$date';
  }

  @override
  String reminderDueTodayTitle(String carrier) {
    return '⏰ $carrier 今天到期';
  }

  @override
  String get reminderDueTodayBodyRolling => '今天是最后期限，请使用一次以续期';

  @override
  String get reminderDueTodayBodyFixed => '请及时续费或处理';

  @override
  String reminderExpiredTitle(String carrier) {
    return '⚠️ $carrier 已过期';
  }

  @override
  String reminderExpiredBodyRolling(String date) {
    return '已超过保号期限 $date，请尽快确认号码状态';
  }

  @override
  String reminderExpiredBodyFixed(String date) {
    return '已于 $date 到期';
  }

  @override
  String get notificationChannelName => '到期提醒';

  @override
  String get notificationChannelDescription => 'SIM 卡即将到期、今天到期或已过期时提醒';

  @override
  String get settingsMaskSensitive => '隐藏敏感信息';

  @override
  String get settingsMaskSensitiveSubtitle =>
      'ICCID、eSIM 激活码与确认码默认部分隐藏，点击眼睛图标查看';

  @override
  String sensitiveShow(String field) {
    return '显示$field';
  }

  @override
  String sensitiveHide(String field) {
    return '隐藏$field';
  }

  @override
  String copyField(String field) {
    return '复制$field';
  }

  @override
  String get esimQrShow => '显示二维码';

  @override
  String get esimQrTitle => 'eSIM 二维码';

  @override
  String get esimQrSemantics => 'eSIM 激活码二维码';

  @override
  String get esimQrHint =>
      '在另一台设备上扫描此二维码安装 eSIM。大多数激活码只能使用一次：已经安装过的 eSIM 通常无法再次下载。';

  @override
  String get esimQrNeedsConfirmation => '安装时还需要输入确认码（见卡片详情中的「确认码」）。';
}
