import 'dart:ui';
import '../models/carrier.dart';

/// 预置运营商数据
class CarrierData {
  CarrierData._();

  /// 所有预置运营商
  static const List<Carrier> carriers = [
    // ══════════ 中国大陆 ══════════
    Carrier(
      code: 'cmcc',
      name: '中国移动',
      countryCode: 'CN',
      themeColor: Color(0xFF0054A6),
    ),
    Carrier(
      code: 'cucc',
      name: '中国联通',
      countryCode: 'CN',
      themeColor: Color(0xFFE60012),
    ),
    Carrier(
      code: 'ctcc',
      name: '中国电信',
      countryCode: 'CN',
      themeColor: Color(0xFF007DC3),
    ),
    Carrier(
      code: 'cbn',
      name: '中国广电',
      countryCode: 'CN',
      themeColor: Color(0xFF00A651),
    ),

    // ══════════ 中国香港 ══════════
    Carrier(
      code: '3hk',
      name: '3 HK',
      countryCode: 'HK',
      themeColor: Color(0xFFE5007D),
    ),
    Carrier(
      code: 'smartone',
      name: 'SmarTone',
      countryCode: 'HK',
      themeColor: Color(0xFF00AAEF),
    ),
    Carrier(
      code: 'cmhk',
      name: '中国移动香港',
      countryCode: 'HK',
      themeColor: Color(0xFF0054A6),
    ),
    Carrier(
      code: 'csl',
      name: 'CSL / 1O1O',
      countryCode: 'HK',
      themeColor: Color(0xFFE30613),
    ),

    // ══════════ 中国台湾 ══════════
    Carrier(
      code: 'cht',
      name: '中华电信',
      countryCode: 'TW',
      themeColor: Color(0xFF00529B),
    ),
    Carrier(
      code: 'twm',
      name: '台湾大哥大',
      countryCode: 'TW',
      themeColor: Color(0xFFFF6B00),
    ),
    Carrier(
      code: 'fet',
      name: '远传电信',
      countryCode: 'TW',
      themeColor: Color(0xFF00A1DE),
    ),
    Carrier(
      code: 'tstar',
      name: '台湾之星',
      countryCode: 'TW',
      themeColor: Color(0xFFE8272C),
    ),
    Carrier(
      code: 'aptg',
      name: '亚太电信',
      countryCode: 'TW',
      themeColor: Color(0xFF00AEEF),
    ),

    // ══════════ 日本 ══════════
    Carrier(
      code: 'docomo',
      name: 'NTT Docomo',
      countryCode: 'JP',
      themeColor: Color(0xFFE60033),
    ),
    Carrier(
      code: 'au_kddi',
      name: 'au (KDDI)',
      countryCode: 'JP',
      themeColor: Color(0xFFFF6600),
    ),
    Carrier(
      code: 'softbank',
      name: 'SoftBank',
      countryCode: 'JP',
      themeColor: Color(0xFFA0A0A0),
    ),
    Carrier(
      code: 'rakuten',
      name: '楽天モバイル',
      countryCode: 'JP',
      themeColor: Color(0xFFBF0000),
    ),

    // ══════════ 韩国 ══════════
    Carrier(
      code: 'skt',
      name: 'SK Telecom',
      countryCode: 'KR',
      themeColor: Color(0xFFE4002B),
    ),
    Carrier(
      code: 'kt',
      name: 'KT',
      countryCode: 'KR',
      themeColor: Color(0xFFE4002B),
    ),
    Carrier(
      code: 'lgu',
      name: 'LG U+',
      countryCode: 'KR',
      themeColor: Color(0xFFEC008C),
    ),

    // ══════════ 新加坡 ══════════
    Carrier(
      code: 'singtel',
      name: 'Singtel',
      countryCode: 'SG',
      themeColor: Color(0xFFE40000),
    ),
    Carrier(
      code: 'starhub',
      name: 'StarHub',
      countryCode: 'SG',
      themeColor: Color(0xFF1DB954),
    ),
    Carrier(
      code: 'm1',
      name: 'M1',
      countryCode: 'SG',
      themeColor: Color(0xFFFF8200),
    ),

    // ══════════ 泰国 ══════════
    Carrier(
      code: 'ais',
      name: 'AIS',
      countryCode: 'TH',
      themeColor: Color(0xFF00AA4F),
    ),
    Carrier(
      code: 'dtac',
      name: 'DTAC',
      countryCode: 'TH',
      themeColor: Color(0xFF00A1E0),
    ),
    Carrier(
      code: 'truemove',
      name: 'TrueMove H',
      countryCode: 'TH',
      themeColor: Color(0xFFE60000),
    ),

    // ══════════ 马来西亚 ══════════
    Carrier(
      code: 'maxis',
      name: 'Maxis',
      countryCode: 'MY',
      themeColor: Color(0xFF009A44),
    ),
    Carrier(
      code: 'digi',
      name: 'Digi',
      countryCode: 'MY',
      themeColor: Color(0xFFFFED00),
    ),
    Carrier(
      code: 'celcom',
      name: 'Celcom',
      countryCode: 'MY',
      themeColor: Color(0xFF0033A0),
    ),

    // ══════════ 美国 ══════════
    Carrier(
      code: 'tmobile',
      name: 'T-Mobile',
      countryCode: 'US',
      themeColor: Color(0xFFE20074),
    ),
    Carrier(
      code: 'att',
      name: 'AT&T',
      countryCode: 'US',
      themeColor: Color(0xFF009FDB),
    ),
    Carrier(
      code: 'verizon',
      name: 'Verizon',
      countryCode: 'US',
      themeColor: Color(0xFFCD040B),
    ),
    Carrier(
      code: 'googlefi',
      name: 'Google Fi',
      countryCode: 'US',
      themeColor: Color(0xFF4285F4),
    ),
    Carrier(
      code: 'mintmobile',
      name: 'Mint Mobile',
      countryCode: 'US',
      themeColor: Color(0xFF00B140),
    ),
    Carrier(
      code: 'usmobile',
      name: 'US Mobile',
      countryCode: 'US',
      themeColor: Color(0xFF1A1A2E),
    ),

    // ══════════ 加拿大 ══════════
    Carrier(
      code: 'rogers',
      name: 'Rogers',
      countryCode: 'CA',
      themeColor: Color(0xFFDA291C),
    ),
    Carrier(
      code: 'bell',
      name: 'Bell',
      countryCode: 'CA',
      themeColor: Color(0xFF0062A3),
    ),
    Carrier(
      code: 'telus',
      name: 'Telus',
      countryCode: 'CA',
      themeColor: Color(0xFF6C2C91),
    ),

    // ══════════ 英国 ══════════
    Carrier(
      code: 'vodafone',
      name: 'Vodafone',
      countryCode: 'GB',
      themeColor: Color(0xFFE60000),
    ),
    Carrier(
      code: 'three',
      name: 'Three',
      countryCode: 'GB',
      themeColor: Color(0xFF7B2D8B),
    ),
    Carrier(
      code: 'ee',
      name: 'EE',
      countryCode: 'GB',
      themeColor: Color(0xFF00B7AC),
    ),
    Carrier(
      code: 'o2',
      name: 'O2',
      countryCode: 'GB',
      themeColor: Color(0xFF003D6B),
    ),
    Carrier(
      code: 'giffgaff',
      name: 'giffgaff',
      countryCode: 'GB',
      themeColor: Color(0xFF202020),
    ),

    // ══════════ 德国 ══════════
    Carrier(
      code: 'telekom_de',
      name: 'Deutsche Telekom',
      countryCode: 'DE',
      themeColor: Color(0xFFE20074),
    ),
    Carrier(
      code: 'vodafone_de',
      name: 'Vodafone DE',
      countryCode: 'DE',
      themeColor: Color(0xFFE60000),
    ),
    Carrier(
      code: 'o2_de',
      name: 'O2 DE',
      countryCode: 'DE',
      themeColor: Color(0xFF003D6B),
    ),

    // ══════════ 法国 ══════════
    Carrier(
      code: 'orange',
      name: 'Orange',
      countryCode: 'FR',
      themeColor: Color(0xFFFF6600),
    ),
    Carrier(
      code: 'sfr',
      name: 'SFR',
      countryCode: 'FR',
      themeColor: Color(0xFFE4002B),
    ),
    Carrier(
      code: 'free',
      name: 'Free Mobile',
      countryCode: 'FR',
      themeColor: Color(0xFFCD1619),
    ),

    // ══════════ 澳大利亚 ══════════
    Carrier(
      code: 'telstra',
      name: 'Telstra',
      countryCode: 'AU',
      themeColor: Color(0xFF0072CE),
    ),
    Carrier(
      code: 'optus',
      name: 'Optus',
      countryCode: 'AU',
      themeColor: Color(0xFF00B5E2),
    ),
    Carrier(
      code: 'vodafone_au',
      name: 'Vodafone AU',
      countryCode: 'AU',
      themeColor: Color(0xFFE60000),
    ),

    // ══════════ 印度 ══════════
    Carrier(
      code: 'jio',
      name: 'Jio',
      countryCode: 'IN',
      themeColor: Color(0xFF0A3D7F),
    ),
    Carrier(
      code: 'airtel',
      name: 'Airtel',
      countryCode: 'IN',
      themeColor: Color(0xFFED1C24),
    ),
    Carrier(
      code: 'vi',
      name: 'Vi (Vodafone Idea)',
      countryCode: 'IN',
      themeColor: Color(0xFFED1C24),
    ),

    // ══════════ 虚拟运营商 / eSIM ══════════
    Carrier(
      code: 'airalo',
      name: 'Airalo',
      countryCode: 'US',
      themeColor: Color(0xFF1E3A5F),
    ),
    Carrier(
      code: 'holafly',
      name: 'Holafly',
      countryCode: 'ES',
      themeColor: Color(0xFF6B4EFF),
    ),
    Carrier(
      code: 'nomad',
      name: 'Nomad eSIM',
      countryCode: 'US',
      themeColor: Color(0xFF000000),
    ),
    Carrier(
      code: 'ubigi',
      name: 'Ubigi',
      countryCode: 'FR',
      themeColor: Color(0xFF00B4D8),
    ),
  ];

  /// 按代码查找运营商
  static Carrier? findByCode(String code) {
    try {
      return carriers.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// 按名称搜索运营商
  static List<Carrier> search(String query) {
    if (query.isEmpty) return carriers;
    final lowerQuery = query.toLowerCase();
    return carriers.where((c) {
      return c.name.toLowerCase().contains(lowerQuery) ||
          c.code.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 获取指定国家的运营商列表
  static List<Carrier> byCountry(String countryCode) {
    return carriers.where((c) => c.countryCode == countryCode).toList();
  }

  /// 获取所有有运营商的国家代码
  static Set<String> get countryCodes =>
      carriers.map((c) => c.countryCode).toSet();
}
