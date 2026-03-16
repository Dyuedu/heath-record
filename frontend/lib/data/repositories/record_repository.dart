import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/record/medical_record_model.dart';
import 'package:frontend/data/models/record/relative.dart';
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
      print("Error fetching records: $e");
      return [];
    }
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
      print(
        'Record API error: ${error.response?.statusCode} - ${error.message}',
      );
      return false;
    } catch (error) {
      print('Unexpected error when saving record: $error');
      return false;
    }
  }

  Future<String?> uploadDiagnosticImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: _extractFileName(file)),
      });

      final response = await _dioClient.dio.post(
        '/api/v1/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data')
      );

      if (response.statusCode == 200) {
        return response.data["url"];
      }
      return null;
    } catch (e) {
      print('Upload image error: $e');
      return null;
    }
  }

  Future<bool> createFullMedicalRecord(Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/doctor/records',
        data: payload,
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Create full record error: $e');
      return false;
    }
  }

  Future<List<HospitalResponse>> getHospitals() async {
    try {
      final response = await _dioClient.dio.get('/api/v1/hospitals');
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => HospitalResponse.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Get hospitals error: $e');
      return [];
    }
  }

  Future<List<ProfileSearchResponse>> searchPatientProfiles(String query) async {
    try {
      final response = await _dioClient.dio.get('/api/v1/doctor/records/profiles/search', queryParameters: {'query': query});
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => ProfileSearchResponse.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Search patients error: $e');
      return [];
    }
  }

  String _extractFileName(File file) {
    final segments = file.path.split(RegExp(r'[\\/]'));
    return segments.isNotEmpty ? segments.last : 'upload';
  }
}
