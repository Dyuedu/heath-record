import 'dart:convert' as Convert;

class Relative {
  String id;
  String name;

  Relative({required this.id, required this.name});

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'name': name,
    };
  }

  String toJson() => Convert.jsonEncode(toMap());

  factory Relative.fromMap(Map<String, dynamic> map) {
    return Relative(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
    );
  }
}