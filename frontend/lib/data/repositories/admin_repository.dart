import 'package:frontend/data/models/admin/admin_user_payload.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';

abstract class AdminRepository {
  Future<List<UserProfileModel>> getAllUsers();

  Future<Map<String, dynamic>?> getDashboardStats();

  Future<List<UserProfileModel>> searchUsers({
    String? search,
    String? role,
    String? status,
  });

  Future<List<UserProfileModel>> getPendingApprovals({
    String? search,
    String? role,
  });

  Future<UserProfileModel?> updateUserStatus(String id, String status);

  Future<UserProfileModel?> approveUser(String id);

  Future<UserProfileModel?> rejectUser(String id);

  Future<UserProfileModel?> createUser(AdminUserPayload payload);

  Future<UserProfileModel?> updateUser({
    required String id,
    required AdminUserPayload payload,
  });
}
