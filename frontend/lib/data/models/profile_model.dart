class ProfileModel {
  final String id;
  final String fullName;
  final String medicalCode;
  final String birthDate;
  final String gender;
  final String phoneNumber;
  final String address;
  final String medicalHistory;
  final String allergy;
  final String? avatarUrl;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.medicalCode,
    this.birthDate = '',
    this.gender = 'Nam',
    this.phoneNumber = '',
    this.address = '',
    this.medicalHistory = '',
    this.allergy = '',
    this.avatarUrl,
  });
}