class AddRelativeRequest {
  final String fullname;
  final String nickname;
  final String identityNumber;
  final String gender;
  final String dateOfBirth;
  final String? phoneNumber;
  final String relationship;

  const AddRelativeRequest({
    required this.fullname,
    required this.nickname,
    required this.identityNumber,
    required this.gender,
    required this.dateOfBirth,
    this.phoneNumber,
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
    return map;
  }
}
