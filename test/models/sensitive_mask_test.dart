import 'package:flutter_test/flutter_test.dart';
import 'package:simer/models/sensitive_mask.dart';

void main() {
  group('SensitiveMask', () {
    test('ICCID 只显示第一组与最后一组', () {
      expect(
        SensitiveMask.iccid('89860012345678901234'),
        '8986 •••• •••• •••• 1234',
      );
      // 19 位：最后一组只有 3 位，仍按组打码，不会错位
      expect(
        SensitiveMask.iccid('8985 2000 0000 0000 001'),
        '8985 •••• •••• •••• 001',
      );
      expect(SensitiveMask.iccid('12345678'), '•••• ••••');
    });

    test('激活码保留首尾各 4 个字符，中间长度固定，不暴露长度', () {
      expect(SensitiveMask.code('ABCD-1234-EFGH-5678'), 'ABCD••••5678');
      expect(SensitiveMask.code('ABCD-5678'), 'ABCD••••5678');
      expect(SensitiveMask.code('SHORT'), '••••••');
      expect(SensitiveMask.code('12345678'), '••••••');
    });

    test('确认码全部打码，不暴露长度', () {
      expect(SensitiveMask.full('1234'), '••••••');
      expect(SensitiveMask.full('1234567890'), '••••••');
    });
  });
}
