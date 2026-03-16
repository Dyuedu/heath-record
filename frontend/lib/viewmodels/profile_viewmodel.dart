import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/add_relative_request.dart';
import 'package:frontend/data/models/record/relative.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel({required ProfileRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  bool _isFamilyLoading = false;
  bool _isAvatarUploading = false;
  bool _isAddLoading = false;
  String? _errorMessage;
  String? _familyErrorMessage;
  String? _avatarErrorMessage;
  String? _addErrorMessage;
  UserProfileModel? _profile;
  List<Relative> _familyProfiles = const [];

  bool get isLoading => _isLoading;
  bool get isFamilyLoading => _isFamilyLoading;
  bool get isAvatarUploading => _isAvatarUploading;
  bool get isAddLoading => _isAddLoading;
  String? get errorMessage => _errorMessage;
  String? get familyErrorMessage => _familyErrorMessage;
  String? get avatarErrorMessage => _avatarErrorMessage;
  String? get addErrorMessage => _addErrorMessage;
  UserProfileModel? get profile => _profile;
  List<Relative> get familyProfiles => List.unmodifiable(_familyProfiles);

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

  Future<bool> updateAvatar(File avatarFile) async {
    _avatarErrorMessage = null;
    _setAvatarUploading(true);

    try {
      final updatedProfile = await _repository.uploadAvatar(avatarFile);
      if (updatedProfile == null) {
        _avatarErrorMessage = 'Không thể cập nhật ảnh đại diện.';
        return false;
      }

      _profile = updatedProfile;
      return true;
    } catch (_) {
      _avatarErrorMessage = 'Không thể cập nhật ảnh đại diện.';
      return false;
    } finally {
      _setAvatarUploading(false);
    }
  }

  Future<bool> addRelative(AddRelativeRequest request) async {
    _addErrorMessage = null;
    _setAddLoading(true);

    try {
      final relative = await _repository.addRelative(request);
      if (relative == null) {
        _addErrorMessage = 'Không thể thêm hồ sơ mới.';
        return false;
      }

      _familyProfiles = [..._familyProfiles, relative];
      notifyListeners();
      return true;
    } catch (_) {
      _addErrorMessage = 'Không thể thêm hồ sơ mới.';
      return false;
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

  void _setAvatarUploading(bool value) {
    _isAvatarUploading = value;
    notifyListeners();
  }

  void _setAddLoading(bool value) {
    _isAddLoading = value;
    notifyListeners();
  }
}
