class UpdateRelativeProfileRequest {
  final String fullName;
  final String nickname;
  final String identityNumber;
  final String gender;
  final String dateOfBirth;
  final String phoneNumber;
  final String address;
  final String? allergy;
  final String? chronicDisease;
  final String? clinicalNotes;
  final String bloodGroup;

  const UpdateRelativeProfileRequest({
    required this.fullName,
    required this.nickname,
    required this.identityNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    this.allergy,
    this.chronicDisease,
    this.clinicalNotes,
    required this.bloodGroup,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'nickname': nickname,
      'identityNumber': identityNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'address': address,
      'allergy': allergy,
      'chronicDisease': chronicDisease,
      'clinicalNotes': clinicalNotes,
      'bloodGroup': bloodGroup,
    };
  }
}
