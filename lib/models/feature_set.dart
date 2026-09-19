import 'dart:convert';

/// 单个功能项：是否支持 + 可选备注
class FeatureItem {
  bool supported;
  String? note;

  FeatureItem({this.supported = false, this.note});

  Map<String, dynamic> toJson() => {
        'supported': supported,
        if (note != null && note!.isNotEmpty) 'note': note,
      };

  factory FeatureItem.fromJson(Map<String, dynamic> json) => FeatureItem(
        supported: json['supported'] as bool? ?? false,
        note: json['note'] as String?,
      );

  FeatureItem copyWith({bool? supported, String? note}) => FeatureItem(
        supported: supported ?? this.supported,
        note: note ?? this.note,
      );
}

/// SIM卡功能集合
class FeatureSet {
  FeatureItem voice; // 通话
  FeatureItem sms; // 短信
  FeatureItem data; // 数据流量
  FeatureItem wifiCalling; // Wi-Fi Calling
  FeatureItem volte; // VoLTE
  FeatureItem hotspot; // 热点共享
  FeatureItem esimTransfer; // eSIM转移
  FeatureItem intlRoaming; // 国际漫游

  FeatureSet({
    FeatureItem? voice,
    FeatureItem? sms,
    FeatureItem? data,
    FeatureItem? wifiCalling,
    FeatureItem? volte,
    FeatureItem? hotspot,
    FeatureItem? esimTransfer,
    FeatureItem? intlRoaming,
  })  : voice = voice ?? FeatureItem(),
        sms = sms ?? FeatureItem(),
        data = data ?? FeatureItem(),
        wifiCalling = wifiCalling ?? FeatureItem(),
        volte = volte ?? FeatureItem(),
        hotspot = hotspot ?? FeatureItem(),
        esimTransfer = esimTransfer ?? FeatureItem(),
        intlRoaming = intlRoaming ?? FeatureItem();

  /// 所有功能项的有序列表，用于 UI 遍历
  List<MapEntry<String, FeatureItem>> get entries => [
        MapEntry('通话', voice),
        MapEntry('短信', sms),
        MapEntry('数据流量', data),
        MapEntry('Wi-Fi Calling', wifiCalling),
        MapEntry('VoLTE', volte),
        MapEntry('热点共享', hotspot),
        MapEntry('eSIM转移', esimTransfer),
        MapEntry('国际漫游', intlRoaming),
      ];

  /// 已支持的功能数量
  int get supportedCount =>
      entries.where((e) => e.value.supported).length;

  Map<String, dynamic> toJson() => {
        'voice': voice.toJson(),
        'sms': sms.toJson(),
        'data': data.toJson(),
        'wifiCalling': wifiCalling.toJson(),
        'volte': volte.toJson(),
        'hotspot': hotspot.toJson(),
        'esimTransfer': esimTransfer.toJson(),
        'intlRoaming': intlRoaming.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory FeatureSet.fromJson(Map<String, dynamic> json) => FeatureSet(
        voice: FeatureItem.fromJson(json['voice'] as Map<String, dynamic>? ?? {}),
        sms: FeatureItem.fromJson(json['sms'] as Map<String, dynamic>? ?? {}),
        data: FeatureItem.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
        wifiCalling:
            FeatureItem.fromJson(json['wifiCalling'] as Map<String, dynamic>? ?? {}),
        volte: FeatureItem.fromJson(json['volte'] as Map<String, dynamic>? ?? {}),
        hotspot:
            FeatureItem.fromJson(json['hotspot'] as Map<String, dynamic>? ?? {}),
        esimTransfer:
            FeatureItem.fromJson(json['esimTransfer'] as Map<String, dynamic>? ?? {}),
        intlRoaming:
            FeatureItem.fromJson(json['intlRoaming'] as Map<String, dynamic>? ?? {}),
      );

  factory FeatureSet.fromJsonString(String jsonString) {
    if (jsonString.isEmpty) return FeatureSet();
    return FeatureSet.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  FeatureSet copyWith({
    FeatureItem? voice,
    FeatureItem? sms,
    FeatureItem? data,
    FeatureItem? wifiCalling,
    FeatureItem? volte,
    FeatureItem? hotspot,
    FeatureItem? esimTransfer,
    FeatureItem? intlRoaming,
  }) =>
      FeatureSet(
        voice: voice ?? this.voice.copyWith(),
        sms: sms ?? this.sms.copyWith(),
        data: data ?? this.data.copyWith(),
        wifiCalling: wifiCalling ?? this.wifiCalling.copyWith(),
        volte: volte ?? this.volte.copyWith(),
        hotspot: hotspot ?? this.hotspot.copyWith(),
        esimTransfer: esimTransfer ?? this.esimTransfer.copyWith(),
        intlRoaming: intlRoaming ?? this.intlRoaming.copyWith(),
      );

  /// 根据功能名获取对应 FeatureItem
  void updateByKey(String key, FeatureItem item) {
    switch (key) {
      case '通话':
        voice = item;
      case '短信':
        sms = item;
      case '数据流量':
        data = item;
      case 'Wi-Fi Calling':
        wifiCalling = item;
      case 'VoLTE':
        volte = item;
      case '热点共享':
        hotspot = item;
      case 'eSIM转移':
        esimTransfer = item;
      case '国际漫游':
        intlRoaming = item;
    }
  }
}
