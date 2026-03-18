import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class UserRepositoryImp implements UserRepository {
  final DioClient _dioClient;

  UserRepositoryImp(this._dioClient);

  @override
  Future<UserProfileModel?> getMyProfile() async {
    try {
      final response = await _dioClient.dio.get('/api/users/me');
      if (response.statusCode == 200 && response.data != null) {
        return UserProfileModel.fromMap(
          Map<String, dynamic>.from(response.data),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserProfileModel?> updateMyProfile({
    required String fullName,
    required String phoneNumber,
    required String gender,
    required String dateOfBirth,
    required String address,
    String avatarUrl = '',
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '/api/users/me',
        data: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'address': address,
          'avatarUrl': avatarUrl,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserProfileModel.fromMap(
          Map<String, dynamic>.from(response.data),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> requestPasswordOtp() async {
    try {
      final response = await _dioClient.dio.put(
        '/api/users/me/password',
        data: {'otp': '', 'newPassword': ''},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> verifyPasswordOtp({required String otp}) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/users/me/password/verify-otp',
        data: {'otp': otp},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> updatePasswordWithOtp({
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '/api/users/me/password',
        data: {'otp': otp, 'newPassword': newPassword},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<UserProfileModel?> uploadAvatar({required File avatarFile}) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          avatarFile.path,
          filename: _extractFileName(avatarFile),
        ),
      });

      final response = await _dioClient.dio.put(
        '/api/users/me/avatar',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserProfileModel.fromMap(
          Map<String, dynamic>.from(response.data),
        );
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  String _extractFileName(File file) {
    final segments = file.path.split(RegExp(r'[\\/]'));
    return segments.isNotEmpty ? segments.last : 'avatar.jpg';
  }
}
