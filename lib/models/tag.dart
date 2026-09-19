/// 用户自定义标签模型
class Tag {
  int? id;
  String name;
  int color; // ARGB 颜色值
  DateTime createdAt;

  Tag({
    this.id,
    required this.name,
    required this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'color': color,
        'created_at': createdAt.toIso8601String(),
      };

  factory Tag.fromMap(Map<String, dynamic> map) => Tag(
        id: map['id'] as int?,
        name: map['name'] as String,
        color: map['color'] as int,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'] as int?,
        name: json['name'] as String,
        color: json['color'] as int,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );

  Tag copyWith({String? name, int? color}) => Tag(
        id: id,
        name: name ?? this.name,
        color: color ?? this.color,
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Tag && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Tag(id: $id, name: $name)';
}
