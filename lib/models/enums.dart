// SIM 卡类型、激活状态、有效期等枚举定义。
// 界面上显示的名称见 lib/l10n/l10n.dart。

/// SIM卡类型
enum SimType {
  physicalSim,
  esim;

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
  active,
  inactive;

  static ActivationStatus fromString(String? value) =>
      ActivationStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ActivationStatus.active,
      );
}

/// 有效性：根据有效期设置与当前日期实时计算，不持久化。
enum ValidityState {
  /// 无期限卡。
  unlimited,

  /// 有期限类型，但缺少计算所需的日期/天数。
  unknown,
  valid,

  /// 处于提前提醒窗口内（含到期日当天）。
  expiringSoon,
  expired,
}

/// 有效期类型
enum ValidityType {
  fixedDate,
  rolling,
  noExpiration;

  static ValidityType fromString(String? value) =>
      ValidityType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ValidityType.noExpiration,
      );
}

/// 首页的状态筛选项。
enum StatusFilter { active, inactive, expiringSoon, expired }

/// 排序依据
enum SortBy { createdAt, expirationDate, carrierName, countryCode }

/// 排序顺序
enum SortOrder {
  ascending,
  descending;

  SortOrder get toggled =>
      this == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending;
}
