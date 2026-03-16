import 'package:frontend/data/models/user/user_profile_model.dart';

class AdminUserPayload {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final String? password;
  final String? gender;
  final String? dateOfBirth;
  final String? address;

  const AdminUserPayload({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.password,
    this.gender,
    this.dateOfBirth,
    this.address,
  });

  factory AdminUserPayload.fromUser(UserProfileModel user) {
    return AdminUserPayload(
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      role: user.role,
      gender: user.gender.isEmpty ? null : user.gender,
      dateOfBirth: user.dateOfBirth.isEmpty ? null : user.dateOfBirth,
      address: user.address.isEmpty ? null : user.address,
    );
  }

  AdminUserPayload copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? role,
    String? password,
    String? gender,
    String? dateOfBirth,
    String? address,
  }) {
    return AdminUserPayload(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': role,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'address': address,
    }..removeWhere(
      (key, value) =>
          value == null || (value is String && value.trim().isEmpty),
    );
  }
}
