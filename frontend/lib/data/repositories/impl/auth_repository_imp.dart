import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/auth/login_request.dart';
import 'package:frontend/data/models/auth/register_request.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthRepositoryImp implements AuthRepository {
  final DioClient _dioClient;
  final SecureStorageRepository _secureStorageRepository;

  AuthRepositoryImp(this._dioClient, this._secureStorageRepository);
  @override
  Future<bool> isLoggedIn() {
    return _secureStorageRepository.getToken().then((token) => token != null);
  }

  @override
  Future<bool> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/login',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _secureStorageRepository.saveToken(token);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  @override
  Future<void> logout() {
    return _secureStorageRepository.deleteToken();
  }

  @override
  Future<bool> register(RegisterRequest request) {
    return _dioClient.dio
        .post('/api/auth/register', data: request.toJson())
        .then((response) {
          if (response.statusCode == 200) {
            return true;
          } else {
            return false;
          }
        })
        .catchError((error) {
          print('Register error: $error');
          return false;
        });
  }

  @override
  Future<bool> isAuthenticated() {
    return _secureStorageRepository.getToken().then((token) {
      if (token == null) return false;
      return !JwtDecoder.isExpired(token);
    });
  }

  @override
  Future<String?> getUserRole() async {
    final token = await _secureStorageRepository.getToken();
    if (token == null) return null;
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['role'] as String?;
    } catch (e) {
      return null;
    }
  }
}
