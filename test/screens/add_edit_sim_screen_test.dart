import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:simer/providers/sim_card_provider.dart';
import 'package:simer/screens/add_edit_sim_screen.dart';

void main() {
  testWidgets('折叠分区中的非法输入同样会阻止保存，并自动展开该分区', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SimCardProvider(),
        child: const MaterialApp(home: AddEditSimScreen()),
      ),
    );

    // 在「基本信息」中填写非法 ICCID
    await tester.enterText(
      find.widgetWithText(TextFormField, '18-22 位数字，可含空格'),
      '123',
    );
    // 展开「有效期」，「基本信息」随之折叠
    await tester.tap(find.text('有效期'));
    await tester.pumpAndSettle();
    expect(find.text('ICCID 应为 18-22 位数字'), findsNothing);

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('请检查标红的内容'), findsOneWidget);
    expect(find.text('ICCID 应为 18-22 位数字'), findsOneWidget);
    expect(find.text('请选择或输入运营商'), findsOneWidget);
    expect(find.byType(AddEditSimScreen), findsOneWidget, reason: '不应保存并退出');
  });
}
