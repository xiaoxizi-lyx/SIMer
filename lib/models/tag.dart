import 'package:clock/clock.dart';

import 'json_utils.dart';

/// 用户自定义标签模型
class Tag {
  Tag({this.id, required this.name, required this.color, DateTime? createdAt})
    : createdAt = (createdAt ?? clock.now()).toUtc();

  /// 备份中缺少标签颜色时使用的默认色。
  static const int defaultColor = 0xFF5E5CE6;

  int? id;
  String name;
  int color; // ARGB 颜色值
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'color': color,
    'created_at': createdAt.toIso8601String(),
  };

  factory Tag.fromMap(Map<String, Object?> map) => Tag(
    id: map['id'] as int?,
    name: map['name']! as String,
    color: map['color']! as int,
    createdAt: DateTime.tryParse(map['created_at'] as String? ?? ''),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'createdAt': createdAt.toIso8601String(),
  };

  /// 从备份 JSON 解析。缺少颜色时使用默认色，类型错误抛出 [FormatException]。
  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    id: json.optInt('id'),
    name: json.reqString('name').trim(),
    color: json.optInt('color') ?? defaultColor,
    createdAt: json.optDateTime('createdAt'),
  );

  Tag copyWith({String? name, int? color}) => Tag(
    id: id,
    name: name ?? this.name,
    color: color ?? this.color,
    createdAt: createdAt,
  );

  /// 已入库的标签按 id 判等；尚未入库（id 为 null）的标签只与自身相等。
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Tag && id != null && other.id == id);

  @override
  int get hashCode => id?.hashCode ?? identityHashCode(this);

  @override
  String toString() => 'Tag(id: $id, name: $name)';
}
