/// 国家/地区数据：ISO 代码 → 中文 / 英文名称
/// emoji 国旗通过 countryCodeToEmoji() 计算，无需硬编码
class CountryData {
  CountryData._();

  /// 将 ISO 3166-1 alpha-2 代码转换为 emoji 国旗
  static String countryCodeToEmoji(String countryCode) {
    if (countryCode.length != 2) return '🏳️';
    const base = 0x1F1E6 - 0x41; // Regional Indicator 'A' offset
    return String.fromCharCodes(
      countryCode.toUpperCase().codeUnits.map((c) => base + c),
    );
  }

  /// 国家/地区名称：界面语言为中文时用中文名，否则用英文名。未收录的代码原样显示。
  static String name(String countryCode, String languageCode) =>
      (languageCode == 'zh' ? countries : countriesEn)[countryCode] ??
      countryCode;

  /// 国家显示文本：emoji 国旗 + 名称。
  static String displayName(String countryCode, String languageCode) =>
      '${countryCodeToEmoji(countryCode)} ${name(countryCode, languageCode)}';

  /// 常用国家/地区列表（按使用频率排序）
  static const Map<String, String> countries = {
    // 东亚
    'CN': '中国大陆',
    'HK': '中国香港',
    'MO': '中国澳门',
    'TW': '中国台湾',
    'JP': '日本',
    'KR': '韩国',
    'MN': '蒙古',

    // 东南亚
    'SG': '新加坡',
    'MY': '马来西亚',
    'TH': '泰国',
    'VN': '越南',
    'PH': '菲律宾',
    'ID': '印度尼西亚',
    'MM': '缅甸',
    'KH': '柬埔寨',
    'LA': '老挝',
    'BN': '文莱',

    // 南亚
    'IN': '印度',
    'PK': '巴基斯坦',
    'BD': '孟加拉国',
    'LK': '斯里兰卡',
    'NP': '尼泊尔',

    // 中亚/西亚
    'AE': '阿联酋',
    'SA': '沙特阿拉伯',
    'TR': '土耳其',
    'IL': '以色列',
    'QA': '卡塔尔',
    'KW': '科威特',
    'BH': '巴林',
    'OM': '阿曼',
    'JO': '约旦',
    'IQ': '伊拉克',

    // 北美
    'US': '美国',
    'CA': '加拿大',
    'MX': '墨西哥',

    // 欧洲
    'GB': '英国',
    'DE': '德国',
    'FR': '法国',
    'IT': '意大利',
    'ES': '西班牙',
    'NL': '荷兰',
    'BE': '比利时',
    'SE': '瑞典',
    'NO': '挪威',
    'DK': '丹麦',
    'FI': '芬兰',
    'CH': '瑞士',
    'AT': '奥地利',
    'PT': '葡萄牙',
    'IE': '爱尔兰',
    'PL': '波兰',
    'CZ': '捷克',
    'GR': '希腊',
    'HU': '匈牙利',
    'RO': '罗马尼亚',
    'RU': '俄罗斯',
    'UA': '乌克兰',
    'IS': '冰岛',
    'LU': '卢森堡',

    // 大洋洲
    'AU': '澳大利亚',
    'NZ': '新西兰',

    // 南美
    'BR': '巴西',
    'AR': '阿根廷',
    'CL': '智利',
    'CO': '哥伦比亚',
    'PE': '秘鲁',

    // 非洲
    'ZA': '南非',
    'EG': '埃及',
    'NG': '尼日利亚',
    'KE': '肯尼亚',
    'MA': '摩洛哥',
    'TN': '突尼斯',
    'ET': '埃塞俄比亚',
    'GH': '加纳',
    'TZ': '坦桑尼亚',
  };

  /// 英文名称（与 [countries] 的代码一一对应）。
  static const Map<String, String> countriesEn = {
    'CN': 'Mainland China',
    'HK': 'Hong Kong, China',
    'MO': 'Macao, China',
    'TW': 'Taiwan, China',
    'JP': 'Japan',
    'KR': 'South Korea',
    'MN': 'Mongolia',
    'SG': 'Singapore',
    'MY': 'Malaysia',
    'TH': 'Thailand',
    'VN': 'Vietnam',
    'PH': 'Philippines',
    'ID': 'Indonesia',
    'MM': 'Myanmar',
    'KH': 'Cambodia',
    'LA': 'Laos',
    'BN': 'Brunei',
    'IN': 'India',
    'PK': 'Pakistan',
    'BD': 'Bangladesh',
    'LK': 'Sri Lanka',
    'NP': 'Nepal',
    'AE': 'United Arab Emirates',
    'SA': 'Saudi Arabia',
    'TR': 'Türkiye',
    'IL': 'Israel',
    'QA': 'Qatar',
    'KW': 'Kuwait',
    'BH': 'Bahrain',
    'OM': 'Oman',
    'JO': 'Jordan',
    'IQ': 'Iraq',
    'US': 'United States',
    'CA': 'Canada',
    'MX': 'Mexico',
    'GB': 'United Kingdom',
    'DE': 'Germany',
    'FR': 'France',
    'IT': 'Italy',
    'ES': 'Spain',
    'NL': 'Netherlands',
    'BE': 'Belgium',
    'SE': 'Sweden',
    'NO': 'Norway',
    'DK': 'Denmark',
    'FI': 'Finland',
    'CH': 'Switzerland',
    'AT': 'Austria',
    'PT': 'Portugal',
    'IE': 'Ireland',
    'PL': 'Poland',
    'CZ': 'Czechia',
    'GR': 'Greece',
    'HU': 'Hungary',
    'RO': 'Romania',
    'RU': 'Russia',
    'UA': 'Ukraine',
    'IS': 'Iceland',
    'LU': 'Luxembourg',
    'AU': 'Australia',
    'NZ': 'New Zealand',
    'BR': 'Brazil',
    'AR': 'Argentina',
    'CL': 'Chile',
    'CO': 'Colombia',
    'PE': 'Peru',
    'ZA': 'South Africa',
    'EG': 'Egypt',
    'NG': 'Nigeria',
    'KE': 'Kenya',
    'MA': 'Morocco',
    'TN': 'Tunisia',
    'ET': 'Ethiopia',
    'GH': 'Ghana',
    'TZ': 'Tanzania',
  };

  /// 搜索国家/地区：代码、中文名与英文名都参与匹配（不区分大小写）。
  /// 返回匹配的代码，顺序与 [countries] 一致。
  static List<String> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return countries.keys.toList();
    return countries.keys.where((code) {
      return code.toLowerCase().contains(q) ||
          countries[code]!.toLowerCase().contains(q) ||
          (countriesEn[code]?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
