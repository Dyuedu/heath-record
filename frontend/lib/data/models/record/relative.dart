import 'dart:convert' as Convert;

class Relative {
  String id;
  String name;
  String relationship;

  Relative({required this.id, required this.name, required this.relationship});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'relationship': relationship};
  }

  String toJson() => Convert.jsonEncode(toMap());

  factory Relative.fromMap(Map<String, dynamic> map) {
    return Relative(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      relationship: map['relationship']?.toString() ?? '',
    );
  }
}
