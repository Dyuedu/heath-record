import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;

  UserViewModel({required UserRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  bool _isAvatarUploading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _avatarErrorMessage;
  Map<String, String> _fieldErrors = const {};
  UserProfileModel? _profile;

  bool get isLoading => _isLoading;
  bool get isAvatarUploading => _isAvatarUploading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get avatarErrorMessage => _avatarErrorMessage;
  Map<String, String> get fieldErrors => _fieldErrors;
  UserProfileModel? get profile => _profile;

  Future<void> loadMyProfile() async {
    _setLoading(true);
    _errorMessage = null;
    final data = await _repository.getMyProfile();
    if (data == null) {
      _errorMessage = 'Cannot load profile';
    } else {
      _profile = data;
    }
    _setLoading(false);
  }

  Future<bool> updateMyProfile({
    required String fullName,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
    required String address,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};

    final data = await _repository.updateMyProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      gender: gender,
      dateOfBirth: dateOfBirth,
      address: address,
    );

    if (data == null) {
      _fieldErrors = _repository.lastValidationErrors;
      final firstFieldError = _fieldErrors.values.isNotEmpty
          ? _fieldErrors.values.first
          : null;
      _errorMessage =
          _repository.lastErrorMessage ??
          (firstFieldError != null && firstFieldError.trim().isNotEmpty
              ? firstFieldError
              : 'Cập nhật hồ sơ thất bại');
      _setLoading(false);
      return false;
    }

    _profile = data;
    _successMessage = 'Profile updated successfully';
    _setLoading(false);
    return true;
  }

  Future<bool> requestPasswordOtp() async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final ok = await _repository.requestPasswordOtp();
    if (!ok) {
      _errorMessage = 'Cannot send OTP';
      _setLoading(false);
      return false;
    }

    _successMessage = 'OTP has been sent to your email';
    _setLoading(false);
    return true;
  }

  Future<bool> verifyPasswordOtp({required String otp}) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final ok = await _repository.verifyPasswordOtp(otp: otp);
    if (!ok) {
      _errorMessage = 'OTP is invalid or expired';
      _setLoading(false);
      return false;
    }

    _successMessage = 'OTP verified successfully';
    _setLoading(false);
    return true;
  }

  Future<bool> updatePasswordWithOtp({
    required String otp,
    required String newPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final ok = await _repository.updatePasswordWithOtp(
      otp: otp,
      newPassword: newPassword,
    );

    if (!ok) {
      _errorMessage = 'Password update failed';
      _setLoading(false);
      return false;
    }

    _successMessage = 'Password updated successfully';
    _setLoading(false);
    return true;
  }

  Future<bool> updateAvatar(File avatarFile) async {
    _avatarErrorMessage = null;
    _setAvatarUploading(true);

    final data = await _repository.uploadAvatar(avatarFile: avatarFile);
    if (data == null) {
      _avatarErrorMessage = 'Không thể cập nhật ảnh đại diện.';
      _setAvatarUploading(false);
      return false;
    }

    _profile = data;
    _setAvatarUploading(false);
    return true;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _fieldErrors = const {};
    notifyListeners();
  }

  void clearSessionData() {
    _isLoading = false;
    _isAvatarUploading = false;
    _errorMessage = null;
    _successMessage = null;
    _avatarErrorMessage = null;
    _fieldErrors = const {};
    _profile = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setAvatarUploading(bool value) {
    _isAvatarUploading = value;
    notifyListeners();
  }
}
