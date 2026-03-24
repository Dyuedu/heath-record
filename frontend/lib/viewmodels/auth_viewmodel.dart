import 'package:flutter/material.dart';
import 'package:frontend/data/models/auth/login_request.dart';
import 'package:frontend/data/models/auth/register_request.dart';
import 'package:frontend/data/models/auth/register_result_model.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentRole;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentRole => _currentRole;
  bool get isAdmin => (_currentRole ?? '').toUpperCase().contains('ADMIN');

  // Logic Đăng nhập
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final request = LoginRequest(email: email, password: password);
      final success = await _authRepository.login(request);

      if (!success) {
        _errorMessage = "Email hoặc mật khẩu không chính xác.";
      } else {
        await refreshCurrentRole();
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi kết nối. Vui lòng thử lại.";
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
      _currentRole = null;
    } catch (e) {
      // Có thể log lỗi nếu cần, nhưng không cần thiết phải hiển thị lỗi logout cho người dùng
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    _setLoading(true);
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      _setLoading(false);
      return isAuthenticated;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final isLogged = await _authRepository.isLoggedIn();
      if (isLogged) {
        final fetchedRole = await _authRepository.getUserRole();
        setRoleFromString(fetchedRole);
      } else {
        setRoleFromString(null);
      }
      return isLogged;
    } catch (e) {
      setRoleFromString(null);
      return false;
    }
  }

  Future<bool> register(
    String fullname,
    String? identityNumber,
    String role,
    String email,
    String phone,
    String password, {
    bool confirmLinkRequest = false,
  }) async {
    final result = await registerWithResult(
      fullname,
      identityNumber,
      role,
      email,
      phone,
      password,
      confirmLinkRequest: confirmLinkRequest,
    );
    return result != null;
  }

  Future<RegisterResultModel?> registerWithResult(
    String fullname,
    String? identityNumber,
    String role,
    String email,
    String phone,
    String password, {
    bool confirmLinkRequest = false,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final request = RegisterRequest(
        fullname: fullname,
        identityNumber: identityNumber,
        confirmLinkRequest: confirmLinkRequest,
        role: role,
        email: email,
        phone: phone,
        password: password,
      );
      final result = await _authRepository.register(request);

      if (result == null) {
        _errorMessage = "Đăng ký thất bại. Vui lòng thử lại.";
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi kết nối. Vui lòng thử lại.";
      _setLoading(false);
      return null;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final success = await _authRepository.verifyOtp(email, otp);
      if (!success) {
        _errorMessage = "Mã OTP không chính xác hoặc đã hết hạn.";
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi kết nối. Vui lòng thử lại.";
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final success = await _authRepository.resendOtp(email);
      if (!success) {
        _errorMessage = "Không thể gửi lại mã OTP lúc này.";
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi kết nối. Vui lòng thử lại.";
      _setLoading(false);
      return false;
    }
  }

  // Xóa thông báo lỗi khi người dùng bắt đầu nhập lại
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> refreshCurrentRole() async {
    try {
      final profile = await _userRepository.getMyProfile();
      _setCurrentRole(profile);
    } catch (_) {
      _setCurrentRole(null);
    }
  }

  void _setCurrentRole(UserProfileModel? profile) {
    final role = profile?.role;
    if (_currentRole != role) {
      _currentRole = role;
      notifyListeners();
    }
  }

  void setRoleFromString(String? role) {
    if (_currentRole != role) {
      _currentRole = role;
      notifyListeners();
    }
  }
}
