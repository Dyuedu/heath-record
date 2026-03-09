import 'dart:convert' as Convert;

class PatientModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final String gender;
  final String dateOfBirth;
  final String address;
  final String avatarUrl;

  PatientModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.gender,
    required this.dateOfBirth,
    required this.address,
    required this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'avatarUrl': avatarUrl,
    };
  }

  String toJson() => Convert.jsonEncode(toMap());

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? '',
      gender: map['gender'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      address: map['address'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }
}
