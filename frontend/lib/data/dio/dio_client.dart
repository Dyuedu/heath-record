import 'package:dio/dio.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';

class DioClient {
  final SecureStorageRepository _storage;
  late final Dio _dio;

  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.1.27:8081',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lấy token từ repo đã được inject
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            print("Unauthorized! Redirecting to login...");
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Getter để lấy instance của dio ra dùng
  Dio get dio => _dio;
}