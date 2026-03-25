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
    return searchUsers();
  }

  @override
  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await _dioClient.dio.get('/api/admin/dashboard/stats');
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (error) {
      print('Get dashboard stats failed: ${error.message}');
    } catch (error) {
      print('Unexpected error when fetching dashboard stats: $error');
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getRecordStats(String period) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/admin/records/stats',
        queryParameters: {'period': period},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (error) {
      print('Get record stats failed: ${error.message}');
    } catch (error) {
      print('Unexpected error when fetching record stats: $error');
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getStats(String period, String type) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/admin/records/stats',
        queryParameters: {'period': period, 'type': type},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (error) {
      print('Get stats failed: ${error.message}');
    } catch (error) {
      print('Unexpected error when fetching stats: $error');
    }
    return null;
  }

  @override
  Future<List<UserProfileModel>> searchUsers({
    String? search,
    String? role,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (search != null && search.isNotEmpty) queryParameters['search'] = search;
      if (role != null && role.isNotEmpty) queryParameters['role'] = role;
      if (status != null && status.isNotEmpty) queryParameters['status'] = status;

      final response = await _dioClient.dio.get(
        '/api/admin/users',
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => UserProfileModel.fromMap(item))
            .toList();
      }
    } on DioException catch (error) {
      print('Search users failed: ${error.message}');
      print('Status code: ${error.response?.statusCode}');
      print('Response data: ${error.response?.data}');
    } catch (error) {
      print('Unexpected error when searching users: $error');
    }
    return [];
  }

  @override
  Future<List<UserProfileModel>> getPendingApprovals({
    String? search,
    String? role,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (search != null && search.isNotEmpty) queryParameters['search'] = search;
      if (role != null && role.isNotEmpty) queryParameters['role'] = role;

      final response = await _dioClient.dio.get(
        '/api/admin/approvals/pending',
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => UserProfileModel.fromMap(item))
            .toList();
      }
    } on DioException catch (error) {
      print('Get pending approvals failed: ${error.message}');
      print('Status code: ${error.response?.statusCode}');
      print('Response data: ${error.response?.data}');
    } catch (error) {
      print('Unexpected error when fetching pending approvals: $error');
    }
    return [];
  }

  @override
  Future<UserProfileModel?> updateUserStatus(String id, String status) async {
    try {
      final response = await _dioClient.dio.put(
        '/api/admin/users/$id/status',
        data: {'status': status},
      );
      if (response.statusCode == 200 && response.data != null) {
        return UserProfileModel.fromMap(response.data);
      }
    } on DioException catch (error) {
      print('Update user status failed: ${error.message}');
    } catch (error) {
      print('Unexpected error when updating user status: $error');
    }
    return null;
  }

  @override
  Future<UserProfileModel?> approveUser(String id) async {
    try {
      final response = await _dioClient.dio.post('/api/admin/approvals/$id/approve');
      if (response.statusCode == 200 && response.data != null) {
        return UserProfileModel.fromMap(response.data);
      }
    } on DioException catch (error) {
      print('Approve user failed: ${error.message}');
    } catch (error) {
      print('Unexpected error when approving user: $error');
    }
    return null;
  }

  @override
  Future<UserProfileModel?> rejectUser(String id) async {
    try {
      final response = await _dioClient.dio.post('/api/admin/approvals/$id/reject');
      if (response.statusCode == 200 && response.data != null) {
        return UserProfileModel.fromMap(response.data);
      }
    } on DioException catch (error) {
      print('Reject user failed: ${error.message}');
    } catch (error) {
      print('Unexpected error when rejecting user: $error');
    }
    return null;
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
