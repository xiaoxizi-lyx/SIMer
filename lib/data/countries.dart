/// 国家/地区数据：ISO代码 → 中文名称
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

  /// 获取国家显示文本：emoji + 名称
  static String displayName(String countryCode) {
    final emoji = countryCodeToEmoji(countryCode);
    final name = countries[countryCode] ?? countryCode;
    return '$emoji $name';
  }

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

  /// 搜索国家（支持代码和中文名模糊匹配）
  static List<MapEntry<String, String>> search(String query) {
    if (query.isEmpty) return countries.entries.toList();
    final lowerQuery = query.toLowerCase();
    return countries.entries.where((entry) {
      return entry.key.toLowerCase().contains(lowerQuery) ||
          entry.value.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
