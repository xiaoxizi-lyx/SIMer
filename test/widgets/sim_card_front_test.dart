import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sim_keeper/models/enums.dart';
import 'package:sim_keeper/models/sim_card.dart';
import 'package:sim_keeper/widgets/sim_card_front.dart';

SimCard _rolling({required int daysSinceUse}) => SimCard(
  uuid: 'u',
  carrierName: '中国移动香港',
  countryCode: 'HK',
  cardColor: 0xFF0054A6,
  validityType: ValidityType.rolling,
  rollingDays: 30,
  lastUsedDate: DateTime(2026, 11, 6).subtract(Duration(days: daysSinceUse)),
  phoneNumbers: ['+852 5123 4567', '+852 6123 4567'],
  iccid: '89852000000000000001',
);

Future<void> _pump(WidgetTester tester, SimCard card) => withClock(
  Clock.fixed(DateTime(2026, 11, 6, 12)),
  () => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SimCardFront(simCard: card, onMarkAsUsed: () {}),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('已过期的滚动有效期卡仍显示「我已使用」', (tester) async {
    await _pump(tester, _rolling(daysSinceUse: 40));
    expect(find.text('我已使用'), findsOneWidget);
    expect(find.text('已过期'), findsOneWidget);
  });

  testWidgets('距到期较远时不在正面显示「我已使用」', (tester) async {
    await _pump(tester, _rolling(daysSinceUse: 1));
    expect(find.text('我已使用'), findsNothing);
  });
}
