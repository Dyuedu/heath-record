import 'package:dio/dio.dart';
import 'package:frontend/data/models/login_request.dart';
import 'package:frontend/data/models/register_request.dart';
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
      String userId = await getUidFromToken(token);
      _userBox.put('user_info', {'userId': userId});
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
  Future<String> getUidFromToken(String token) async {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['sub'];
      return userId;
    } catch (e) {
      throw Exception("Error decoding token: $e");
    }
  }

  @override
  Future<void> register(RegisterRequest request) async {
    try {
      await _dio.post('/api/auth/register', data: request.toJson());
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        // Bóc tách theo cấu trúc: errors[0] -> message -> {email: ..., password: ...}
        if (data != null &&
            data['errors'] != null &&
            data['errors'].isNotEmpty) {
          final fieldErrors = data['errors'][0]['message'];
          if (fieldErrors is Map<String, dynamic>) {
            // Ném thẳng Map này về cho ViewModel
            throw fieldErrors;
          }
        }
      }
      throw Exception("Đã có lỗi xảy ra, vui lòng thử lại.");
    }
  }
}
