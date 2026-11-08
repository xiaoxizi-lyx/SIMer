import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simer/models/enums.dart';
import 'package:simer/models/sim_card.dart';
import 'package:simer/widgets/sim_card_back.dart';

import '../support/l10n.dart';

SimCard _esim() => SimCard(
  uuid: 'u1',
  carrierName: 'giffgaff',
  countryCode: 'GB',
  cardColor: 0xFF34C759,
  type: SimType.esim,
  iccid: '89441100000000000001',
  rspServerAddress: 'rsp.example.com',
  activationCode: 'ABCD-1234-EFGH-5678',
  confirmationCode: '246810',
  createdAt: DateTime(2026, 11, 1),
  updatedAt: DateTime(2026, 11, 1),
);

Future<void> _pump(WidgetTester tester, {required bool mask}) async {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    localizedApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SimCardBack(simCard: _esim(), maskSensitive: mask),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('默认打码显示 ICCID、激活码与确认码，点击眼睛图标后显示完整内容', (tester) async {
    await _pump(tester, mask: true);

    expect(find.text('8944 •••• •••• •••• 0001'), findsOneWidget);
    expect(find.text('ABCD••••5678'), findsOneWidget);
    expect(find.text('••••••'), findsOneWidget);
    expect(find.text('246810'), findsNothing);
    // SM-DP+ 地址不是敏感信息
    expect(find.text('rsp.example.com'), findsOneWidget);

    await tester.tap(find.byTooltip('显示ICCID'));
    await tester.pump();
    expect(find.text('8944 1100 0000 0000 0001'), findsOneWidget);
    // 其他行保持打码
    expect(find.text('ABCD••••5678'), findsOneWidget);

    await tester.tap(find.byTooltip('显示确认码'));
    await tester.pump();
    expect(find.text('246810'), findsOneWidget);

    await tester.tap(find.byTooltip('隐藏ICCID'));
    await tester.pump();
    expect(find.text('8944 •••• •••• •••• 0001'), findsOneWidget);
  });

  testWidgets('打码时复制的仍是完整内容', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await _pump(tester, mask: true);
    await tester.tap(find.byTooltip('复制激活码'));
    await tester.pump();
    expect(copied, 'ABCD-1234-EFGH-5678');
  });

  testWidgets('关闭「隐藏敏感信息」时直接显示完整内容', (tester) async {
    await _pump(tester, mask: false);
    expect(find.text('8944 1100 0000 0000 0001'), findsOneWidget);
    expect(find.text('ABCD-1234-EFGH-5678'), findsOneWidget);
    expect(find.text('246810'), findsOneWidget);
    expect(find.byTooltip('显示ICCID'), findsNothing);
  });
}
