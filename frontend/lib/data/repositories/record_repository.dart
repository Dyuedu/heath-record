import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/record/add_relative_request.dart';
import 'package:frontend/data/models/record/add_relative_result_model.dart';
import 'package:frontend/data/models/record/medical_record_model.dart';
import 'package:frontend/data/models/record/relative.dart';
import 'package:frontend/data/models/record/relative_history_model.dart';
import 'package:frontend/data/models/hospital_response.dart';
import 'package:frontend/data/models/relative_search_response.dart';

class RecordRepository {
  final DioClient _dioClient;

  RecordRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<Relative>> getMyRelatives() async {
    try {
      final response = await _dioClient.dio.get('/api/relatives');
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => Relative.fromMap(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<MedicalRecordModel>> getRecordsByRelative(
    String relativeId,
  ) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/relatives/$relativeId/records',
      );
      if (response.statusCode == 200) {
        // Ánh xạ dữ liệu từ List<Map> sang List<MedicalRecordModel>
        return (response.data as List).map((map) {
          // Map lại các trường nếu BE trả về tên khác với Model của bạn
          return MedicalRecordModel.fromMap({
            ...map,
            'patientId': map['relativeId'], // Map relativeId -> patientId
            'important':
                map['important'], // Model của bạn dùng key 'important' trong fromMap
          });
        }).toList();
      }
      return [];
    } catch (e) {
      developer.log('Error fetching records: $e');
      return [];
    }
  }

  Future<RelativeHistoryModel?> getHealthHistoryByProfileId(
    String profileId,
  ) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/profiles/$profileId/health-history',
      );

      if (response.statusCode == 200 && response.data is Map) {
        return RelativeHistoryModel.fromMap(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } on DioException catch (error) {
      developer.log(
        'Get health history API error: ${error.response?.statusCode} - ${error.message}',
      );
    } catch (error) {
      developer.log('Unexpected error when fetching health history: $error');
    }
    return null;
  }

  Future<bool> saveMedicalRecord({
    required String relativeId,
    required String title,
    required String type,
    required List<String> tags,
    required String notes,
    required bool isImportant,
    required List<File> files,
  }) async {
    try {
      final formData = FormData();
      formData.fields
        ..add(MapEntry('title', title.trim()))
        ..add(MapEntry('type', type.trim()))
        ..add(MapEntry('important', isImportant.toString()));

      if (notes.trim().isNotEmpty) {
        formData.fields.add(MapEntry('notes', notes.trim()));
      }

      for (final tag in tags) {
        final cleanTag = tag.trim();
        if (cleanTag.isNotEmpty) {
          formData.fields.add(MapEntry('tags', cleanTag));
        }
      }

      for (final file in files) {
        if (!file.existsSync()) continue;
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: _extractFileName(file),
            ),
          ),
        );
      }

      final response = await _dioClient.dio.post(
        '/api/relatives/$relativeId/create-record',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return response.statusCode == 201;
    } on DioException catch (error) {
      // Log lỗi để thuận tiện debug nhưng vẫn trả về false cho ViewModel xử lý UI
      developer.log(
        'Record API error: ${error.response?.statusCode} - ${error.message}',
      );
      return false;
    } catch (error) {
      developer.log('Unexpected error when saving record: $error');
      return false;
    }
  }

  Future<AddRelativeResultModel?> addRelative(
    AddRelativeRequest request,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/relatives',
        data: request.toMap(),
      );

      if (response.statusCode == 201 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          if (map.containsKey('status')) {
            return AddRelativeResultModel.fromMap(map);
          }
          return AddRelativeResultModel.fallbackCreated(Relative.fromMap(map));
        }

        if (response.data is Map) {
          final map = Map<String, dynamic>.from(response.data as Map);
          if (map.containsKey('status')) {
            return AddRelativeResultModel.fromMap(map);
          }
          return AddRelativeResultModel.fallbackCreated(Relative.fromMap(map));
        }
      }
    } on DioException catch (error) {
      developer.log(
        'Add relative API error: ${error.response?.statusCode} - ${error.message}',
      );
    } catch (error) {
      developer.log('Unexpected error when adding relative: $error');
    }

    return null;
  }

  Future<List<HospitalResponse>> getHospitals() async {
    try {
      final response = await _dioClient.dio.get('/api/v1/hospitals');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (e) => HospitalResponse.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }
    } on DioException catch (error) {
      developer.log(
        'Get hospitals API error: ${error.response?.statusCode} - ${error.message}',
      );
    } catch (error) {
      developer.log('Unexpected error when fetching hospitals: $error');
    }
    return [];
  }

  Future<List<ProfileSearchResponse>> searchPatientProfiles(
    String query,
  ) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }
    try {
      final response = await _dioClient.dio.get(
        '/api/v1/doctor/records/profiles/search',
        queryParameters: {'query': cleanQuery},
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (e) => ProfileSearchResponse.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }
    } on DioException catch (error) {
      developer.log(
        'Search patient profiles error: ${error.response?.statusCode} - ${error.message}',
      );
    } catch (error) {
      developer.log('Unexpected error when searching profiles: $error');
    }
    return [];
  }

  Future<String?> uploadDiagnosticImage(File file) async {
    if (!file.existsSync()) {
      return null;
    }
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _extractFileName(file),
        ),
      });
      final response = await _dioClient.dio.post(
        '/api/v1/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final url = data['url'];
        return url is String ? url : null;
      }
    } on DioException catch (error) {
      developer.log(
        'Upload diagnostic image error: ${error.response?.statusCode} - ${error.message}',
      );
    } catch (error) {
      developer.log('Unexpected error when uploading diagnostic image: $error');
    }
    return null;
  }

  Future<bool> createFullMedicalRecord(Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/doctor/records',
        data: payload,
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (error) {
      developer.log(
        'Create medical record error: ${error.response?.statusCode} - ${error.message}',
      );
      return false;
    } catch (error) {
      developer.log('Unexpected error when creating medical record: $error');
      return false;
    }
  }

  String _extractFileName(File file) {
    final segments = file.path.split(RegExp(r'[\\/]'));
    return segments.isNotEmpty ? segments.last : 'upload';
  }
}
