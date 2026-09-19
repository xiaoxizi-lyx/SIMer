import 'package:flutter_test/flutter_test.dart';
import 'package:sim_keeper/models/enums.dart';
import 'package:sim_keeper/models/sim_card.dart';
import 'package:sim_keeper/services/qr_parser_service.dart';

void main() {
  group('QrParserService Tests', () {
    test('Parse valid LPA without confirmation code', () {
      const raw = 'LPA:1\$smdp.example.com\$MATCHING-ID-12345';
      final result = QrParserService.parse(raw);

      expect(result.isSuccess, isTrue);
      expect(result.smdpAddress, 'smdp.example.com');
      expect(result.matchingId, 'MATCHING-ID-12345');
      expect(result.confirmationCode, isNull);
    });

    test('Parse valid LPA with confirmation code', () {
      const raw = 'LPA:1\$smdp.io\$ACTIVATION-CODE\$CONFIRM-999';
      final result = QrParserService.parse(raw);

      expect(result.isSuccess, isTrue);
      expect(result.smdpAddress, 'smdp.io');
      expect(result.matchingId, 'ACTIVATION-CODE');
      expect(result.confirmationCode, 'CONFIRM-999');
    });

    test('Reject invalid LPA prefix', () {
      const raw = 'INVALID:1\$smdp.io\$CODE';
      final result = QrParserService.parse(raw);

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('缺少 LPA: 前缀'));
    });

    test('Reject empty input', () {
      final result = QrParserService.parse('');
      expect(result.isSuccess, isFalse);
    });

    test('buildLpaString generates proper format', () {
      final lpa = QrParserService.buildLpaString(
        smdpAddress: 'smdp.example.com',
        matchingId: 'MATCH-123',
        confirmationCode: 'PIN',
      );
      expect(lpa, 'LPA:1\$smdp.example.com\$MATCH-123\$PIN');
      expect(QrParserService.isValidLpaFormat(lpa), isTrue);
    });
  });

  group('SimCard Model Tests', () {
    test('Rolling validity computation', () {
      final card = SimCard(
        uuid: 'test-uuid-rolling',
        cardColor: 0xFF5E5CE6,
        type: SimType.esim,
        carrierName: 'Test Carrier',
        countryCode: 'US',
        validityType: ValidityType.rolling,
        rollingDays: 30,
        lastUsedDate: DateTime.now().subtract(const Duration(days: 10)),
      );

      expect(card.daysRemaining, inInclusiveRange(19, 21));
      expect(card.isExpired, isFalse);
    });

    test('No expiration card', () {
      final card = SimCard(
        uuid: 'test-uuid-lifetime',
        cardColor: 0xFF5E5CE6,
        type: SimType.physicalSim,
        carrierName: 'Lifetime SIM',
        countryCode: 'HK',
        validityType: ValidityType.noExpiration,
      );

      expect(card.effectiveExpirationDate, isNull);
      expect(card.daysRemaining, isNull);
      expect(card.isExpired, isFalse);
    });

    test('Fixed expiration date passed is detected as expired', () {
      final card = SimCard(
        uuid: 'test-uuid-expired',
        cardColor: 0xFFFF453A,
        type: SimType.physicalSim,
        carrierName: 'Expired SIM',
        countryCode: 'CN',
        validityType: ValidityType.fixedDate,
        expirationDate: DateTime.now().subtract(const Duration(hours: 3)),
      );

      expect(card.isExpired, isTrue);
      expect(card.needsReminder, isTrue);
    });

    test('Formatted ICCID groups by 4 digits', () {
      final card = SimCard(
        uuid: 'test-uuid-iccid',
        cardColor: 0xFF5E5CE6,
        type: SimType.physicalSim,
        carrierName: 'Test Carrier',
        countryCode: 'CN',
        iccid: '89860012345678901234',
      );

      expect(card.formattedIccid, '8986 0012 3456 7890 1234');
    });

    test('JSON serialization roundtrip', () {
      final original = SimCard(
        uuid: 'roundtrip-uuid-1',
        cardColor: 0xFF34C759,
        type: SimType.esim,
        carrierName: 'Giffgaff',
        carrierCode: 'giffgaff',
        countryCode: 'GB',
        phoneNumbers: ['+447123456789'],
        validityType: ValidityType.rolling,
        rollingDays: 180,
      );

      final jsonMap = original.toJson();
      final restored = SimCard.fromJson(jsonMap);

      expect(restored.uuid, original.uuid);
      expect(restored.carrierName, original.carrierName);
      expect(restored.phoneNumbers, original.phoneNumbers);
      expect(restored.validityType, original.validityType);
      expect(restored.rollingDays, original.rollingDays);
      expect(restored.cardColor, original.cardColor);
    });
  });
}
