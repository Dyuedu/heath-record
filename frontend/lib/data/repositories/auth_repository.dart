import 'package:frontend/data/models/login_request.dart';
import 'package:frontend/data/models/register_request.dart';

abstract class AuthRepository {
  Future<String> login(LoginRequest request);
  Future<void> register(RegisterRequest request);
  Future<String?> getToken();
  Future<String> getUidFromToken(String token);
}