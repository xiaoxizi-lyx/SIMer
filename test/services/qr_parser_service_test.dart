import 'package:flutter_test/flutter_test.dart';
import 'package:sim_keeper/services/qr_parser_service.dart';

void main() {
  group('QrParserService（GSMA SGP.22 §4.1）', () {
    test('解析基本激活码', () {
      final result = QrParserService.parse(
        r'LPA:1$smdp.example.com$04386-AGYFT-A74Y8-3F815',
      );
      expect(result.isSuccess, isTrue);
      expect(result.code!.smdpAddress, 'smdp.example.com');
      expect(result.code!.matchingId, '04386-AGYFT-A74Y8-3F815');
      expect(result.code!.smdpOid, isNull);
      expect(result.code!.confirmationCodeRequired, isFalse);
    });

    test('第 4 段是 SM-DP+ OID，不是确认码', () {
      final code = QrParserService.parse(
        r'LPA:1$smdp.example.com$ABC-123$1.3.6.1.4.1.31746',
      ).code!;
      expect(code.smdpOid, '1.3.6.1.4.1.31746');
      expect(code.confirmationCodeRequired, isFalse);
    });

    test('第 5 段为 1 表示需要确认码（确认码本身不在二维码中）', () {
      final code = QrParserService.parse(r'LPA:1$smdp.example.com$ABC-123$$1')
          .code!;
      expect(code.smdpOid, isNull);
      expect(code.confirmationCodeRequired, isTrue);
    });

    test('兼容不带 LPA: 前缀的激活码与大小写、首尾空白', () {
      expect(
        QrParserService.parse(r'1$smdp.example.com$TOKEN').code!.smdpAddress,
        'smdp.example.com',
      );
      expect(
        QrParserService.parse('  lpa:1\$rsp.truphone.com\$X  ')
            .code!
            .matchingId,
        'X',
      );
    });

    test('拒绝非激活码内容', () {
      for (final input in [
        '',
        'https://example.com',
        r'smdp.example.com$TOKEN',
        'WIFI:S:home;;',
      ]) {
        final result = QrParserService.parse(input);
        expect(result.isSuccess, isFalse, reason: input);
        expect(result.errorMessage, isNotEmpty);
      }
    });

    test('拒绝格式版本不是 1 或字段缺失的激活码', () {
      expect(
        QrParserService.parse(r'LPA:2$smdp.example.com$X').isSuccess,
        isFalse,
      );
      expect(
        QrParserService.parse(r'LPA:1$smdp.example.com').isSuccess,
        isFalse,
      );
      expect(QrParserService.parse(r'LPA:1$$TOKEN').isSuccess, isFalse);
      expect(
        QrParserService.parse(r'LPA:1$https://smdp.example.com/x$TOKEN')
            .isSuccess,
        isFalse,
      );
    });

    test('toLpaString 生成规范的激活码并可再次解析', () {
      const code = LpaActivationCode(
        smdpAddress: 'smdp.example.com',
        matchingId: 'M-1',
        confirmationCodeRequired: true,
      );
      expect(code.toLpaString(), r'LPA:1$smdp.example.com$M-1$$1');
      final reparsed = QrParserService.parse(code.toLpaString()).code!;
      expect(reparsed.confirmationCodeRequired, isTrue);
      expect(
        const LpaActivationCode(
          smdpAddress: 'a.b',
          matchingId: 'X',
        ).toLpaString(),
        r'LPA:1$a.b$X',
      );
    });
  });
}
