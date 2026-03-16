import 'package:dio/dio.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/admin/admin_user_payload.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/admin_repository.dart';

class AdminRepositoryImp implements AdminRepository {
  final DioClient _dioClient;

  AdminRepositoryImp(this._dioClient);

  @override
  Future<List<UserProfileModel>> getAllUsers() async {
    try {
      final response = await _dioClient.dio.get('/api/admin/users');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => UserProfileModel.fromMap(item))
            .toList();
      }
    } on DioException catch (error) {
      print('Get users failed: ${error.message}');
    } catch (error) {
      print('Unexpected error when fetching users: $error');
    }
    return [];
  }

  @override
  Future<UserProfileModel?> createUser(AdminUserPayload payload) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/admin/users',
        data: payload.toMap(),
      );
      if (response.statusCode == 201 && response.data != null) {
        return UserProfileModel.fromMap(response.data);
      }
    } on DioException catch (error) {
      print('Create user failed: ${error.message}');
    } catch (error) {
      print('Unexpected error when creating user: $error');
    }
    return null;
  }

  @override
  Future<UserProfileModel?> updateUser({
    required String id,
    required AdminUserPayload payload,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '/api/admin/users/$id',
        data: payload.toMap(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return UserProfileModel.fromMap(response.data);
      }
    } on DioException catch (error) {
      print('Update user failed: ${error.message}');
    } catch (error) {
      print('Unexpected error when updating user: $error');
    }
    return null;
  }
}
