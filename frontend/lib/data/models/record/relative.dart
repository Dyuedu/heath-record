import 'dart:convert' as convert;

class Relative {
  String id;
  String name;
  String relationship;
  String? profileId;
  String? avatarUrl;
  String? dateOfBirth;

  Relative({
    required this.id,
    required this.name,
    required this.relationship,
    this.profileId,
    this.avatarUrl,
    this.dateOfBirth,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      if (profileId != null) 'profileId': profileId,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    };
  }

  String toJson() => convert.jsonEncode(toMap());

  factory Relative.fromMap(Map<String, dynamic> map) {
    return Relative(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      relationship: map['relationship']?.toString() ?? '',
      profileId: map['profileId']?.toString(),
      avatarUrl: map['avatarUrl']?.toString(),
      dateOfBirth: map['dateOfBirth']?.toString(),
    );
  }
}
