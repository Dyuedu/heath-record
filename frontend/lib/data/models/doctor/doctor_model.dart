enum Gender { male, female }

class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int heartCount; // Số lượng tim để lọc theo mức độ ưa thích
  final Gender gender;
  final String imageUrl;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.heartCount,
    required this.gender,
    required this.imageUrl,
  });

  // Chuyển từ JSON từ Backend sang Object Flutter
  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      heartCount: json['heartCount'] ?? 0,
      gender: json['gender'] == 'male' ? Gender.male : Gender.female,
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}