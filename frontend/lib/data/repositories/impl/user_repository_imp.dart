import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/user/doctor_patient_detail_model.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class UserRepositoryImp implements UserRepository {
  final DioClient _dioClient;
  String? _lastErrorMessage;
  Map<String, String> _lastValidationErrors = const {};

  UserRepositoryImp(this._dioClient);

  @override
  String? get lastErrorMessage => _lastErrorMessage;

  @override
  Map<String, String> get lastValidationErrors => _lastValidationErrors;

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
    required String allergy,
    required String chronicDisease,
    required String clinicalNotes,
    required String bloodGroup,
  }) async {
    _clearLastError();
    try {
      final response = await _dioClient.dio.put(
        '/api/users/me',
        data: {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'address': address,
          'allergy': allergy,
          'chronicDisease': chronicDisease,
          'clinicalNotes': clinicalNotes,
          'bloodGroup': bloodGroup,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserProfileModel.fromMap(
          Map<String, dynamic>.from(response.data),
        );
      }
      return null;
    } on DioException catch (error) {
      _captureErrorFromDio(error);
      return null;
    } catch (_) {
      _lastErrorMessage = 'Không thể cập nhật hồ sơ.';
      return null;
    }
  }

  @override
  Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '/api/users/me/password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
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

  void _clearLastError() {
    _lastErrorMessage = null;
    _lastValidationErrors = const {};
  }

  void _captureErrorFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final message = map['message']?.toString();
      _lastErrorMessage = (message != null && message.trim().isNotEmpty)
          ? message
          : 'Không thể cập nhật hồ sơ.';

      final validation = map['validationErrors'];
      if (validation is Map) {
        _lastValidationErrors = validation.map(
          (key, value) => MapEntry(
            key.toString(),
            value?.toString() ?? 'Dữ liệu không hợp lệ',
          ),
        );
      }
      return;
    }

    _lastErrorMessage = 'Không thể cập nhật hồ sơ.';
  }

  @override
  Future<List<UserProfileModel>> searchPatientsForDoctor({
    required String keyword,
  }) async {
    final cleanKeyword = keyword.trim();
    if (cleanKeyword.isEmpty) {
      return const [];
    }

    try {
      final response = await _dioClient.dio.get(
        '/api/v1/doctor/records/profiles/search',
        queryParameters: {'query': cleanKeyword},
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (e) =>
                  UserProfileModel.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<DoctorPatientDetailModel?> fetchDoctorPatientDetail({
    required String patientId,
  }) async {
    final id = patientId.trim();
    if (id.isEmpty) {
      return null;
    }

    try {
      final response = await _dioClient.dio.get(
        '/api/v1/doctor/records/patients/$id/detail',
      );
      if (response.statusCode == 200 && response.data != null) {
        return DoctorPatientDetailModel.fromMap(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<UserProfileModel>> fetchDoctors({
    String? keyword,
    String? department,
  }) async {
    final cleanKeyword = keyword?.trim() ?? '';
    final cleanDepartment = department?.trim() ?? '';
    final query = <String, String>{};
    if (cleanKeyword.isNotEmpty) {
      query['keyword'] = cleanKeyword;
    }
    if (cleanDepartment.isNotEmpty) {
      query['department'] = cleanDepartment;
    }
    try {
      final response = await _dioClient.dio.get(
        '/api/doctors',
        queryParameters: query.isEmpty ? null : query,
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (e) =>
                  UserProfileModel.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }
}
