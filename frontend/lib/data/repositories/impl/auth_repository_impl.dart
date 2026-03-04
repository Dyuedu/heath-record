import 'package:dio/dio.dart';
import 'package:frontend/data/models/login_request.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Box _userBox;
  final Dio _dio;
  final SecureStorageRepository _secureStorageRepository;

  AuthRepositoryImpl(this._userBox, this._dio, this._secureStorageRepository);

  @override
  Future<String> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: request.toJson(),
      );
      final String token = response.data['token'];
      await _secureStorageRepository.saveToken(token);
      return token;

    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorageRepository.getToken();
  }

  @override
  Future<String> getUidFromToken(String token) async{
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['sub'];
      return userId;
    } catch (e) {
      throw Exception("Error decoding token: $e");
    }
  }
}
