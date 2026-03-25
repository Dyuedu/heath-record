class RelativeProfileDetailModel {
  final String profileId;
  final String relativeId;
  final String relativeName;
  final String relationship;
  final String? avatarUrl;
  final String? fullName;
  final String? nickname;
  final String? identityNumber;
  final String? gender;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String? address;
  final String? allergy;
  final String? chronicDisease;
  final String? clinicalNotes;
  final String? bloodGroup;

  const RelativeProfileDetailModel({
    required this.profileId,
    required this.relativeId,
    required this.relativeName,
    required this.relationship,
    this.avatarUrl,
    this.fullName,
    this.nickname,
    this.identityNumber,
    this.gender,
    this.dateOfBirth,
    this.phoneNumber,
    this.address,
    this.allergy,
    this.chronicDisease,
    this.clinicalNotes,
    this.bloodGroup,
  });

  factory RelativeProfileDetailModel.fromMap(Map<String, dynamic> map) {
    return RelativeProfileDetailModel(
      profileId: (map['profileId'] ?? '').toString(),
      relativeId: (map['relativeId'] ?? '').toString(),
      relativeName: (map['relativeName'] ?? '').toString(),
      relationship: (map['relationship'] ?? '').toString(),
      avatarUrl: map['avatarUrl']?.toString(),
      fullName: map['fullName']?.toString(),
      nickname: map['nickname']?.toString(),
      identityNumber: map['identityNumber']?.toString(),
      gender: map['gender']?.toString(),
      dateOfBirth: map['dateOfBirth']?.toString(),
      phoneNumber: map['phoneNumber']?.toString(),
      address: map['address']?.toString(),
      allergy: map['allergy']?.toString(),
      chronicDisease: map['chronicDisease']?.toString(),
      clinicalNotes: map['clinicalNotes']?.toString(),
      bloodGroup: map['bloodGroup']?.toString(),
    );
  }
}
