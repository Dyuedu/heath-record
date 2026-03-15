import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/record/medical_record_list_item_model.dart';
import 'package:frontend/data/repositories/medical_record_repository.dart';

class MedicalRecordRepositoryImp implements MedicalRecordRepository {
  final DioClient _dioClient;

  MedicalRecordRepositoryImp(this._dioClient);

  @override
  Future<List<MedicalRecordListItemModel>> fetchMedicalRecordsByProfile(String profileId) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/medical-records/profile/$profileId',
      );

      if (response.statusCode == 200 && response.data != null) {
        // Casting response.data as List and mapping to your Model
        return (response.data as List)
            .map((item) => MedicalRecordListItemModel.fromMap(
          Map<String, dynamic>.from(item),
        ))
            .toList();
      }
      return [];
    } catch (e) {
      // It's often better to rethrow or use a Result wrapper,
      // but following your current pattern:
      print("Fetch Medical Records Error: $e");
      return [];
    }
  }
}