import 'package:dio/dio.dart';
import 'package:frontend/data/repositories/auth_repository.dart';

class DioClient {
  final AuthRepository authRepository;
  late final Dio dio;

  DioClient(this.authRepository) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.33.67.160:8080',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Thêm Interceptor ngay khi khởi tạo
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await authRepository.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
             // Xử lý logout hoặc refresh token ở đây
          }
          return handler.next(e);
        },
      ),
    );
  }
}