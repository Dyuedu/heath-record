import 'package:frontend/data/models/admin/admin_user_payload.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';

abstract class AdminRepository {
  Future<List<UserProfileModel>> getAllUsers();

  Future<UserProfileModel?> createUser(AdminUserPayload payload);

  Future<UserProfileModel?> updateUser({
    required String id,
    required AdminUserPayload payload,
  });
}
