import 'dart:convert';

import 'json_utils.dart';

/// SIM 卡可能支持的功能。枚举名同时是备份 JSON 中的键，不可随意修改。
enum Feature {
  voice,
  sms,
  data,
  wifiCalling,
  volte,
  hotspot,
  esimTransfer,
  intlRoaming,
}

/// 单个功能项：是否支持 + 可选备注（不可变）。
class FeatureItem {
  const FeatureItem({this.supported = false, this.note});

  final bool supported;
  final String? note;

  static const Object _unset = Object();

  /// 复制并修改。与常见的 `??` 写法不同，显式传入 `note: null` 会清除备注。
  FeatureItem copyWith({bool? supported, Object? note = _unset}) => FeatureItem(
    supported: supported ?? this.supported,
    note: identical(note, _unset) ? this.note : note as String?,
  );

  Map<String, Object?> toJson() => {
    'supported': supported,
    if (note != null && note!.isNotEmpty) 'note': note,
  };

  factory FeatureItem.fromJson(Map<String, dynamic> json) => FeatureItem(
    supported: json.optBool('supported') ?? false,
    note: json.optString('note'),
  );
}

/// SIM卡功能集合
class FeatureSet {
  FeatureSet([Map<Feature, FeatureItem>? items])
    : _items = {
        for (final feature in Feature.values)
          feature: items?[feature] ?? const FeatureItem(),
      };

  final Map<Feature, FeatureItem> _items;

  FeatureItem operator [](Feature feature) => _items[feature]!;

  void operator []=(Feature feature, FeatureItem item) =>
      _items[feature] = item;

  /// 按固定顺序遍历所有功能项，用于 UI。
  Iterable<MapEntry<Feature, FeatureItem>> get entries =>
      Feature.values.map((f) => MapEntry(f, _items[f]!));

  /// 已支持的功能数量
  int get supportedCount => _items.values.where((i) => i.supported).length;

  /// 独立副本（编辑表单使用，取消编辑时不影响原卡片）。
  FeatureSet copy() => FeatureSet(_items);

  Map<String, Object?> toJson() => {
    for (final feature in Feature.values)
      feature.name: _items[feature]!.toJson(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory FeatureSet.fromJson(Map<String, dynamic> json) => FeatureSet({
    for (final feature in Feature.values)
      feature: FeatureItem.fromJson(
        json.optMap(feature.name) ?? const <String, dynamic>{},
      ),
  });

  factory FeatureSet.fromJsonString(String jsonString) {
    if (jsonString.isEmpty) return FeatureSet();
    final decoded = jsonDecode(jsonString);
    return decoded is Map<String, dynamic>
        ? FeatureSet.fromJson(decoded)
        : FeatureSet();
  }
}
