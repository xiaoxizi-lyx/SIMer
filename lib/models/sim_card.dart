import 'package:clock/clock.dart';

import 'calendar_date.dart';
import 'enums.dart';
import 'feature_set.dart';
import 'json_utils.dart';

/// SIM卡主数据模型
///
/// 日期约定：
/// - [activationDate] / [expirationDate] / [lastUsedDate] 是日历日（本地 00:00），
///   存储为 `yyyy-MM-dd`；
/// - [createdAt] / [updatedAt] / [archivedAt] 是时间点，统一以 UTC 保存。
class SimCard {
  SimCard({
    this.id,
    required this.uuid,
    this.type = SimType.physicalSim,
    this.activationStatus = ActivationStatus.active,
    DateTime? archivedAt,
    this.iccid,
    required this.carrierName,
    this.carrierCode,
    required this.countryCode,
    List<String>? phoneNumbers,
    this.source,
    this.notes,
    this.validityType = ValidityType.noExpiration,
    DateTime? activationDate,
    DateTime? expirationDate,
    this.rollingDays,
    DateTime? lastUsedDate,
    this.reminderDaysBefore = defaultReminderDays,
    this.dataBalanceMB,
    this.dataTotalMB,
    this.voiceMinutesRemaining,
    this.voiceMinutesTotal,
    this.smsRemaining,
    this.smsTotal,
    this.balance,
    this.balanceCurrency,
    FeatureSet? features,
    this.rspServerAddress,
    this.activationCode,
    this.confirmationCode,
    this.qrCodeRawData,
    required this.cardColor,
    List<int>? tagIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : archivedAt = archivedAt?.toUtc(),
       phoneNumbers = phoneNumbers ?? [],
       activationDate = _calendarDate(activationDate),
       expirationDate = _calendarDate(expirationDate),
       lastUsedDate = _calendarDate(lastUsedDate),
       features = features ?? FeatureSet(),
       tagIds = tagIds ?? [],
       createdAt = (createdAt ?? clock.now()).toUtc(),
       updatedAt = (updatedAt ?? clock.now()).toUtc();

  /// 默认提前提醒天数。
  static const int defaultReminderDays = 7;

  /// 备份中缺少卡片颜色时使用的默认色（靛蓝紫）。
  static const int defaultCardColor = 0xFF5E5CE6;

  int? id;
  final String uuid;
  SimType type;

  /// 用户设置的激活状态。
  ActivationStatus activationStatus;

  /// 归档时间；为 null 表示未归档。
  DateTime? archivedAt;

  // ── 基本信息 ──
  String? iccid;
  String carrierName;
  String? carrierCode; // 预置运营商代码，自定义运营商为 null 或 custom_*
  String countryCode; // ISO 3166-1 alpha-2
  List<String> phoneNumbers;
  String? source; // 来源渠道
  String? notes; // 通用备注

  // ── 有效期 ──
  ValidityType validityType;
  DateTime? activationDate;
  DateTime? expirationDate; // fixedDate 模式
  int? rollingDays; // rolling 模式的天数
  DateTime? lastUsedDate; // rolling 模式的上次使用日
  int reminderDaysBefore; // 提前提醒天数

  // ── 手动记录的用量 ──
  double? dataBalanceMB;
  double? dataTotalMB;
  double? voiceMinutesRemaining;
  double? voiceMinutesTotal;
  int? smsRemaining;
  int? smsTotal;
  double? balance; // 话费余额
  String? balanceCurrency; // 币种

  // ── 功能支持 ──
  FeatureSet features;

  // ── eSIM 特有 ──
  String? rspServerAddress; // SM-DP+ 地址
  String? activationCode; // 匹配 ID（AC_Token）
  String? confirmationCode;
  String? qrCodeRawData;

  // ── 视觉 ──
  int cardColor; // ARGB 颜色值

  // ── 标签 ──
  List<int> tagIds;

  // ── 元数据 ──
  final DateTime createdAt;
  DateTime updatedAt;

  // ══════════════════════════════════════════
  // 计算属性
  // ══════════════════════════════════════════

  bool get isArchived => archivedAt != null;

  /// 滚动有效期的计算基准日：上次使用日 → 激活日 → 添加日。
  DateTime get rollingBaseDate =>
      lastUsedDate ?? activationDate ?? CalendarDate.of(createdAt);

  /// 实际到期日（日历日，到期日当天仍然有效）。无期限或缺少日期时为 null。
  DateTime? get effectiveExpirationDate {
    switch (validityType) {
      case ValidityType.fixedDate:
        return expirationDate;
      case ValidityType.rolling:
        final days = rollingDays;
        if (days == null || days <= 0) return null;
        return CalendarDate.addDays(rollingBaseDate, days);
      case ValidityType.noExpiration:
        return null;
    }
  }

  /// 在 [today] 这天距到期日的天数：0 表示当天到期（仍有效），负数表示已过期天数。
  int? daysRemainingOn(DateTime today) {
    final expiration = effectiveExpirationDate;
    if (expiration == null) return null;
    return CalendarDate.daysBetween(today, expiration);
  }

  /// 距到期日的天数（以今天为准）。
  int? get daysRemaining => daysRemainingOn(CalendarDate.today());

  ValidityState validityStateOn(DateTime today) {
    if (validityType == ValidityType.noExpiration) {
      return ValidityState.unlimited;
    }
    final days = daysRemainingOn(today);
    if (days == null) return ValidityState.unknown;
    if (days < 0) return ValidityState.expired;
    if (days <= reminderDaysBefore.clamp(0, 3650)) {
      return ValidityState.expiringSoon;
    }
    return ValidityState.valid;
  }

  /// 当前有效性（以今天为准）。
  ValidityState get validityState => validityStateOn(CalendarDate.today());

  bool get isExpired => validityState == ValidityState.expired;

  bool get isExpiringSoon => validityState == ValidityState.expiringSoon;

  /// 主号码（用于卡片显示）
  String? get primaryNumber =>
      phoneNumbers.isNotEmpty ? phoneNumbers.first : null;

  /// 格式化 ICCID（每4位一空格，类似银行卡号）
  String? get formattedIccid {
    final value = iccid;
    if (value == null || value.isEmpty) return null;
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(value[i]);
    }
    return buffer.toString();
  }

  /// 更新修改时间。
  void touch() => updatedAt = clock.now().toUtc();

  // ══════════════════════════════════════════
  // 序列化
  // ══════════════════════════════════════════

  static DateTime? _calendarDate(DateTime? value) =>
      value == null ? null : CalendarDate.of(value);

  static String? _formatDate(DateTime? value) =>
      value == null ? null : CalendarDate.format(value);

  static DateTime? _parseTimestamp(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toUtc() : null;

  /// 转为数据库 Map（不含 phoneNumbers 和 tagIds，这些在关联表中）
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'uuid': uuid,
    'type': type.name,
    'activation_status': activationStatus.name,
    'archived_at': archivedAt?.toIso8601String(),
    'iccid': iccid,
    'carrier_name': carrierName,
    'carrier_code': carrierCode,
    'country_code': countryCode,
    'source': source,
    'notes': notes,
    'validity_type': validityType.name,
    'activation_date': _formatDate(activationDate),
    'expiration_date': _formatDate(expirationDate),
    'rolling_days': rollingDays,
    'last_used_date': _formatDate(lastUsedDate),
    'reminder_days_before': reminderDaysBefore,
    'data_balance_mb': dataBalanceMB,
    'data_total_mb': dataTotalMB,
    'voice_minutes_remaining': voiceMinutesRemaining,
    'voice_minutes_total': voiceMinutesTotal,
    'sms_remaining': smsRemaining,
    'sms_total': smsTotal,
    'balance': balance,
    'balance_currency': balanceCurrency,
    'features': features.toJsonString(),
    'rsp_server_address': rspServerAddress,
    'activation_code': activationCode,
    'confirmation_code': confirmationCode,
    'qr_code_raw_data': qrCodeRawData,
    'card_color': cardColor,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory SimCard.fromMap(
    Map<String, Object?> map, {
    List<String>? phoneNumbers,
    List<int>? tagIds,
  }) {
    final features = map['features'];
    return SimCard(
      id: map['id'] as int?,
      uuid: map['uuid']! as String,
      type: SimType.fromString(map['type'] as String?),
      activationStatus: ActivationStatus.fromString(
        map['activation_status'] as String?,
      ),
      archivedAt: _parseTimestamp(map['archived_at']),
      iccid: map['iccid'] as String?,
      carrierName: map['carrier_name']! as String,
      carrierCode: map['carrier_code'] as String?,
      countryCode: map['country_code']! as String,
      phoneNumbers: phoneNumbers,
      source: map['source'] as String?,
      notes: map['notes'] as String?,
      validityType: ValidityType.fromString(map['validity_type'] as String?),
      activationDate: CalendarDate.tryParse(map['activation_date'] as String?),
      expirationDate: CalendarDate.tryParse(map['expiration_date'] as String?),
      rollingDays: map['rolling_days'] as int?,
      lastUsedDate: CalendarDate.tryParse(map['last_used_date'] as String?),
      reminderDaysBefore:
          map['reminder_days_before'] as int? ?? defaultReminderDays,
      dataBalanceMB: (map['data_balance_mb'] as num?)?.toDouble(),
      dataTotalMB: (map['data_total_mb'] as num?)?.toDouble(),
      voiceMinutesRemaining: (map['voice_minutes_remaining'] as num?)
          ?.toDouble(),
      voiceMinutesTotal: (map['voice_minutes_total'] as num?)?.toDouble(),
      smsRemaining: map['sms_remaining'] as int?,
      smsTotal: map['sms_total'] as int?,
      balance: (map['balance'] as num?)?.toDouble(),
      balanceCurrency: map['balance_currency'] as String?,
      features: features is String && features.isNotEmpty
          ? FeatureSet.fromJsonString(features)
          : null,
      rspServerAddress: map['rsp_server_address'] as String?,
      activationCode: map['activation_code'] as String?,
      confirmationCode: map['confirmation_code'] as String?,
      qrCodeRawData: map['qr_code_raw_data'] as String?,
      cardColor: map['card_color']! as int,
      tagIds: tagIds,
      createdAt: _parseTimestamp(map['created_at']),
      updatedAt: _parseTimestamp(map['updated_at']),
    );
  }

  /// 转为 JSON（用于导出备份，包含号码与标签引用）
  Map<String, Object?> toJson() => {
    'uuid': uuid,
    'type': type.name,
    'activationStatus': activationStatus.name,
    'archivedAt': archivedAt?.toIso8601String(),
    'iccid': iccid,
    'carrierName': carrierName,
    'carrierCode': carrierCode,
    'countryCode': countryCode,
    'phoneNumbers': phoneNumbers,
    'source': source,
    'notes': notes,
    'validityType': validityType.name,
    'activationDate': _formatDate(activationDate),
    'expirationDate': _formatDate(expirationDate),
    'rollingDays': rollingDays,
    'lastUsedDate': _formatDate(lastUsedDate),
    'reminderDaysBefore': reminderDaysBefore,
    'dataBalanceMB': dataBalanceMB,
    'dataTotalMB': dataTotalMB,
    'voiceMinutesRemaining': voiceMinutesRemaining,
    'voiceMinutesTotal': voiceMinutesTotal,
    'smsRemaining': smsRemaining,
    'smsTotal': smsTotal,
    'balance': balance,
    'balanceCurrency': balanceCurrency,
    'features': features.toJson(),
    'rspServerAddress': rspServerAddress,
    'activationCode': activationCode,
    'confirmationCode': confirmationCode,
    'qrCodeRawData': qrCodeRawData,
    'cardColor': cardColor,
    'tagIds': tagIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// 从备份 JSON 解析（兼容 SIMer 1.0 格式）。
  ///
  /// 字段缺失时使用默认值；字段类型错误时抛出 [FormatException]。
  factory SimCard.fromJson(Map<String, dynamic> json) {
    final features = json.optMap('features');
    final updatedAt = json.optDateTime('updatedAt');

    // SIMer 1.0 把「已过期 / 已归档」也混在 status 字段里：
    // 过期改为按日期实时计算；归档改用归档时间，原激活状态已无法得知，按未激活处理。
    final legacyStatus = json.optString('status');
    final activationStatus = json.containsKey('activationStatus')
        ? ActivationStatus.fromString(json.optString('activationStatus'))
        : (legacyStatus == 'inactive' || legacyStatus == 'archived'
              ? ActivationStatus.inactive
              : ActivationStatus.active);
    final archivedAt = json.containsKey('archivedAt')
        ? json.optDateTime('archivedAt')
        : (legacyStatus == 'archived' ? (updatedAt ?? clock.now()) : null);

    return SimCard(
      uuid: json.reqString('uuid'),
      type: SimType.fromString(json.optString('type')),
      activationStatus: activationStatus,
      archivedAt: archivedAt,
      iccid: json.optString('iccid'),
      carrierName: json.reqString('carrierName'),
      carrierCode: json.optString('carrierCode'),
      countryCode: json.optString('countryCode') ?? '',
      phoneNumbers: json.stringList('phoneNumbers'),
      source: json.optString('source'),
      notes: json.optString('notes'),
      validityType: ValidityType.fromString(json.optString('validityType')),
      activationDate: json.optCalendarDate('activationDate'),
      expirationDate: json.optCalendarDate('expirationDate'),
      rollingDays: json.optInt('rollingDays'),
      lastUsedDate: json.optCalendarDate('lastUsedDate'),
      reminderDaysBefore:
          json.optInt('reminderDaysBefore') ?? defaultReminderDays,
      dataBalanceMB: json.optDouble('dataBalanceMB'),
      dataTotalMB: json.optDouble('dataTotalMB'),
      voiceMinutesRemaining: json.optDouble('voiceMinutesRemaining'),
      voiceMinutesTotal: json.optDouble('voiceMinutesTotal'),
      smsRemaining: json.optInt('smsRemaining'),
      smsTotal: json.optInt('smsTotal'),
      balance: json.optDouble('balance'),
      balanceCurrency: json.optString('balanceCurrency'),
      features: features != null ? FeatureSet.fromJson(features) : null,
      rspServerAddress: json.optString('rspServerAddress'),
      activationCode: json.optString('activationCode'),
      confirmationCode: json.optString('confirmationCode'),
      qrCodeRawData: json.optString('qrCodeRawData'),
      cardColor: json.optInt('cardColor') ?? defaultCardColor,
      tagIds: json.intList('tagIds'),
      createdAt: json.optDateTime('createdAt'),
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'SimCard(id: $id, uuid: $uuid, carrier: $carrierName)';
}
