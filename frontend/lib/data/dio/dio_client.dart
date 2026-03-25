import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/app_routers.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';
import 'package:frontend/main.dart'; // Để lấy navigatorKey

class DioClient {
  final SecureStorageRepository _storage;
  late final Dio _dio;
  static bool _isNavigatingToLogin = false;

  DioClient(this._storage) {
    final configuredBaseUrl = const String.fromEnvironment('API_BASE_URL');
    final fallbackBaseUrl = _getBaseUrl();

    _dio = Dio(
      BaseOptions(
        baseUrl: configuredBaseUrl.isNotEmpty
            ? configuredBaseUrl
            : fallbackBaseUrl,
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

  // Hàm lấy base URL với hỗ trợ cả emulator và thiết bị thật
  String _getBaseUrl() {
    const String localIp =
        '192.168.0.132'; // Thay đổi IP này thành IP máy tính của bạn
    const int port = 8081;

    // Web platform
    if (kIsWeb) {
      return 'http://localhost:$port';
    }

    // Android
    if (Platform.isAndroid) {
      // Kiểm tra nếu đang chạy trên Android emulator
      if (_isRunningOnEmulator()) {
        return 'http://10.0.2.2:$port'; // Android emulator
      }
      // Thiết bị Android thật
      return 'http://$localIp:$port';
    }

    // iOS
    if (Platform.isIOS) {
      // Kiểm tra nếu đang chạy trên iOS simulator
      if (_isRunningOnSimulator()) {
        return 'http://localhost:$port'; // iOS simulator
      }
      // Thiết bị iOS thật
      return 'http://$localIp:$port';
    }

    // Default fallback
    return 'http://localhost:$port';
  }

  // Kiểm tra xem có đang chạy trên Android emulator không
  bool _isRunningOnEmulator() {
    return Platform.environment.containsKey('ANDROID_EMULATOR') ||
        Platform.environment.containsKey('RUNNING_IN_EMULATOR') ||
        (Platform.isAndroid && Platform.environment.containsKey('EMULATOR'));
  }

  // Kiểm tra xem có đang chạy trên iOS simulator không
  bool _isRunningOnSimulator() {
    return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') ||
        Platform.environment.containsKey('RUNNING_IN_SIMULATOR');
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

  Dio get dio => _dio;
}
