import 'package:flutter/material.dart';
import 'package:frontend/data/models/auth/login_request.dart';
import 'package:frontend/data/models/auth/register_request.dart';
import 'package:frontend/data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;

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
        _userRole = await _authRepository.getUserRole();
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
      _userRole = null;
    } catch (e) {
      // Có thể log lỗi nếu cần, nhưng không cần thiết phải hiển thị lỗi logout cho người dùng
    } finally {
      _setLoading(false);
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
        _userRole = await _authRepository.getUserRole();
      }
      return isLogged;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(
    String fullname,
    String email,
    String phone,
    String password,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final request = RegisterRequest(
        fullname: fullname,
        email: email,
        phone: phone,
        password: password,
      );
      final success = await _authRepository.register(request);

      if (!success) {
        _errorMessage = "Đăng ký thất bại. Vui lòng thử lại.";
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
}
