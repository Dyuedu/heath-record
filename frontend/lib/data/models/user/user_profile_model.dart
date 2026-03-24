class UserProfileModel {
  final String id;
  final String email;
  final String phoneNumber;
  final String identityNumber;
  final String fullName;
  final String role;
  final String gender;
  final String dateOfBirth;
  final String address;
  final String avatarUrl;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.identityNumber,
    required this.fullName,
    required this.role,
    required this.gender,
    required this.dateOfBirth,
    required this.address,
    required this.avatarUrl,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: (map['id'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phoneNumber: (map['phoneNumber'] ?? '').toString(),
      identityNumber: (map['identityNumber'] ?? '').toString(),
      fullName: (map['fullName'] ?? '').toString(),
      role: (map['role'] ?? '').toString(),
      gender: (map['gender'] ?? '').toString(),
      dateOfBirth: (map['dateOfBirth'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      avatarUrl: (map['avatarUrl'] ?? '').toString(),
    );
  }
}
