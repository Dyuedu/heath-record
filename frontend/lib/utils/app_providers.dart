import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/impl/auth_repository_imp.dart';
import 'package:frontend/data/repositories/impl/secure_storage_repository_imp.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  static List<SingleChildWidget> getProviders() {
    return [
      // initialize FlutterSecureStorage and provide it to the app
      Provider<FlutterSecureStorage>(
        create: (_) => const FlutterSecureStorage(),
      ),
      // provide SecureStorageRepository using the FlutterSecureStorage instance
      ProxyProvider<FlutterSecureStorage, SecureStorageRepository>(
        update: (context, secureStorage, previous) =>
            SecureStorageRepositoryImp(secureStorage),
      ),
      // provide DioClient using the SecureStorageRepository instance
      ProxyProvider<SecureStorageRepository, DioClient>(
        update: (context, secureStorageRepository, previous) =>
            DioClient(secureStorageRepository),
      ),
      ProxyProvider2<DioClient, SecureStorageRepository, AuthRepository>(
        update: (context, dioClient, secureStorageRepository, previous) =>
            AuthRepositoryImp(dioClient, secureStorageRepository),
      ),
      // Thay đổi ProxyProvider thành ChangeNotifierProxyProvider
      ChangeNotifierProxyProvider<AuthRepository, AuthViewModel>(
        create: (context) =>
            AuthViewModel(authRepository: context.read<AuthRepository>()),
        update: (context, authRepository, previous) {
          // Nếu previous đã tồn tại, ta trả về chính nó để giữ state
          // Nếu AuthRepository thay đổi, previous sẽ được cập nhật
          if (previous != null) return previous;
          return AuthViewModel(authRepository: authRepository);
        },
      ),
    ];
  }
}
