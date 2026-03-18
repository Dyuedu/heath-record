import 'package:flutter/material.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;

  UserViewModel({required UserRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  UserProfileModel? _profile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
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
    String avatarUrl = '',
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;

    final data = await _repository.updateMyProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      gender: gender,
      dateOfBirth: dateOfBirth,
      address: address,
      avatarUrl: avatarUrl,
    );

    if (data == null) {
      _errorMessage = 'Profile update failed';
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

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
