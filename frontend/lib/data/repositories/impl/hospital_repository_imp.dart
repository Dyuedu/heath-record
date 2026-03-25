import 'package:dio/dio.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/hospital/hospital_model.dart';
import 'package:frontend/data/repositories/hospital_repository.dart';

class HospitalRepositoryImp implements HospitalRepository {
  final DioClient _dioClient;

  HospitalRepositoryImp(this._dioClient);

  @override
  Future<List<HospitalModel>> getAllHospitals() async {
    try {
      final response = await _dioClient.dio.get('/api/admin/hospitals');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => HospitalModel.fromJson(item))
            .toList();
      }
    } on DioException catch (error) {
      print('Get hospitals failed: ${error.message}');
    } catch (error) {
      print('Unexpected error fetching hospitals: $error');
    }
    return [];
  }

  @override
  Future<HospitalModel?> createHospital(String name) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/admin/hospitals',
        data: {'name': name},
      );
      if (response.statusCode == 201 && response.data != null) {
        return HospitalModel.fromJson(response.data);
      }
    } on DioException catch (error) {
      print('Create hospital failed: ${error.message}');
      throw Exception(error.response?.data?['message'] ?? 'Thêm bệnh viện thất bại');
    } catch (error) {
      print('Unexpected error adding hospital: $error');
      throw Exception('Thêm bệnh viện thất bại');
    }
    return null;
  }

  @override
  Future<HospitalModel?> updateHospital(int id, String name) async {
    try {
      final response = await _dioClient.dio.put(
        '/api/admin/hospitals/$id',
        data: {'name': name},
      );
      if (response.statusCode == 200 && response.data != null) {
        return HospitalModel.fromJson(response.data);
      }
    } on DioException catch (error) {
      print('Update hospital failed: ${error.message}');
      throw Exception(error.response?.data?['message'] ?? 'Cập nhật bệnh viện thất bại');
    } catch (error) {
      print('Unexpected error updating hospital: $error');
      throw Exception('Cập nhật bệnh viện thất bại');
    }
    return null;
  }

  @override
  Future<void> deleteHospital(int id) async {
    try {
      final response = await _dioClient.dio.delete('/api/admin/hospitals/$id');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Xóa bệnh viện thất bại');
      }
    } on DioException catch (error) {
       print('Delete hospital failed: ${error.message}');
       throw Exception(error.response?.data?['message'] ?? 'Xóa bệnh viện thất bại');
    } catch (error) {
       print('Unexpected error deleting hospital: $error');
       throw Exception('Xóa bệnh viện thất bại');
    }
  }
}
