import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sim_keeper/models/calendar_date.dart';
import 'package:sim_keeper/models/enums.dart';
import 'package:sim_keeper/models/sim_card.dart';

/// 固定「现在」为 2026-11-06 15:30（本地时间）。
final _now = DateTime(2026, 11, 6, 15, 30);
final _today = DateTime(2026, 11, 6);

SimCard _card({
  ValidityType validityType = ValidityType.noExpiration,
  DateTime? expirationDate,
  int? rollingDays,
  DateTime? lastUsedDate,
  DateTime? activationDate,
  DateTime? createdAt,
  int reminderDaysBefore = 7,
}) => SimCard(
  uuid: 'u',
  carrierName: 'giffgaff',
  countryCode: 'GB',
  cardColor: 0xFF34C759,
  validityType: validityType,
  expirationDate: expirationDate,
  rollingDays: rollingDays,
  lastUsedDate: lastUsedDate,
  activationDate: activationDate,
  createdAt: createdAt,
  reminderDaysBefore: reminderDaysBefore,
);

void main() {
  group('固定到期日', () {
    test('到期日当天仍然有效（剩余 0 天，状态为即将到期）', () {
      withClock(Clock.fixed(_now), () {
        final card = _card(
          validityType: ValidityType.fixedDate,
          expirationDate: _today, // showDatePicker 返回当天 00:00
        );
        expect(card.daysRemaining, 0);
        expect(card.isExpired, isFalse);
        expect(card.validityState, ValidityState.expiringSoon);
      });
    });

    test('到期日次日才算已过期', () {
      withClock(Clock.fixed(_now), () {
        final card = _card(
          validityType: ValidityType.fixedDate,
          expirationDate: DateTime(2026, 11, 5),
        );
        expect(card.daysRemaining, -1);
        expect(card.validityState, ValidityState.expired);
      });
    });

    test('提醒窗口以卡片自身的提前提醒天数为准', () {
      final card = _card(
        validityType: ValidityType.fixedDate,
        expirationDate: DateTime(2026, 11, 20),
        reminderDaysBefore: 30,
      );
      expect(card.validityStateOn(_today), ValidityState.expiringSoon);
      card.reminderDaysBefore = 7;
      expect(card.validityStateOn(_today), ValidityState.valid);
    });

    test('缺少到期日时为「未设定」而不是无期限', () {
      final card = _card(validityType: ValidityType.fixedDate);
      expect(card.validityStateOn(_today), ValidityState.unknown);
    });
  });

  group('滚动有效期', () {
    test('以上次使用日为基准', () {
      final card = _card(
        validityType: ValidityType.rolling,
        rollingDays: 180,
        lastUsedDate: DateTime(2026, 6, 1),
        activationDate: DateTime(2026, 1, 1),
      );
      expect(card.effectiveExpirationDate, DateTime(2026, 11, 28));
    });

    test('没有上次使用日时以激活日为基准', () {
      final card = _card(
        validityType: ValidityType.rolling,
        rollingDays: 30,
        activationDate: DateTime(2026, 10, 20),
      );
      expect(card.effectiveExpirationDate, DateTime(2026, 11, 19));
    });

    test('日期都没填时以添加日为基准，仍会倒计时与提醒', () {
      final card = _card(
        validityType: ValidityType.rolling,
        rollingDays: 30,
        createdAt: DateTime(2026, 10, 10, 23, 59),
      );
      expect(card.effectiveExpirationDate, DateTime(2026, 11, 9));
      expect(card.validityStateOn(_today), ValidityState.expiringSoon);
    });

    test('滚动天数为空或非正数时为「未设定」', () {
      expect(
        _card(validityType: ValidityType.rolling).validityStateOn(_today),
        ValidityState.unknown,
      );
      expect(
        _card(
          validityType: ValidityType.rolling,
          rollingDays: 0,
        ).validityStateOn(_today),
        ValidityState.unknown,
      );
    });
  });

  test('无期限卡', () {
    final card = _card();
    expect(card.effectiveExpirationDate, isNull);
    expect(card.validityStateOn(_today), ValidityState.unlimited);
    expect(card.isExpired, isFalse);
  });

  test('天数按日历日计算，不受具体时刻影响', () {
    expect(
      CalendarDate.daysBetween(
        DateTime(2026, 3, 28, 23, 59),
        DateTime(2026, 3, 30, 0, 1),
      ),
      2,
    );
    expect(CalendarDate.addDays(DateTime(2026, 12, 31), 1), DateTime(2027));
  });
}
