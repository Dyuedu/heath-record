import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';

class SecureStorageRepositoryImp implements SecureStorageRepository {
  final FlutterSecureStorage _storage;
  SecureStorageRepositoryImp(this._storage);
  static const _jwtKey = 'JWT_TOKEN';
  @override
  Future<void> deleteToken() {
    return _storage.delete(key: _jwtKey);
  }

  @override
  Future<String?> getToken() {
    return _storage.read(key: _jwtKey);
  }

  @override
  Future<void> saveToken(String token) {
    return _storage.write(key: _jwtKey, value: token);
  }
}
