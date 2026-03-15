import 'package:flutter/material.dart';
import 'package:frontend/data/models/record/medical_record_list_item_model.dart';
import 'package:frontend/data/repositories/medical_record_repository.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';

class MedicalRecordViewModel extends ChangeNotifier {
  final MedicalRecordRepository repository;
  final SecureStorageRepository storage; // Injected to handle identity

  MedicalRecordViewModel({
    required this.repository,
    required this.storage,
  });

  List<MedicalRecordListItemModel> _records = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MedicalRecordListItemModel> get records => _records;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Now the UI just calls this. The ViewModel finds the ID.
  Future<void> initFetch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Get the profile ID internally from storage
      final profileId = "c66d66f8-5ab5-495b-92d2-18459edf99b2";

      if (profileId == null) {
        _errorMessage = "No profile found. Please log in again.";
      } else {
        // 2. Fetch data using the ID we just found
        _records = await repository.fetchMedicalRecordsByProfile(profileId);
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}