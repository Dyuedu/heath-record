import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/impl/auth_repository_impl.dart';
import 'package:frontend/data/repositories/impl/secure_storage_repository_imp.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';
import 'package:frontend/viewmodels/login_view_model.dart';
import 'package:frontend/viewmodels/register_view_model.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  static List<SingleChildWidget> getProviders() {
    return [
      Provider<Box>(create: (_) => Hive.box('userBox')),
      Provider<SecureStorageRepository>(
        create: (_) => SecureStorageRepositoryImp(const FlutterSecureStorage()),
      ),
      Provider<Dio>(
        create: (_) => Dio(BaseOptions(baseUrl: 'http://10.33.67.160:8080')),
      ),
      ProxyProvider<AuthRepository, DioClient>(
        update: (_, authRepo, _) => DioClient(authRepo),
      ),
      ProxyProvider3<Box, Dio, SecureStorageRepository, AuthRepository>(
        update: (_, box, dio, secureStorage, _) =>
            AuthRepositoryImpl(box, dio, secureStorage),
      ),
      ChangeNotifierProvider<LoginViewModel>(
        create: (context) =>
            LoginViewModel(authRepository: context.read<AuthRepository>()),
      ),
      ChangeNotifierProvider<RegisterViewModel>(
        create: (context) =>
            RegisterViewModel(authRepository: context.read<AuthRepository>()),
      ),
    ];
  }
}
