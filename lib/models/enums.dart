// SIM 卡类型、激活状态、有效期等枚举定义

/// SIM卡类型
enum SimType {
  physicalSim('实体SIM卡'),
  esim('eSIM');

  const SimType(this.label);
  final String label;

  static SimType fromString(String? value) => SimType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => SimType.physicalSim,
  );
}

/// 激活状态：由用户设置并持久化。
///
/// 是否过期由有效期实时计算（见 [ValidityState]），是否归档由归档时间决定，
/// 二者都不再混入此状态。
enum ActivationStatus {
  active('激活'),
  inactive('未激活');

  const ActivationStatus(this.label);
  final String label;

  static ActivationStatus fromString(String? value) =>
      ActivationStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ActivationStatus.active,
      );
}

/// 有效性：根据有效期设置与当前日期实时计算，不持久化。
enum ValidityState {
  /// 无期限卡。
  unlimited('无期限'),

  /// 有期限类型，但缺少计算所需的日期/天数。
  unknown('未设定'),
  valid('有效'),

  /// 处于提前提醒窗口内（含到期日当天）。
  expiringSoon('即将到期'),
  expired('已过期');

  const ValidityState(this.label);
  final String label;
}

/// 有效期类型
enum ValidityType {
  fixedDate('固定到期日'),
  rolling('滚动有效期'),
  noExpiration('无期限');

  const ValidityType(this.label);
  final String label;

  String get description => switch (this) {
    ValidityType.fixedDate => '设定一个具体的到期日期，当天仍然有效',
    ValidityType.rolling => '每隔N天需使用一次，使用后自动续期',
    ValidityType.noExpiration => '此SIM卡没有有效期限制',
  };

  static ValidityType fromString(String? value) =>
      ValidityType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ValidityType.noExpiration,
      );
}

/// 首页的状态筛选项。
enum StatusFilter {
  active('激活'),
  inactive('未激活'),
  expiringSoon('即将到期'),
  expired('已过期');

  const StatusFilter(this.label);
  final String label;
}

/// 排序依据
enum SortBy {
  createdAt('添加时间'),
  expirationDate('到期时间'),
  carrierName('运营商'),
  countryCode('国家/地区');

  const SortBy(this.label);
  final String label;
}

/// 排序顺序
enum SortOrder {
  ascending('升序'),
  descending('降序');

  const SortOrder(this.label);
  final String label;

  SortOrder get toggled =>
      this == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending;
}
