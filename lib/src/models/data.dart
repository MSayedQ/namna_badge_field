
import 'dart:convert';

class OptionData {
  OptionData({this.id, required this.name});

  final int? id;
  final String name;

  @override
  bool operator ==(covariant OptionData other) {
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

  factory OptionData.fromMap(Map<String, dynamic> map) {
    return OptionData(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory OptionData.fromJson(String source) =>
      OptionData.fromMap(json.decode(source));
}
