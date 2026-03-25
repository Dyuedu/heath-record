import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/auth/login_request.dart';
import 'package:frontend/data/models/auth/register_request.dart';
import 'package:frontend/data/models/auth/register_result_model.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';
import 'package:dio/dio.dart';
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
      if (error is DioException && error.response?.data is Map) {
        final message = error.response!.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      return false;
    }
  }

  @override
  Future<void> logout() {
    return _secureStorageRepository.deleteToken();
  }

  @override
  Future<RegisterResultModel?> register(RegisterRequest request) async {
    try {
      final payload = request.toMap();
      payload['role'] =
          (payload['role']?.toString().trim().toLowerCase() ?? 'user');

      final response = await _dioClient.dio.post(
        '/api/auth/register',
        data: payload,
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return RegisterResultModel.fromMap(
          response.data as Map<String, dynamic>,
        );
      }
      if (response.statusCode == 200) {
        return RegisterResultModel.fallbackSuccess();
      }
    } on DioException catch (error) {
      if (error.response?.data is Map) {
        final data = error.response!.data;
        if (data['validationErrors'] != null && data['validationErrors'] is Map) {
          final errors = data['validationErrors'] as Map;
          if (errors.isNotEmpty) {
             throw Exception(errors.values.first.toString());
          }
        }
        if (data['message'] != null) {
          throw Exception(data['message'].toString());
        }
      }
      throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
    } catch (error) {
      print('Register error: $error');
      throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
    }
    return null;
  }

  @override
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );
      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> resendOtp(String email) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/resend-otp',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
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
