import 'package:dio/dio.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/impl/auth_repository_impl.dart';

class DioClient {
  static final AuthRepository authRepository = AuthRepositoryImpl();
  static final Dio _instance = Dio(
    BaseOptions(
      baseUrl: 'http://10.33.67.160:8080',
      //baseUrl: 'http://192.168.1.25:8080',
      // baseUrl: 'https://api.dyucode.io.vn',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static Dio get instance {
    if (_instance.interceptors.isEmpty) {
      _instance.interceptors.add(
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
              print("Unauthorized! Redirecting to login...");
            }
            return handler.next(e);
          },
        ),
      );
    }
    return _instance;
  }
}
