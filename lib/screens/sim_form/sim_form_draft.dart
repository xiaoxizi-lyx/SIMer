import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/carriers.dart';
import '../../models/calendar_date.dart';
import '../../models/carrier.dart';
import '../../models/enums.dart';
import '../../models/feature_set.dart';
import '../../models/sim_card.dart';
import '../../services/qr_parser_service.dart';
import '../../theme/app_colors.dart';
import 'sim_form_validators.dart';

/// 表单分区。
enum SimFormSection {
  basic(Icons.sim_card_outlined),
  validity(Icons.calendar_today_rounded),
  usage(Icons.data_usage_rounded),
  features(Icons.checklist_rounded),
  esim(Icons.qr_code_rounded),
  appearance(Icons.palette_rounded);

  const SimFormSection(this.icon);
  final IconData icon;
}

/// 添加/编辑 SIM 卡表单的全部状态。
///
/// 文本字段统一使用 [TextEditingController]，分区折叠/展开不会丢失输入；
/// 保存前用 [invalidSections] 对所有分区做校验，不依赖分区是否展开。
class SimFormDraft extends ChangeNotifier {
  /// 新建卡片。
  SimFormDraft.create({required this._usedColors})
    : original = null,
      type = SimType.physicalSim,
      activationStatus = ActivationStatus.active,
      carrierName = '',
      countryCode = 'CN',
      validityType = ValidityType.noExpiration,
      cardColor = AppColors.pickUniqueColor(_usedColors),
      colorAutoAssigned = true,
      tagIds = <int>{},
      features = FeatureSet() {
    phones.add(TextEditingController());
    rollingDays.text = '30';
    reminderDays.text = '${SimCard.defaultReminderDays}';
    _initialFingerprint = _fingerprint();
  }

  /// 编辑已有卡片（原卡片对象不会被修改，保存时生成新对象）。
  SimFormDraft.edit(SimCard card, {required this._usedColors})
    : original = card,
      type = card.type,
      activationStatus = card.activationStatus,
      carrierCode = card.carrierCode,
      carrierName = card.carrierName,
      countryCode = card.countryCode,
      validityType = card.validityType,
      activationDate = card.activationDate,
      expirationDate = card.expirationDate,
      lastUsedDate = card.lastUsedDate,
      cardColor = Color(card.cardColor),
      colorAutoAssigned = false,
      tagIds = card.tagIds.toSet(),
      features = card.features.copy(),
      qrCodeRawData = card.qrCodeRawData {
    iccid.text = card.iccid ?? '';
    for (final number in card.phoneNumbers) {
      phones.add(TextEditingController(text: number));
    }
    if (phones.isEmpty) phones.add(TextEditingController());
    source.text = card.source ?? '';
    notes.text = card.notes ?? '';
    rollingDays.text = '${card.rollingDays ?? 30}';
    reminderDays.text = '${card.reminderDaysBefore}';
    dataBalance.text = _formatNumber(card.dataBalanceMB);
    dataTotal.text = _formatNumber(card.dataTotalMB);
    voiceRemaining.text = _formatNumber(card.voiceMinutesRemaining);
    voiceTotal.text = _formatNumber(card.voiceMinutesTotal);
    smsRemaining.text = card.smsRemaining?.toString() ?? '';
    smsTotal.text = card.smsTotal?.toString() ?? '';
    balance.text = _formatNumber(card.balance);
    currency.text = card.balanceCurrency ?? '';
    smdpAddress.text = card.rspServerAddress ?? '';
    matchingId.text = card.activationCode ?? '';
    confirmationCode.text = card.confirmationCode ?? '';
    final lpa = card.qrCodeRawData;
    confirmationCodeRequired =
        lpa != null &&
        (QrParserService.parse(lpa).code?.confirmationCodeRequired ?? false);
    _initialFingerprint = _fingerprint();
  }

  final SimCard? original;
  final Set<int> _usedColors;
  late final String _initialFingerprint;

  bool get isEditing => original != null;

  // ── 选择类字段（修改请通过 [update]，以便刷新界面） ──
  SimType type;
  ActivationStatus activationStatus;
  String? carrierCode;
  String carrierName;
  String countryCode;
  ValidityType validityType;
  DateTime? activationDate;
  DateTime? expirationDate;
  DateTime? lastUsedDate;
  Color cardColor;

  /// 颜色仍是自动分配的（用户未手动选过），更换运营商时可以跟着变。
  bool colorAutoAssigned;
  final Set<int> tagIds;
  final FeatureSet features;
  String? qrCodeRawData;
  bool confirmationCodeRequired = false;

  // ── 文本字段 ──
  final iccid = TextEditingController();
  final phones = <TextEditingController>[];
  final source = TextEditingController();
  final notes = TextEditingController();
  final rollingDays = TextEditingController();
  final reminderDays = TextEditingController();
  final dataBalance = TextEditingController();
  final dataTotal = TextEditingController();
  final voiceRemaining = TextEditingController();
  final voiceTotal = TextEditingController();
  final smsRemaining = TextEditingController();
  final smsTotal = TextEditingController();
  final balance = TextEditingController();
  final currency = TextEditingController();
  final smdpAddress = TextEditingController();
  final matchingId = TextEditingController();
  final confirmationCode = TextEditingController();

  /// 修改选择类字段并刷新界面。
  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  void addPhone() => update(() => phones.add(TextEditingController()));

  void removePhone(int index) => update(() => phones.removeAt(index).dispose());

  void chooseCarrier(CarrierChoice choice) => update(() {
    switch (choice) {
      case PresetCarrierChoice(:final carrier):
        carrierCode = carrier.code;
        carrierName = carrier.name;
        countryCode = carrier.countryCode;
        if (colorAutoAssigned) cardColor = carrier.themeColor;
      case CustomCarrierChoice(:final name):
        carrierCode = null;
        carrierName = name;
        // 自定义运营商保留已选的国家/地区，并分配一个与其他卡片不冲突的颜色
        if (colorAutoAssigned) {
          cardColor = AppColors.pickUniqueColor(_usedColors);
        }
    }
  });

  void chooseColor(Color color) => update(() {
    cardColor = color;
    colorAutoAssigned = false;
  });

  /// 填入扫描或粘贴得到的 eSIM 激活码。确认码不在激活码中，保持用户已填的内容。
  void applyActivationCode(QrParseResult result) {
    final code = result.code;
    if (code == null) return;
    update(() {
      type = SimType.esim;
      smdpAddress.text = code.smdpAddress;
      matchingId.text = code.matchingId;
      qrCodeRawData = code.toLpaString();
      confirmationCodeRequired = code.confirmationCodeRequired;
    });
  }

  /// 预置运营商的推荐颜色（自定义运营商为 null）。
  Color? get carrierDefaultColor => carrierCode == null
      ? null
      : CarrierData.findByCode(carrierCode!)?.themeColor;

  // ── 校验 ──

  /// 有错误的分区（与是否展开无关）。
  Set<SimFormSection> invalidSections({DateTime? today}) {
    final day = today ?? CalendarDate.today();
    final invalid = <SimFormSection>{};

    if (carrierName.trim().isEmpty ||
        SimFormValidators.iccid(iccid.text) != null) {
      invalid.add(SimFormSection.basic);
    }

    final validityErrors = [
      if (validityType == ValidityType.fixedDate && expirationDate == null)
        FieldError.expirationRequired,
      if (validityType == ValidityType.rolling) ...[
        SimFormValidators.rollingDays(rollingDays.text),
        SimFormValidators.lastUsedDate(lastUsedDate, day),
      ],
      if (validityType != ValidityType.noExpiration)
        SimFormValidators.reminderDays(reminderDays.text),
    ];
    if (validityErrors.any((e) => e != null)) {
      invalid.add(SimFormSection.validity);
    }

    final usageErrors = [
      for (final c in [
        dataBalance,
        dataTotal,
        voiceRemaining,
        voiceTotal,
        balance,
      ])
        SimFormValidators.decimal(c.text),
      for (final c in [smsRemaining, smsTotal])
        SimFormValidators.integer(c.text),
    ];
    if (usageErrors.any((e) => e != null)) invalid.add(SimFormSection.usage);

    return invalid;
  }

  // ── 生成卡片 ──

  /// 用当前表单内容生成卡片。新卡片使用 [newUuid]。
  SimCard build({required String newUuid}) {
    String? text(TextEditingController c) {
      final value = c.text.trim();
      return value.isEmpty ? null : value;
    }

    double? decimal(TextEditingController c) =>
        SimFormValidators.parseDecimal(c.text);
    int? integer(TextEditingController c) => SimFormValidators.parseInt(c.text);

    final iccidValue = SimFormValidators.normalizeIccid(iccid.text);
    final isRolling = validityType == ValidityType.rolling;
    final isEsim = type == SimType.esim;

    return SimCard(
      id: original?.id,
      uuid: original?.uuid ?? newUuid,
      type: type,
      activationStatus: activationStatus,
      archivedAt: original?.archivedAt,
      iccid: iccidValue.isEmpty ? null : iccidValue,
      carrierName: carrierName.trim(),
      carrierCode: carrierCode,
      countryCode: countryCode,
      phoneNumbers: [
        for (final c in phones)
          if (c.text.trim().isNotEmpty) c.text.trim(),
      ],
      source: text(source),
      notes: text(notes),
      validityType: validityType,
      activationDate: activationDate,
      expirationDate: validityType == ValidityType.fixedDate
          ? expirationDate
          : null,
      rollingDays: isRolling ? integer(rollingDays) : null,
      lastUsedDate: isRolling ? lastUsedDate : null,
      reminderDaysBefore:
          integer(reminderDays) ??
          original?.reminderDaysBefore ??
          SimCard.defaultReminderDays,
      dataBalanceMB: decimal(dataBalance),
      dataTotalMB: decimal(dataTotal),
      voiceMinutesRemaining: decimal(voiceRemaining),
      voiceMinutesTotal: decimal(voiceTotal),
      smsRemaining: integer(smsRemaining),
      smsTotal: integer(smsTotal),
      balance: decimal(balance),
      balanceCurrency: text(currency),
      features: features.copy(),
      rspServerAddress: isEsim ? text(smdpAddress) : null,
      activationCode: isEsim ? text(matchingId) : null,
      confirmationCode: isEsim ? text(confirmationCode) : null,
      qrCodeRawData: isEsim ? qrCodeRawData : null,
      cardColor: cardColor.toARGB32(),
      tagIds: tagIds.toList(),
      createdAt: original?.createdAt,
    );
  }

  /// 与打开表单时相比是否有改动（用于离开前确认）。
  bool get hasChanges => _fingerprint() != _initialFingerprint;

  String _fingerprint() {
    final json = build(newUuid: '_draft').toJson()
      ..remove('createdAt')
      ..remove('updatedAt');
    return jsonEncode(json);
  }

  static String _formatNumber(double? value) {
    if (value == null) return '';
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  void dispose() {
    for (final c in [
      iccid,
      ...phones,
      source,
      notes,
      rollingDays,
      reminderDays,
      dataBalance,
      dataTotal,
      voiceRemaining,
      voiceTotal,
      smsRemaining,
      smsTotal,
      balance,
      currency,
      smdpAddress,
      matchingId,
      confirmationCode,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
