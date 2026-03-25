import 'package:frontend/data/models/hospital/hospital_model.dart';

abstract class HospitalRepository {
  Future<List<HospitalModel>> getAllHospitals();
  Future<HospitalModel?> createHospital(String name);
  Future<HospitalModel?> updateHospital(int id, String name);
  Future<void> deleteHospital(int id);
}
