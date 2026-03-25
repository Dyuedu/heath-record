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
  String? _lastErrorMessage;
  Map<String, String> _lastValidationErrors = const {};

  AuthRepositoryImp(this._dioClient, this._secureStorageRepository);

  @override
  String? get lastErrorMessage => _lastErrorMessage;

  @override
  Map<String, String> get lastValidationErrors => _lastValidationErrors;

  void _clearLastError() {
    _lastErrorMessage = null;
    _lastValidationErrors = const {};
  }

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
    _clearLastError();
    try {
      final payload = request.toMap();
      payload['role'] =
          (payload['role']?.toString().trim().toLowerCase() ?? 'user');

      final response = await _dioClient.dio.post(
        '/api/auth/register',
        data: payload,
      );

      if (response.statusCode == 200 && response.data is Map) {
        return RegisterResultModel.fromMap(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      if (response.statusCode == 200) {
        return RegisterResultModel.fallbackSuccess();
      }
      throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final message = map['message']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          throw Exception(message);
        }

        final validation = map['validationErrors'];
        if (validation is Map && validation.isNotEmpty) {
          final firstError = validation.values.first?.toString();
          if (firstError != null && firstError.trim().isNotEmpty) {
            throw Exception(firstError);
          }
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw Exception('Kết nối tới máy chủ bị timeout. Vui lòng thử lại.');
      }

      throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
    } catch (_) {
      throw Exception('Đăng ký thất bại. Vui lòng thử lại.');
    }
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
  Future<bool> requestForgotPasswordOtp(String email) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/forgot-password/request-otp',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> verifyForgotPasswordOtp(String email, String otp) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/forgot-password/verify-otp',
        data: {'email': email, 'otp': otp},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> resetForgotPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/forgot-password/reset',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (_) {
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
