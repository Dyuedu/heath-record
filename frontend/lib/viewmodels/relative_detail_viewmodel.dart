import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:frontend/data/models/record/relative_history_model.dart';
import 'package:frontend/data/models/record/relative_profile_detail_model.dart';
import 'package:frontend/data/models/record/update_relative_profile_request.dart';
import 'package:frontend/data/repositories/record_repository.dart';

class RelativeDetailViewModel extends ChangeNotifier {
  RelativeDetailViewModel({required RecordRepository repository})
      : _repository = repository;

  final RecordRepository _repository;

  bool isLoading = false;
  bool isProfileLoading = false;
  bool isUpdatingProfile = false;
  bool isUpdatingAvatar = false;
  String? errorMessage;
  String? profileErrorMessage;
  String? profileUpdateMessage;
  RelativeHistoryModel? history;
  RelativeProfileDetailModel? profileDetail;
  String? _activeProfileId;

  String? get activeProfileId => _activeProfileId;

  Future<void> loadHistory(String profileId, {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        history != null &&
        _activeProfileId == profileId &&
        !isLoading) {
      return;
    }

    final bool isSwitchingProfile = _activeProfileId != profileId;
    _activeProfileId = profileId;
    if (isSwitchingProfile) {
      history = null;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getHealthHistoryByProfileId(profileId);
      history = result;
      if (result == null) {
        errorMessage = 'Không tìm thấy dữ liệu sức khoẻ.';
      }
    } catch (_) {
      errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại sau.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String profileId) {
    return loadHistory(profileId, forceRefresh: true);
  }

  Future<void> loadRelativeProfile(String profileId) async {
    isProfileLoading = true;
    profileErrorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getRelativeProfileDetail(profileId);
      profileDetail = result;
      if (result == null) {
        profileErrorMessage = 'Không thể tải thông tin hồ sơ người thân.';
      }
    } catch (_) {
      profileErrorMessage = 'Không thể tải thông tin hồ sơ người thân.';
    } finally {
      isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRelativeProfile(
    String profileId,
    UpdateRelativeProfileRequest request,
  ) async {
    isUpdatingProfile = true;
    profileUpdateMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateRelativeProfile(profileId, request);
      if (updated == null) {
        profileUpdateMessage = 'Cập nhật hồ sơ thất bại.';
        return false;
      }

      profileDetail = updated;
      profileUpdateMessage = 'Cập nhật hồ sơ thành công.';
      return true;
    } catch (_) {
      profileUpdateMessage = 'Cập nhật hồ sơ thất bại.';
      return false;
    } finally {
      isUpdatingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> uploadRelativeAvatar(String profileId, File avatarFile) async {
    isUpdatingAvatar = true;
    profileUpdateMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateRelativeAvatar(profileId, avatarFile);
      if (updated == null) {
        profileUpdateMessage = 'Cập nhật ảnh đại diện thất bại.';
        return false;
      }
      profileDetail = updated;
      profileUpdateMessage = 'Cập nhật ảnh đại diện thành công.';
      return true;
    } catch (_) {
      profileUpdateMessage = 'Cập nhật ảnh đại diện thất bại.';
      return false;
    } finally {
      isUpdatingAvatar = false;
      notifyListeners();
    }
  }

  void clear() {
    history = null;
    profileDetail = null;
    errorMessage = null;
    profileErrorMessage = null;
    profileUpdateMessage = null;
    _activeProfileId = null;
    isLoading = false;
    isProfileLoading = false;
    isUpdatingProfile = false;
    isUpdatingAvatar = false;
    notifyListeners();
  }
}
