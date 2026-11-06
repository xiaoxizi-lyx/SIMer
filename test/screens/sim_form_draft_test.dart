import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sim_keeper/data/carriers.dart';
import 'package:sim_keeper/models/carrier.dart';
import 'package:sim_keeper/models/enums.dart';
import 'package:sim_keeper/models/feature_set.dart';
import 'package:sim_keeper/models/sim_card.dart';
import 'package:sim_keeper/screens/sim_form/sim_form_draft.dart';
import 'package:sim_keeper/screens/sim_form/sim_form_validators.dart';
import 'package:sim_keeper/services/qr_parser_service.dart';

void main() {
  group('SimFormValidators', () {
    test('ICCID 允许空格，校验去空格后的位数', () {
      expect(SimFormValidators.iccid('8986 0012 3456 7890 1234'), isNull);
      expect(SimFormValidators.iccid('12345'), isNotNull);
      expect(SimFormValidators.iccid(''), isNull);
    });

    test('数字字段允许千分位，拒绝非数字与负数', () {
      expect(SimFormValidators.parseDecimal('1,024'), 1024);
      expect(SimFormValidators.decimal('abc'), isNotNull);
      expect(SimFormValidators.decimal('-5'), isNotNull);
      expect(SimFormValidators.integer('1.5'), isNotNull);
    });

    test('滚动天数与提醒天数有范围限制', () {
      expect(SimFormValidators.rollingDays('0'), isNotNull);
      expect(SimFormValidators.rollingDays('180'), isNull);
      expect(SimFormValidators.rollingDays(''), isNotNull);
      expect(SimFormValidators.reminderDays('-1'), isNotNull);
      expect(SimFormValidators.reminderDays('0'), isNull);
    });
  });

  group('SimFormDraft', () {
    test('校验不依赖分区是否展开：非法 ICCID 标记基本信息分区', () {
      final draft = SimFormDraft.create(usedColors: {})
        ..carrierName = 'Three'
        ..iccid.text = '123';
      expect(draft.invalidSections(), {SimFormSection.basic});
      draft.iccid.text = '8985 2000 0000 0000 0001';
      expect(draft.invalidSections(), isEmpty);
    });

    test('固定到期日必须选择日期，滚动天数必须合法', () {
      final draft = SimFormDraft.create(usedColors: {})
        ..carrierName = 'A'
        ..validityType = ValidityType.fixedDate;
      expect(draft.invalidSections(), contains(SimFormSection.validity));
      draft
        ..validityType = ValidityType.rolling
        ..rollingDays.text = '0';
      expect(draft.invalidSections(), contains(SimFormSection.validity));
    });

    test('生成卡片时规范化输入并丢弃隐藏字段', () {
      final draft = SimFormDraft.create(usedColors: {})
        ..carrierName = '  giffgaff  '
        ..iccid.text = '8944 1100 0000 0000 0001'
        ..dataBalance.text = '1,024'
        ..smdpAddress.text = 'rsp.example.com'; // 实体卡不保存 eSIM 字段
      draft.phones.first.text = ' +44 7700 900000 ';
      final card = draft.build(newUuid: 'u1');
      expect(card.carrierName, 'giffgaff');
      expect(card.iccid, '89441100000000000001');
      expect(card.dataBalanceMB, 1024);
      expect(card.phoneNumbers, ['+44 7700 900000']);
      expect(card.rspServerAddress, isNull);
      expect(card.activationStatus, ActivationStatus.active);
    });

    test('自定义运营商保留已选国家并分配不冲突的颜色', () {
      final used = {0xFF5E5CE6};
      final draft = SimFormDraft.create(usedColors: used)..countryCode = 'GB';
      draft.chooseCarrier(const CustomCarrierChoice('Lyca Mobile'));
      expect(draft.countryCode, 'GB');
      expect(draft.carrierCode, isNull);
      expect(used, isNot(contains(draft.cardColor.toARGB32())));
    });

    test('选择预置运营商会带出国家与品牌色；手动改色后不再被覆盖', () {
      final ee = CarrierData.findByCode('ee')!;
      final draft = SimFormDraft.create(usedColors: {})
        ..chooseCarrier(PresetCarrierChoice(ee));
      expect(draft.countryCode, 'GB');
      expect(draft.cardColor, ee.themeColor);
      draft.chooseColor(const Color(0xFF000000));
      draft.chooseCarrier(PresetCarrierChoice(CarrierData.findByCode('cmcc')!));
      expect(draft.cardColor, const Color(0xFF000000));
    });

    test('填入激活码时不覆盖已填写的确认码，并记录确认码必需标志', () {
      final draft = SimFormDraft.create(usedColors: {})
        ..confirmationCode.text = '1234';
      draft.applyActivationCode(QrParserService.parse(r'LPA:1$smdp.io$ABC$$1'));
      expect(draft.type, SimType.esim);
      expect(draft.smdpAddress.text, 'smdp.io');
      expect(draft.matchingId.text, 'ABC');
      expect(draft.confirmationCode.text, '1234');
      expect(draft.confirmationCodeRequired, isTrue);
    });

    test('编辑时未改动则 hasChanges 为 false，改动后为 true', () {
      final card = SimCard(
        id: 1,
        uuid: 'x',
        carrierName: 'KT',
        countryCode: 'KR',
        cardColor: 0xFFED1C24,
        features: FeatureSet({
          Feature.volte: const FeatureItem(supported: true),
        }),
      );
      final draft = SimFormDraft.edit(card, usedColors: {});
      expect(draft.hasChanges, isFalse);
      draft.notes.text = '新备注';
      expect(draft.hasChanges, isTrue);
    });
  });
}
