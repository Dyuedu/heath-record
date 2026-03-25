class AddRelativeRequest {
  final String fullname;
  final String nickname;
  final String identityNumber;
  final String gender;
  final String dateOfBirth;
  final String? phoneNumber;
  final String? allergy;
  final String? chronicDisease;
  final String? clinicalNotes;
  final String? bloodGroup;
  final String relationship;

  const AddRelativeRequest({
    required this.fullname,
    required this.nickname,
    required this.identityNumber,
    required this.gender,
    required this.dateOfBirth,
    this.phoneNumber,
    this.allergy,
    this.chronicDisease,
    this.clinicalNotes,
    this.bloodGroup,
    required this.relationship,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'fullname': fullname,
      'nickname': nickname,
      'identityNumber': identityNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'relationship': relationship,
    };

    final phone = phoneNumber;
    if (phone != null && phone.trim().isNotEmpty) {
      map['phoneNumber'] = phone;
    }

    final allergyValue = allergy;
    if (allergyValue != null && allergyValue.trim().isNotEmpty) {
      map['allergy'] = allergyValue;
    }

    final chronicDiseaseValue = chronicDisease;
    if (chronicDiseaseValue != null && chronicDiseaseValue.trim().isNotEmpty) {
      map['chronicDisease'] = chronicDiseaseValue;
    }

    final clinicalNotesValue = clinicalNotes;
    if (clinicalNotesValue != null && clinicalNotesValue.trim().isNotEmpty) {
      map['clinicalNotes'] = clinicalNotesValue;
    }

    final bloodGroupValue = bloodGroup;
    if (bloodGroupValue != null && bloodGroupValue.trim().isNotEmpty) {
      map['bloodGroup'] = bloodGroupValue;
    }

    return map;
  }
}
