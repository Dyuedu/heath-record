import 'package:frontend/data/models/login_request.dart';

abstract class AuthRepository {
  Future<String> login(LoginRequest request);
  Future<String?> getToken();
  Future<String> getUidFromToken(String token);
}