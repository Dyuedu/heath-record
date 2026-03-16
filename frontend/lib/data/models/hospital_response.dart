class HospitalResponse {
  final int id;
  final String name;

  HospitalResponse({required this.id, required this.name});

  factory HospitalResponse.fromJson(Map<String, dynamic> json) {
    return HospitalResponse(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
    );
  }
}
