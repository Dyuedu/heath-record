class ProfileSearchResponse {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String dateOfBirth;
  final String avatarUrl;
  final String relationship;

  ProfileSearchResponse({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.avatarUrl,
    required this.relationship,
  });

  factory ProfileSearchResponse.fromJson(Map<String, dynamic> json) {
    return ProfileSearchResponse(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? 'Unknown List',
      phoneNumber: json['phoneNumber'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      relationship: json['relationship'] ?? '',
    );
  }
}
