import 'dart:io';

import 'package:frontend/data/models/record/add_relative_result_model.dart';
import 'package:frontend/data/models/record/add_relative_request.dart';
import 'package:frontend/data/models/record/relative.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/profile_repository.dart';
import 'package:frontend/data/repositories/record_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class ProfileRepositoryImp implements ProfileRepository {
  final UserRepository _userRepository;
  final RecordRepository _recordRepository;

  ProfileRepositoryImp({
    required UserRepository userRepository,
    required RecordRepository recordRepository,
  }) : _userRepository = userRepository,
       _recordRepository = recordRepository;

  @override
  Future<UserProfileModel?> fetchMyProfile() {
    return _userRepository.getMyProfile();
  }

  @override
  Future<List<Relative>> fetchFamilyProfiles() {
    return _recordRepository.getMyRelatives();
  }

  @override
  Future<AddRelativeResultModel?> addRelative(
    AddRelativeRequest request, {
    File? avatarFile,
  }) {
    return _recordRepository.addRelative(request, avatarFile: avatarFile);
  }
}
