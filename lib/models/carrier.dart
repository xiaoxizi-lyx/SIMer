import 'dart:ui';

/// 预置运营商模型
class Carrier {
  final String code; // 内部唯一标识，如 "cmcc"
  final String name; // 显示名称，如 "中国移动"
  final String countryCode; // ISO 3166-1 alpha-2，如 "CN"
  final Color themeColor; // 运营商主题色

  const Carrier({
    required this.code,
    required this.name,
    required this.countryCode,
    required this.themeColor,
  });

  @override
  String toString() => 'Carrier($code: $name)';
}

/// 运营商选择结果：预置运营商，或用户输入的自定义名称。
sealed class CarrierChoice {
  const CarrierChoice();
}

class PresetCarrierChoice extends CarrierChoice {
  const PresetCarrierChoice(this.carrier);
  final Carrier carrier;
}

class CustomCarrierChoice extends CarrierChoice {
  const CustomCarrierChoice(this.name);
  final String name;
}
