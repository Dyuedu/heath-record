import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/repositories/admin_repository.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/impl/admin_repository_imp.dart';
import 'package:frontend/data/repositories/impl/auth_repository_imp.dart';
import 'package:frontend/data/repositories/impl/secure_storage_repository_imp.dart';
import 'package:frontend/data/repositories/impl/user_repository_imp.dart';
import 'package:frontend/data/repositories/link_request_repository.dart';
import 'package:frontend/data/repositories/record_repository.dart';
import 'package:frontend/data/repositories/impl/profile_repository_imp.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/data/repositories/profile_repository.dart';
import 'package:frontend/viewmodels/admin_viewmodel.dart';
import 'package:frontend/viewmodels/auth_viewmodel.dart';
import 'package:frontend/viewmodels/doctor_viewmodel.dart';
import 'package:frontend/viewmodels/link_request_viewmodel.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:frontend/viewmodels/record_view_model.dart';
import 'package:frontend/viewmodels/relative_detail_viewmodel.dart';
import 'package:frontend/viewmodels/user_viewmodel.dart';
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
      ProxyProvider<DioClient, UserRepository>(
        update: (context, dioClient, previous) => UserRepositoryImp(dioClient),
      ),
      ProxyProvider2<DioClient, SecureStorageRepository, AuthRepository>(
        update: (context, dioClient, secureStorageRepository, previous) =>
            AuthRepositoryImp(dioClient, secureStorageRepository),
      ),
      ChangeNotifierProxyProvider2<
        AuthRepository,
        UserRepository,
        AuthViewModel
      >(
        create: (context) => AuthViewModel(
          authRepository: context.read<AuthRepository>(),
          userRepository: context.read<UserRepository>(),
        ),
        update: (context, authRepository, userRepository, previous) {
          if (previous != null) return previous;
          return AuthViewModel(
            authRepository: authRepository,
            userRepository: userRepository,
          );
        },
      ),
      ProxyProvider<DioClient, RecordRepository>(
        update: (context, dioClient, previous) =>
            RecordRepository(dioClient: dioClient),
      ),
      ProxyProvider<DioClient, LinkRequestRepository>(
        update: (context, dioClient, previous) =>
            LinkRequestRepository(dioClient: dioClient),
      ),
      ChangeNotifierProxyProvider<RecordRepository, RecordViewModel>(
        create: (context) =>
            RecordViewModel(repository: context.read<RecordRepository>()),
        update: (context, recordRepository, previous) =>
            previous ?? RecordViewModel(repository: recordRepository),
      ),
      ChangeNotifierProxyProvider<LinkRequestRepository, LinkRequestViewModel>(
        create: (context) => LinkRequestViewModel(
          repository: context.read<LinkRequestRepository>(),
        ),
        update: (context, repository, previous) =>
            previous ?? LinkRequestViewModel(repository: repository),
      ),
      ChangeNotifierProvider<RelativeDetailViewModel>(
        create: (context) => RelativeDetailViewModel(
          repository: context.read<RecordRepository>(),
        ),
      ),
      ChangeNotifierProvider<DoctorViewModel>(
        create: (context) => DoctorViewModel(),
      ),
      ChangeNotifierProxyProvider<UserRepository, UserViewModel>(
        create: (context) =>
            UserViewModel(repository: context.read<UserRepository>()),
        update: (context, userRepository, previous) =>
            previous ?? UserViewModel(repository: userRepository),
      ),
      ProxyProvider2<UserRepository, RecordRepository, ProfileRepository>(
        update: (context, userRepository, recordRepository, previous) =>
            ProfileRepositoryImp(
              userRepository: userRepository,
              recordRepository: recordRepository,
            ),
      ),
      ChangeNotifierProxyProvider<ProfileRepository, ProfileViewModel>(
        create: (context) =>
            ProfileViewModel(repository: context.read<ProfileRepository>()),
        update: (context, profileRepository, previous) =>
            previous ?? ProfileViewModel(repository: profileRepository),
      ),
      ProxyProvider<DioClient, AdminRepository>(
        update: (context, dioClient, previous) => AdminRepositoryImp(dioClient),
      ),
      ChangeNotifierProxyProvider<AdminRepository, AdminViewModel>(
        create: (context) =>
            AdminViewModel(repository: context.read<AdminRepository>()),
        update: (context, repository, previous) =>
            previous ?? AdminViewModel(repository: repository),
      ),
    ];
  }
}
