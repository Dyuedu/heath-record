import 'package:frontend/data/models/auth/login_request.dart';
import 'package:frontend/data/models/auth/register_request.dart';
import 'package:frontend/data/models/auth/register_result_model.dart';

abstract class AuthRepository {
  String? get lastErrorMessage;
  Map<String, String> get lastValidationErrors;

  Future<bool> login(LoginRequest request);
  Future<RegisterResultModel?> register(RegisterRequest request);
  Future<bool> verifyOtp(String email, String otp);
  Future<bool> resendOtp(String email);
  Future<bool> requestForgotPasswordOtp(String email);
  Future<bool> verifyForgotPasswordOtp(String email, String otp);
  Future<bool> resetForgotPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<dynamic> isAuthenticated() async {}
  Future<String?> getUserRole();
}
