import 'package:frontend/data/models/patient/patient_model.dart';
import 'package:frontend/data/models/record/medical_record_model.dart';

class PatientDetailModel {
  final PatientModel patient;
  final List<PatientRelativeRecordModel> relatives;

  PatientDetailModel({
    required this.patient,
    required this.relatives,
  });

  factory PatientDetailModel.fromMap(Map<String, dynamic> map) {
    return PatientDetailModel(
      patient: PatientModel.fromMap(
        Map<String, dynamic>.from(map['patient'] ?? const {}),
      ),
      relatives: (map['relatives'] as List? ?? [])
          .map((relative) => PatientRelativeRecordModel.fromMap(
                Map<String, dynamic>.from(relative ?? const {}),
              ))
          .toList(),
    );
  }
}

class PatientRelativeRecordModel {
  final String id;
  final String? profileId;
  final String name;
  final String? relationship;
  final List<MedicalRecordModel> records;

  PatientRelativeRecordModel({
    required this.id,
    required this.profileId,
    required this.name,
    required this.relationship,
    required this.records,
  });

  factory PatientRelativeRecordModel.fromMap(Map<String, dynamic> map) {
    final relativeId = map['id']?.toString() ?? '';
    final rawRecords = (map['records'] as List? ?? [])
        .map((record) => Map<String, dynamic>.from(record ?? const {}))
        .toList();

    return PatientRelativeRecordModel(
      id: relativeId,
      profileId: map['profileId']?.toString(),
      name: map['name'] ?? '',
      relationship: map['relationship']?.toString(),
      records: rawRecords
          .map((recordMap) {
            recordMap['patientId'] ??= relativeId;
            recordMap['type'] ??= 'Diagnosis';
            return MedicalRecordModel.fromMap(recordMap);
          })
          .toList(),
    );
  }
}
