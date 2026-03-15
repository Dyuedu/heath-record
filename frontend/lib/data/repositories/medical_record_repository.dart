import 'package:frontend/data/models/record/medical_record_list_item_model.dart';

abstract class MedicalRecordRepository {
  Future<List<MedicalRecordListItemModel>> fetchMedicalRecordsByProfile(String profileId);
}