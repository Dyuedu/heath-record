import 'package:frontend/data/models/user/user_profile_model.dart';

abstract class UserRepository {
  Future<UserProfileModel?> getMyProfile();

  Future<UserProfileModel?> updateMyProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
    required String address,
    String avatarUrl,
  });

  Future<bool> requestPasswordOtp();

  Future<bool> verifyPasswordOtp({required String otp});

  Future<bool> updatePasswordWithOtp({
    required String otp,
    required String newPassword,
  });
}
