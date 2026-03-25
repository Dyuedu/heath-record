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
  final String status;
  final String? cccdFrontUrl;
  final String? cccdBackUrl;
  final String? diplomaUrl;
  final String? createdAt;
  final String? allergy;
  final String? chronicDisease;
  final String? clinicalNotes;
  final String? bloodGroup;

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
    required this.status,
    this.cccdFrontUrl,
    this.cccdBackUrl,
    this.diplomaUrl,
    this.createdAt,
    this.allergy,
    this.chronicDisease,
    this.clinicalNotes,
    this.bloodGroup,
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
      status: (map['status'] ?? 'ACTIVE').toString(), // Default to ACTIVE
      cccdFrontUrl: map['cccdFrontUrl']?.toString(),
      cccdBackUrl: map['cccdBackUrl']?.toString(),
      diplomaUrl: map['diplomaUrl']?.toString(),
      createdAt: map['createdAt']?.toString(),
      allergy: map['allergy']?.toString(),
      chronicDisease: map['chronicDisease']?.toString(),
      clinicalNotes: map['clinicalNotes']?.toString(),
      bloodGroup: map['bloodGroup']?.toString(),
    );
  }
}
