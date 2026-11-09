import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simer/data/carriers.dart';
import 'package:simer/data/countries.dart';
import 'package:simer/database/database_helper.dart';
import 'package:simer/l10n/l10n.dart';
import 'package:simer/providers/locale_provider.dart';

import '../support/l10n.dart';

void main() {
  group('界面语言', () {
    test('跟随系统：中文（含繁体）用简体中文，其他语言用英文', () {
      Locale resolve(List<Locale> preferred) =>
          LocaleProvider.resolve(preferred);
      expect(resolve(const [Locale('zh', 'CN')]).languageCode, 'zh');
      expect(
        resolve(const [
          Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
        ]).languageCode,
        'zh',
      );
      expect(resolve(const [Locale('en', 'GB')]).languageCode, 'en');
      expect(resolve(const [Locale('ja', 'JP')]).languageCode, 'en');
      // 首选语言不受支持时，按系统语言列表中的下一种语言选择
      expect(
        resolve(const [Locale('ja'), Locale('zh', 'CN')]).languageCode,
        'zh',
      );
    });

    test('中英文 ARB 的文案条目一一对应', () {
      Set<String> keys(String path) =>
          (jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>)
              .keys
              .where((k) => !k.startsWith('@'))
              .toSet();
      expect(keys('lib/l10n/app_en.arb'), keys('lib/l10n/app_zh.arb'));
    });
  });

  group('数据的本地化名称', () {
    test('国家/地区名称随语言变化，未收录的代码原样显示', () {
      expect(CountryData.name('GB', 'zh'), '英国');
      expect(CountryData.name('GB', 'en'), 'United Kingdom');
      expect(CountryData.name('HK', 'en'), 'Hong Kong, China');
      expect(CountryData.name('XX', 'en'), 'XX');
      expect(CountryData.countriesEn.keys, CountryData.countries.keys);
    });

    test('国家搜索同时匹配代码、中文名与英文名', () {
      expect(CountryData.search('英国'), ['GB']);
      expect(CountryData.search('kingdom'), ['GB']);
      expect(CountryData.search('gb'), contains('GB'));
    });

    test('预置运营商在英文界面显示英文名，自定义运营商保持原样', () {
      String name(String? code, String stored, String lang) =>
          CarrierData.displayName(
            carrierCode: code,
            storedName: stored,
            languageCode: lang,
          );
      expect(name('cmcc', '中国移动', 'zh'), '中国移动');
      expect(name('cmcc', '中国移动', 'en'), 'China Mobile');
      expect(name(null, '我的物联网卡', 'en'), '我的物联网卡');
      expect(name('custom_1', 'Lyca', 'en'), 'Lyca');
    });
  });

  test('导入结果摘要按语言生成', () {
    const result = ImportResult(
      importedCards: 1,
      overwrittenCards: 0,
      skippedCards: 2,
      importedTags: 3,
    );
    expect(result.summary(zh), '导入完成：新增 1 张卡片，跳过 2 张重复卡片，新增 3 个标签');
    expect(
      result.summary(en),
      'Import complete: 1 card added, 2 duplicates skipped, 3 tags added',
    );
  });
}
