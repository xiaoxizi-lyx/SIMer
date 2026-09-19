// SIM卡类型、状态、有效期类型等枚举定义

/// SIM卡类型
enum SimType {
  physicalSim('实体SIM卡'),
  esim('eSIM');

  final String label;
  const SimType(this.label);

  static SimType fromString(String value) {
    return SimType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SimType.physicalSim,
    );
  }
}

/// SIM卡状态
enum SimStatus {
  active('激活'),
  inactive('未激活'),
  expired('已过期'),
  archived('已归档');

  final String label;
  const SimStatus(this.label);

  static SimStatus fromString(String value) {
    return SimStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SimStatus.inactive,
    );
  }
}

/// 有效期类型
enum ValidityType {
  fixedDate('固定到期日'),
  rolling('滚动有效期'),
  noExpiration('无期限');

  final String label;
  const ValidityType(this.label);

  String get description {
    switch (this) {
      case ValidityType.fixedDate:
        return '设定一个具体的到期日期';
      case ValidityType.rolling:
        return '每隔N天需使用一次，使用后自动续期';
      case ValidityType.noExpiration:
        return '此SIM卡没有有效期限制';
    }
  }

  static ValidityType fromString(String value) {
    return ValidityType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ValidityType.noExpiration,
    );
  }
}

/// 排序依据
enum SortBy {
  createdAt('添加时间'),
  expirationDate('到期时间'),
  carrierName('运营商'),
  countryCode('国家/地区');

  final String label;
  const SortBy(this.label);
}

/// 排序顺序
enum SortOrder {
  ascending('升序'),
  descending('降序');

  final String label;
  const SortOrder(this.label);

  SortOrder get toggled =>
      this == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending;
}
