import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/patient/patient_model.dart';
import 'package:frontend/data/repositories/doctor_repository.dart';

class DoctorRepositoryImp implements DoctorRepository {
  final DioClient _dioClient;
  DoctorRepositoryImp(this._dioClient);

  @override
  Future<List<PatientModel>> searchPatientByPhone(String phone) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/doctor/search-patients',
        queryParameters: {'phone': phone},
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => PatientModel.fromMap(e))
            .toList();
      }
      return [];
    } catch (e) {
      print("Search Error: $e");
      return [];
    }
  }
}