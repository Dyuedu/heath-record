import 'package:frontend/data/models/auth/login_request.dart';
import 'package:frontend/data/models/auth/register_request.dart';

abstract class AuthRepository {
  Future<bool> login(LoginRequest request);
  Future<bool> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<dynamic> isAuthenticated() async {}
}