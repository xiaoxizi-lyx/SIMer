// 在真实的 Android 系统（CI 中的模拟器）上运行完整应用，覆盖电脑上的单元测试
// 无法验证的部分：SQLite、通知预约、后台 isolate 中的加密、本地化切换与持久化。
//
// 运行：flutter test integration_test（需要已连接的 Android 设备或模拟器）
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:simer/database/database_helper.dart';
import 'package:simer/l10n/app_localizations.dart';
import 'package:simer/main.dart' as app;
import 'package:simer/models/calendar_date.dart';
import 'package:simer/models/enums.dart';
import 'package:simer/models/sim_card.dart';
import 'package:simer/screens/home_screen.dart';
import 'package:simer/services/backup_codec.dart';
import 'package:simer/services/backup_crypto.dart';
import 'package:simer/services/backup_service.dart';
import 'package:simer/services/notification_service.dart';

const _carrier = 'Integration Carrier';

/// 当前对话框中的文字（避免与页面上同样的文字混淆）。
Finder _inDialog(String text) =>
    find.descendant(of: find.byType(Dialog), matching: find.text(text));

const _iccid = '89860012345678901234';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('在真机环境中添加、查看、备份、提醒与归档一张卡片', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    // 文案按设备语言取，不写死中文或英文
    final l = AppLocalizations.of(tester.element(find.byType(HomeScreen)));
    expect(find.text(l.homeEmpty), findsOneWidget);

    // ── 通过界面添加一张卡 ──
    await tester.tap(find.text(l.homeAddCard));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.formCarrierHint));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, l.carrierPickerSearchHint),
      _carrier,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.carrierPickerUseCustom(_carrier)));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, l.formIccidHint),
      _iccid,
    );
    await tester.tap(find.text(l.commonSave));
    await tester.pumpAndSettle();

    // 首页显示新卡片，ICCID 默认打码
    expect(find.text(_carrier), findsOneWidget);
    expect(find.text('8986 •••• •••• •••• 1234'), findsOneWidget);
    expect(find.textContaining('0012'), findsNothing);

    // ── 数据写入了设备上的 SQLite ──
    final saved = await DatabaseHelper.instance.getSimCards(archived: false);
    expect(saved.map((c) => c.carrierName), [_carrier]);
    expect(saved.single.iccid, _iccid);

    // ── 加密备份：在后台 isolate 中加密，再解密核对 ──
    final watch = Stopwatch()..start();
    final export = await BackupService.prepareExport(password: 'device-pw-1');
    debugPrint('Encrypted export took ${watch.elapsedMilliseconds} ms');
    final root = jsonDecode(utf8.decode(export.bytes)) as Map<String, dynamic>;
    expect(BackupCrypto.isEncrypted(root), isTrue);
    expect(utf8.decode(export.bytes), isNot(contains(_iccid)));
    final restored = BackupCodec.decode(
      await BackupCrypto.decrypt(root, 'device-pw-1'),
    );
    expect(restored.cards.single.iccid, _iccid);

    // ── 通知：按系统时区预约三条一次性提醒，并能全部取消 ──
    final today = CalendarDate.today();
    final expiring = SimCard(
      id: saved.single.id,
      uuid: saved.single.uuid,
      carrierName: _carrier,
      countryCode: 'GB',
      cardColor: saved.single.cardColor,
      validityType: ValidityType.fixedDate,
      expirationDate: DateTime(today.year, today.month, today.day + 10),
    );
    final notifications = FlutterLocalNotificationsPlugin();
    await NotificationService.reschedule(
      [expiring],
      enabled: true,
      hour: 9,
      minute: 0,
      strings: l,
    );
    final pending = await notifications.pendingNotificationRequests();
    expect(pending, hasLength(3));
    expect(pending.map((p) => p.payload).toSet(), {saved.single.uuid});
    await NotificationService.reschedule(
      [expiring],
      enabled: false,
      hour: 9,
      minute: 0,
      strings: l,
    );
    expect(await notifications.pendingNotificationRequests(), isEmpty);

    // ── 切换界面语言，再改回跟随系统 ──
    await tester.tap(find.byTooltip(l.settingsTitle));
    await tester.pumpAndSettle();
    final other = lookupAppLocalizations(
      Locale(l.localeName == 'zh' ? 'en' : 'zh'),
    );
    await tester.tap(find.text(l.settingsLanguage));
    await tester.pumpAndSettle();
    await tester.tap(_inDialog(other.localeName == 'zh' ? '简体中文' : 'English'));
    await tester.pumpAndSettle();
    expect(find.text(other.settingsTitle), findsOneWidget);
    await tester.tap(find.text(other.settingsLanguage));
    await tester.pumpAndSettle();
    // 主题设置里也有「跟随系统」，只在语言对话框中查找
    await tester.tap(_inDialog(other.commonFollowSystem));
    await tester.pumpAndSettle();
    expect(find.text(l.settingsTitle), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ── 翻到背面并归档 ──
    await tester.tap(find.text(_carrier));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.cardArchive));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, l.cardArchive));
    await tester.pumpAndSettle();
    expect(find.text(l.homeEmpty), findsOneWidget);

    final archived = await DatabaseHelper.instance.getSimCards(archived: true);
    expect(archived.map((c) => c.carrierName), [_carrier]);

    // 清理，便于在同一设备上重复运行
    await DatabaseHelper.instance.permanentlyDeleteSimCard(archived.single.id!);
  });
}
