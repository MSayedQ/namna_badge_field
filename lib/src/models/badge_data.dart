import 'dart:convert';

class BadgeData {
  BadgeData({this.id, required this.name});

  final int? id;
  final String name;

  @override
  bool operator ==(covariant BadgeData other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }
    result.addAll({'name': name});

    return result;
  }

  factory BadgeData.fromMap(Map<String, dynamic> map) {
    return BadgeData(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BadgeData.fromJson(String source) =>
      BadgeData.fromMap(json.decode(source));
}
