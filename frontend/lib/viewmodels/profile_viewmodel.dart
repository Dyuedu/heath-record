import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/add_relative_result_model.dart';
import 'package:frontend/data/models/record/add_relative_request.dart';
import 'package:frontend/data/models/record/relative.dart';
import 'package:frontend/data/models/user/doctor_patient_detail_model.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel({required ProfileRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  bool _isFamilyLoading = false;
  bool _isAddLoading = false;
  String? _errorMessage;
  String? _familyErrorMessage;
  String? _addErrorMessage;
  String? _doctorSearchErrorMessage;
  UserProfileModel? _profile;
  List<Relative> _familyProfiles = const [];
  List<UserProfileModel> _doctorSearchResults = const [];
  bool _isDoctorSearchLoading = false;

  bool get isLoading => _isLoading;
  bool get isFamilyLoading => _isFamilyLoading;
  bool get isAddLoading => _isAddLoading;
  String? get errorMessage => _errorMessage;
  String? get familyErrorMessage => _familyErrorMessage;
  String? get addErrorMessage => _addErrorMessage;
  String? get doctorSearchErrorMessage => _doctorSearchErrorMessage;
  UserProfileModel? get profile => _profile;
  List<Relative> get familyProfiles => List.unmodifiable(_familyProfiles);
  List<UserProfileModel> get doctorSearchResults =>
      List.unmodifiable(_doctorSearchResults);
  bool get isDoctorSearchLoading => _isDoctorSearchLoading;

  Future<void> loadOverview() async {
    _errorMessage = null;
    _familyErrorMessage = null;
    _setLoading(true);
    _setFamilyLoading(true);

    try {
      final results = await Future.wait([
        _repository.fetchMyProfile(),
        _repository.fetchFamilyProfiles(),
      ]);

      _profile = results[0] as UserProfileModel?;
      _familyProfiles = (results[1] as List<Relative>);

      if (_profile == null) {
        _errorMessage = 'Không thể tải thông tin của bạn lúc này.';
      }
    } catch (_) {
      _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại sau.';
      _familyErrorMessage = 'Không thể tải hồ sơ người thân.';
    } finally {
      _setLoading(false);
      _setFamilyLoading(false);
    }
  }

  Future<void> reloadFamilyProfiles() async {
    _familyErrorMessage = null;
    _setFamilyLoading(true);

    try {
      _familyProfiles = await _repository.fetchFamilyProfiles();
    } catch (_) {
      _familyErrorMessage = 'Không thể tải hồ sơ người thân.';
    } finally {
      _setFamilyLoading(false);
    }
  }

  Future<AddRelativeResultModel?> addRelative(
    AddRelativeRequest request, {
    File? avatarFile,
  }) async {
    _addErrorMessage = null;
    _setAddLoading(true);

    try {
      final result = await _repository.addRelative(
        request,
        avatarFile: avatarFile,
      );
      if (result == null) {
        _addErrorMessage = 'Không thể thêm hồ sơ mới.';
        return null;
      }

      if (result.isCreated && result.relative != null) {
        _familyProfiles = [..._familyProfiles, result.relative!];
      }
      notifyListeners();
      return result;
    } catch (_) {
      _addErrorMessage = 'Không thể thêm hồ sơ mới.';
      return null;
    } finally {
      _setAddLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFamilyLoading(bool value) {
    _isFamilyLoading = value;
    notifyListeners();
  }

  void _setAddLoading(bool value) {
    _isAddLoading = value;
    notifyListeners();
  }

  Future<void> searchPatientsForDoctor(String keyword) async {
    final cleanKeyword = keyword.trim();
    _doctorSearchErrorMessage = null;

    if (cleanKeyword.isEmpty) {
      _doctorSearchResults = const [];
      notifyListeners();
      return;
    }

    _isDoctorSearchLoading = true;
    notifyListeners();

    try {
      _doctorSearchResults = await _repository.searchPatientsForDoctor(
        keyword: cleanKeyword,
      );
      if (_doctorSearchResults.isEmpty) {
        _doctorSearchErrorMessage = 'Không tìm thấy người dùng phù hợp.';
      }
    } catch (_) {
      _doctorSearchResults = const [];
      _doctorSearchErrorMessage = 'Không thể tìm kiếm lúc này.';
    } finally {
      _isDoctorSearchLoading = false;
      notifyListeners();
    }
  }

  Future<DoctorPatientDetailModel?> fetchDoctorPatientDetail(
    String patientId,
  ) {
    return _repository.fetchDoctorPatientDetail(patientId: patientId);
  }
}
