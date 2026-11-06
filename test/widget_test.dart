import 'package:flutter_test/flutter_test.dart';
import 'package:sim_keeper/models/enums.dart';
import 'package:sim_keeper/models/sim_card.dart';

void main() {
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
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(card.isExpired, isTrue);
      expect(card.validityState, ValidityState.expired);
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
