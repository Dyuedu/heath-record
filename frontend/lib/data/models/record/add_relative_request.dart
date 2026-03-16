class AddRelativeRequest {
  final String fullname;
  final String nickname;
  final String gender;
  final String dateOfBirth;
  final String phoneNumber;
  final String relationship;

  const AddRelativeRequest({
    required this.fullname,
    required this.nickname,
    required this.gender,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.relationship,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullname': fullname,
      'nickname': nickname,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
    };
  }
}
