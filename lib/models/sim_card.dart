import 'enums.dart';
import 'feature_set.dart';

/// SIM卡主数据模型
class SimCard {
  int? id;
  final String uuid;
  SimType type;
  SimStatus status;

  // ── 基本信息 ──
  String? iccid;
  String carrierName;
  String? carrierCode; // 预置运营商代码，自定义运营商为 null
  String countryCode; // ISO 3166-1 alpha-2
  List<String> phoneNumbers;
  String? source; // 来源渠道
  String? notes; // 通用备注

  // ── 有效期 ──
  ValidityType validityType;
  DateTime? activationDate;
  DateTime? expirationDate; // fixedDate 模式
  int? rollingDays; // rolling 模式的天数
  DateTime? lastUsedDate; // rolling 模式的上次使用时间
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
  String? activationCode; // 匹配 ID
  String? confirmationCode;
  String? qrCodeRawData;

  // ── 视觉 ──
  int cardColor; // ARGB 颜色值

  // ── 标签 ──
  List<int> tagIds;

  // ── 照片 ──
  String? photoPath;

  // ── 元数据 ──
  DateTime createdAt;
  DateTime updatedAt;

  SimCard({
    this.id,
    required this.uuid,
    this.type = SimType.physicalSim,
    this.status = SimStatus.inactive,
    this.iccid,
    required this.carrierName,
    this.carrierCode,
    required this.countryCode,
    List<String>? phoneNumbers,
    this.source,
    this.notes,
    this.validityType = ValidityType.noExpiration,
    this.activationDate,
    this.expirationDate,
    this.rollingDays,
    this.lastUsedDate,
    this.reminderDaysBefore = 7,
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
    this.photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : phoneNumbers = phoneNumbers ?? [],
        features = features ?? FeatureSet(),
        tagIds = tagIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ── 计算属性 ──

  /// 实际到期日（根据有效期类型计算）
  DateTime? get effectiveExpirationDate {
    switch (validityType) {
      case ValidityType.fixedDate:
        return expirationDate;
      case ValidityType.rolling:
        if (lastUsedDate != null && rollingDays != null) {
          return lastUsedDate!.add(Duration(days: rollingDays!));
        }
        if (activationDate != null && rollingDays != null) {
          return activationDate!.add(Duration(days: rollingDays!));
        }
        return null;
      case ValidityType.noExpiration:
        return null;
    }
  }

  /// 剩余天数（null = 无期限，基于日历天对齐计算）
  int? get daysRemaining {
    final expDate = effectiveExpirationDate;
    if (expDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expDate.year, expDate.month, expDate.day);
    return target.difference(today).inDays;
  }

  /// 是否已过期（根据精确时间戳比较，避免整除小时导致的截断偏差）
  bool get isExpired {
    final expDate = effectiveExpirationDate;
    if (expDate == null) return false;
    return expDate.isBefore(DateTime.now());
  }

  /// 是否需要提醒
  bool get needsReminder {
    if (isExpired) return true;
    final days = daysRemaining;
    if (days == null) return false;
    return days >= 0 && days <= reminderDaysBefore;
  }

  /// 主号码（用于卡片显示）
  String? get primaryNumber =>
      phoneNumbers.isNotEmpty ? phoneNumbers.first : null;

  /// 格式化 ICCID（每4位一空格，类似银行卡号）
  String? get formattedIccid {
    if (iccid == null || iccid!.isEmpty) return null;
    final buffer = StringBuffer();
    for (int i = 0; i < iccid!.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(iccid![i]);
    }
    return buffer.toString();
  }

  // ── 滚动有效期操作 ──

  /// 标记为"已使用"，更新 lastUsedDate 并重置到期日
  void markAsUsed() {
    if (validityType == ValidityType.rolling) {
      lastUsedDate = DateTime.now();
      updatedAt = DateTime.now();
      // 如果之前过期了，恢复为激活
      if (status == SimStatus.expired) {
        status = SimStatus.active;
      }
    }
  }

  // ── 序列化 ──

  /// 转为数据库 Map（不含 phoneNumbers 和 tagIds，这些在关联表中）
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'uuid': uuid,
        'type': type.name,
        'status': status.name,
        'iccid': iccid,
        'carrier_name': carrierName,
        'carrier_code': carrierCode,
        'country_code': countryCode,
        'source': source,
        'notes': notes,
        'validity_type': validityType.name,
        'activation_date': activationDate?.toIso8601String(),
        'expiration_date': expirationDate?.toIso8601String(),
        'rolling_days': rollingDays,
        'last_used_date': lastUsedDate?.toIso8601String(),
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
        'photo_path': photoPath,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory SimCard.fromMap(
    Map<String, dynamic> map, {
    List<String>? phoneNumbers,
    List<int>? tagIds,
  }) =>
      SimCard(
        id: map['id'] as int?,
        uuid: map['uuid'] as String,
        type: SimType.fromString(map['type'] as String),
        status: SimStatus.fromString(map['status'] as String),
        iccid: map['iccid'] as String?,
        carrierName: map['carrier_name'] as String,
        carrierCode: map['carrier_code'] as String?,
        countryCode: map['country_code'] as String,
        phoneNumbers: phoneNumbers,
        source: map['source'] as String?,
        notes: map['notes'] as String?,
        validityType: ValidityType.fromString(map['validity_type'] as String),
        activationDate: map['activation_date'] != null
            ? DateTime.parse(map['activation_date'] as String)
            : null,
        expirationDate: map['expiration_date'] != null
            ? DateTime.parse(map['expiration_date'] as String)
            : null,
        rollingDays: map['rolling_days'] as int?,
        lastUsedDate: map['last_used_date'] != null
            ? DateTime.parse(map['last_used_date'] as String)
            : null,
        reminderDaysBefore: map['reminder_days_before'] as int? ?? 7,
        dataBalanceMB: (map['data_balance_mb'] as num?)?.toDouble(),
        dataTotalMB: (map['data_total_mb'] as num?)?.toDouble(),
        voiceMinutesRemaining:
            (map['voice_minutes_remaining'] as num?)?.toDouble(),
        voiceMinutesTotal: (map['voice_minutes_total'] as num?)?.toDouble(),
        smsRemaining: map['sms_remaining'] as int?,
        smsTotal: map['sms_total'] as int?,
        balance: (map['balance'] as num?)?.toDouble(),
        balanceCurrency: map['balance_currency'] as String?,
        features: map['features'] != null
            ? FeatureSet.fromJsonString(map['features'] as String)
            : null,
        rspServerAddress: map['rsp_server_address'] as String?,
        activationCode: map['activation_code'] as String?,
        confirmationCode: map['confirmation_code'] as String?,
        qrCodeRawData: map['qr_code_raw_data'] as String?,
        cardColor: map['card_color'] as int,
        tagIds: tagIds,
        photoPath: map['photo_path'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  /// 转为 JSON（用于导出，包含所有关联数据）
  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'type': type.name,
        'status': status.name,
        'iccid': iccid,
        'carrierName': carrierName,
        'carrierCode': carrierCode,
        'countryCode': countryCode,
        'phoneNumbers': phoneNumbers,
        'source': source,
        'notes': notes,
        'validityType': validityType.name,
        'activationDate': activationDate?.toIso8601String(),
        'expirationDate': expirationDate?.toIso8601String(),
        'rollingDays': rollingDays,
        'lastUsedDate': lastUsedDate?.toIso8601String(),
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
        'photoPath': photoPath,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SimCard.fromJson(Map<String, dynamic> json) => SimCard(
        uuid: json['uuid'] as String,
        type: SimType.fromString(json['type'] as String),
        status: SimStatus.fromString(json['status'] as String),
        iccid: json['iccid'] as String?,
        carrierName: json['carrierName'] as String,
        carrierCode: json['carrierCode'] as String?,
        countryCode: json['countryCode'] as String,
        phoneNumbers: (json['phoneNumbers'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        source: json['source'] as String?,
        notes: json['notes'] as String?,
        validityType: ValidityType.fromString(json['validityType'] as String),
        activationDate: json['activationDate'] != null
            ? DateTime.parse(json['activationDate'] as String)
            : null,
        expirationDate: json['expirationDate'] != null
            ? DateTime.parse(json['expirationDate'] as String)
            : null,
        rollingDays: json['rollingDays'] as int?,
        lastUsedDate: json['lastUsedDate'] != null
            ? DateTime.parse(json['lastUsedDate'] as String)
            : null,
        reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 7,
        dataBalanceMB: (json['dataBalanceMB'] as num?)?.toDouble(),
        dataTotalMB: (json['dataTotalMB'] as num?)?.toDouble(),
        voiceMinutesRemaining:
            (json['voiceMinutesRemaining'] as num?)?.toDouble(),
        voiceMinutesTotal: (json['voiceMinutesTotal'] as num?)?.toDouble(),
        smsRemaining: json['smsRemaining'] as int?,
        smsTotal: json['smsTotal'] as int?,
        balance: (json['balance'] as num?)?.toDouble(),
        balanceCurrency: json['balanceCurrency'] as String?,
        features: json['features'] != null
            ? FeatureSet.fromJson(json['features'] as Map<String, dynamic>)
            : null,
        rspServerAddress: json['rspServerAddress'] as String?,
        activationCode: json['activationCode'] as String?,
        confirmationCode: json['confirmationCode'] as String?,
        qrCodeRawData: json['qrCodeRawData'] as String?,
        cardColor: json['cardColor'] as int,
        tagIds: (json['tagIds'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        photoPath: json['photoPath'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  SimCard copyWith({
    int? id,
    String? uuid,
    SimType? type,
    SimStatus? status,
    String? iccid,
    String? carrierName,
    String? carrierCode,
    String? countryCode,
    List<String>? phoneNumbers,
    String? source,
    String? notes,
    ValidityType? validityType,
    DateTime? activationDate,
    DateTime? expirationDate,
    int? rollingDays,
    DateTime? lastUsedDate,
    int? reminderDaysBefore,
    double? dataBalanceMB,
    double? dataTotalMB,
    double? voiceMinutesRemaining,
    double? voiceMinutesTotal,
    int? smsRemaining,
    int? smsTotal,
    double? balance,
    String? balanceCurrency,
    FeatureSet? features,
    String? rspServerAddress,
    String? activationCode,
    String? confirmationCode,
    String? qrCodeRawData,
    int? cardColor,
    List<int>? tagIds,
    String? photoPath,
  }) =>
      SimCard(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        type: type ?? this.type,
        status: status ?? this.status,
        iccid: iccid ?? this.iccid,
        carrierName: carrierName ?? this.carrierName,
        carrierCode: carrierCode ?? this.carrierCode,
        countryCode: countryCode ?? this.countryCode,
        phoneNumbers: phoneNumbers ?? List.from(this.phoneNumbers),
        source: source ?? this.source,
        notes: notes ?? this.notes,
        validityType: validityType ?? this.validityType,
        activationDate: activationDate ?? this.activationDate,
        expirationDate: expirationDate ?? this.expirationDate,
        rollingDays: rollingDays ?? this.rollingDays,
        lastUsedDate: lastUsedDate ?? this.lastUsedDate,
        reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
        dataBalanceMB: dataBalanceMB ?? this.dataBalanceMB,
        dataTotalMB: dataTotalMB ?? this.dataTotalMB,
        voiceMinutesRemaining:
            voiceMinutesRemaining ?? this.voiceMinutesRemaining,
        voiceMinutesTotal: voiceMinutesTotal ?? this.voiceMinutesTotal,
        smsRemaining: smsRemaining ?? this.smsRemaining,
        smsTotal: smsTotal ?? this.smsTotal,
        balance: balance ?? this.balance,
        balanceCurrency: balanceCurrency ?? this.balanceCurrency,
        features: features ?? this.features.copyWith(),
        rspServerAddress: rspServerAddress ?? this.rspServerAddress,
        activationCode: activationCode ?? this.activationCode,
        confirmationCode: confirmationCode ?? this.confirmationCode,
        qrCodeRawData: qrCodeRawData ?? this.qrCodeRawData,
        cardColor: cardColor ?? this.cardColor,
        tagIds: tagIds ?? List.from(this.tagIds),
        photoPath: photoPath ?? this.photoPath,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  @override
  String toString() => 'SimCard(id: $id, carrier: $carrierName, iccid: $iccid)';
}
