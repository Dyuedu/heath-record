import 'package:frontend/data/models/user/user_profile_model.dart';

enum Gender { male, female }

class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int heartCount; // Số lượng tim để lọc theo mức độ ưa thích
  final Gender gender;
  final String imageUrl;
  final int experienceYears;
  final int reviewCount;
  final String availability;
  final String profile;
  final String careerPath;
  final String highlights;
  final List<String> availableSlots;
  final String contactEmail;
  final String contactPhone;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.heartCount,
    required this.gender,
    required this.imageUrl,
    required this.experienceYears,
    required this.reviewCount,
    required this.availability,
    required this.profile,
    required this.careerPath,
    required this.highlights,
    required this.availableSlots,
    required this.contactEmail,
    required this.contactPhone,
  });

  // Chuyển từ JSON từ Backend sang Object Flutter
  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: (json['department'] ?? json['specialty'] ?? '').toString(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      heartCount: json['heartCount'] ?? 0,
      gender: json['gender'] == 'male' ? Gender.male : Gender.female,
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      experienceYears: json['experienceYears'] ?? 10,
      reviewCount: json['reviewCount'] ?? 0,
      availability: json['availability'] ?? 'Mon-Fri / 9:00AM - 5:00PM',
      profile: json['profile'] ?? 'Profile not provided yet.',
      careerPath: json['careerPath'] ?? 'Career path not provided yet.',
      highlights: json['highlights'] ?? 'Highlights not provided yet.',
      availableSlots: List<String>.from(json['availableSlots'] ?? const []),
      contactEmail: json['contactEmail'] ?? 'contact@health.com',
      contactPhone: json['contactPhone'] ?? '+1 000 000 0000',
    );
  }

  factory DoctorModel.fromUserProfile(UserProfileModel profile) {
    final genderString = profile.gender.trim().toLowerCase();
    final gender = genderString == 'nam' ? Gender.male : Gender.female;
    final fallbackName = profile.fullName.trim().isEmpty
        ? profile.email.trim()
        : profile.fullName.trim();
    final department = profile.department.trim();
    final resolvedSpecialty = department.isNotEmpty
      ? department
      : 'Bác sĩ đa khoa';
    return DoctorModel(
      id: profile.id,
      name: fallbackName.isEmpty ? 'Bác sĩ' : fallbackName,
      specialty: resolvedSpecialty,
      rating: 4.9,
      heartCount: 0,
      gender: gender,
      imageUrl: profile.avatarUrl.trim().isEmpty
          ? 'https://via.placeholder.com/150'
          : profile.avatarUrl.trim(),
      experienceYears: 10,
      reviewCount: 0,
      availability: 'Liên hệ để biết lịch làm việc',
      profile: 'Thông tin đang được cập nhật.',
      careerPath: 'Đang cập nhật',
      highlights: 'Đang cập nhật',
      availableSlots: const [],
      contactEmail: profile.email,
      contactPhone: profile.phoneNumber,
    );
  }
}
