import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/utils/app_routers.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';
import 'package:frontend/main.dart'; // Để lấy navigatorKey

class DioClient {
  final SecureStorageRepository _storage;
  late final Dio _dio;

  DioClient(this._storage) {
    final configuredBaseUrl = const String.fromEnvironment('API_BASE_URL');
    final fallbackBaseUrl = kIsWeb
        ? 'http://localhost:8081'
        : defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8081'
        : 'http://localhost:8081';

    _dio = Dio(
      BaseOptions(
        baseUrl: configuredBaseUrl.isNotEmpty
            ? configuredBaseUrl
            : fallbackBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();

          if (token != null) {
            // Kiểm tra hết hạn chủ động phía Client
            if (JwtDecoder.isExpired(token)) {
              await _storage.deleteToken();
              _redirectToLogin();
              return handler.reject(
                DioException(requestOptions: options, message: "Token expired"),
              );
            }
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Xử lý khi Server trả về 401 Unauthorized
          if (e.response?.statusCode == 401) {
            await _storage.deleteToken();
            _redirectToLogin();
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Hàm điều hướng tập trung
  void _redirectToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRouter.login,
      (route) => false,
    );
  }

  Dio get dio => _dio;
}
