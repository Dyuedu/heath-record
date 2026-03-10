import 'package:frontend/data/models/patient/patient_detail_model.dart';
import 'package:frontend/data/models/patient/patient_model.dart';

abstract class DoctorRepository {
  Future<List<PatientModel>> searchPatientByPhone(String phone);

  Future<PatientDetailModel?> fetchPatientDetail(String patientId);
}