import 'package:frontend/data/models/user/user_profile_model.dart';

class AdminUserPayload {
  final String? fullName;
  final String email;
  final String? phoneNumber;
  final String? identityNumber;
  final String role;
  final String? password;
  final String? gender;
  final String? dateOfBirth;
  final String? address;
  final String? status;

  const AdminUserPayload({
    this.fullName,
    required this.email,
    this.phoneNumber,
    this.identityNumber,
    required this.role,
    this.password,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.status,
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
    String? identityNumber,
    String? role,
    String? password,
    String? gender,
    String? dateOfBirth,
    String? address,
    String? status,
  }) {
    return AdminUserPayload(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      identityNumber: identityNumber ?? this.identityNumber,
      role: role ?? this.role,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'identityNumber': identityNumber,
      'password': password,
      'role': role,
      'status': status,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'address': address,
    }..removeWhere(
      (key, value) =>
          value == null || (value is String && value.trim().isEmpty),
    );
  }
}
