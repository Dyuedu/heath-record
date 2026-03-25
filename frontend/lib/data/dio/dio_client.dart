import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';
import 'package:frontend/utils/app_routers.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/main.dart'; // Để lấy navigatorKey

class DioClient {
  final SecureStorageRepository _storage;
  late final Dio _dio;
  static bool _isNavigatingToLogin = false;

  DioClient(this._storage) {
    final envBaseUrl = (dotenv.env['API_BASE_URL'] ?? '').trim();
    final configuredBaseUrl = envBaseUrl.isNotEmpty
        ? envBaseUrl
        : const String.fromEnvironment('API_BASE_URL');

    if (configuredBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is required. Please set API_BASE_URL in .env or via --dart-define.',
      );
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: _normalizeBaseUrl(configuredBaseUrl),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;
          final isAuthEndpoint = path.startsWith('/api/auth/');
          if (isAuthEndpoint) {
            options.headers.remove('Authorization');
            return handler.next(options);
          }

          final token = await _storage.getToken();

          if (token != null && token.trim().isNotEmpty) {
            // Kiểm tra hết hạn chủ động phía Client
            try {
              if (JwtDecoder.isExpired(token)) {
                await _storage.deleteToken();
                _redirectToLogin();
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    message: "Token expired",
                    type: DioExceptionType.badResponse,
                  ),
                );
              }
              options.headers['Authorization'] = 'Bearer $token';
            } catch (e) {
              await _storage.deleteToken();
              _redirectToLogin();
              return handler.reject(
                DioException(
                  requestOptions: options,
                  message: "Invalid token format",
                  type: DioExceptionType.badResponse,
                ),
              );
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Xử lý khi Server trả về 401 Unauthorized
          if (e.response?.statusCode == 401) {
            String? errorMessage;
            if (e.response?.data is Map &&
                e.response!.data['message'] != null) {
              errorMessage = e.response!.data['message'];
            }
            await _storage.deleteToken();
            _redirectToLogin(errorMessage);
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Hàm điều hướng tập trung
  void _redirectToLogin([String? message]) {
    if (_isNavigatingToLogin) return;
    _isNavigatingToLogin = true;

    // Đảm bảo điều hướng được thực hiện sau khi frame được xây dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRouter.login,
        (route) => false,
        arguments: message,
      );
    });

    Future.delayed(const Duration(seconds: 2), () {
      _isNavigatingToLogin = false;
    });
  }

  String _normalizeBaseUrl(String baseUrl) {
    String value = baseUrl.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  Dio get dio => _dio;
}
