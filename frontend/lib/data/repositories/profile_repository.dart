import 'dart:io';

import 'package:frontend/data/models/record/add_relative_result_model.dart';
import 'package:frontend/data/models/record/add_relative_request.dart';
import 'package:frontend/data/models/record/relative.dart';
import 'package:frontend/data/models/user/doctor_patient_detail_model.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';

abstract class ProfileRepository {
  Future<UserProfileModel?> fetchMyProfile();

  Future<List<Relative>> fetchFamilyProfiles();

  Future<AddRelativeResultModel?> addRelative(
    AddRelativeRequest request, {
    File? avatarFile,
  });

  Future<List<UserProfileModel>> searchPatientsForDoctor({
    required String keyword,
  });

  Future<DoctorPatientDetailModel?> fetchDoctorPatientDetail({
    required String patientId,
  });
}
