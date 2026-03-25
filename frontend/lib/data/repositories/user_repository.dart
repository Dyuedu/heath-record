import 'dart:io';

import 'package:frontend/data/models/user/doctor_patient_detail_model.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';

abstract class UserRepository {
  String? get lastErrorMessage;
  Map<String, String> get lastValidationErrors;

  Future<UserProfileModel?> getMyProfile();

  Future<UserProfileModel?> updateMyProfile({
    required String fullName,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
    required String address,
    required String allergy,
    required String chronicDisease,
    required String clinicalNotes,
    required String bloodGroup,
  });

  Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<UserProfileModel?> uploadAvatar({required File avatarFile});

  Future<List<UserProfileModel>> searchPatientsForDoctor({
    required String keyword,
  });

  Future<DoctorPatientDetailModel?> fetchDoctorPatientDetail({
    required String patientId,
  });

  Future<List<UserProfileModel>> fetchDoctors({String? keyword});
}
