import 'package:flutter/material.dart';
import 'package:frontend/data/models/patient/patient_detail_model.dart';
import 'package:frontend/data/models/patient/patient_model.dart';
import 'package:frontend/data/models/record/medical_record_model.dart';
import 'package:frontend/data/repositories/doctor_repository.dart';

class PatientDetailViewModel extends ChangeNotifier {
  final DoctorRepository _repository;

  PatientDetailModel? _detail;
  bool isLoading = false;
  String? errorMessage;
  String? selectedRelativeId;

  PatientDetailViewModel({required DoctorRepository repository})
      : _repository = repository;

  // Getters sạch sẽ hơn
  PatientModel? get patient => _detail?.patient;
  List<PatientRelativeRecordModel> get relatives => _detail?.relatives ?? [];

  // Tìm relative đang được chọn dựa trên ID
  PatientRelativeRecordModel? get selectedRelative {
    if (relatives.isEmpty) return null;
    // Tìm trong danh sách đã sắp xếp
    return relatives.firstWhere(
      (rel) => rel.id == selectedRelativeId,
      orElse: () => relatives.first,
    );
  }

  // Lấy danh sách records của relative đang chọn
  List<MedicalRecordModel> get records =>
      selectedRelative?.records ?? const <MedicalRecordModel>[];

  Future<void> loadPatientDetail(String patientId,
      {String? relativeToSelect}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final detail = await _repository.fetchPatientDetail(patientId);
      
      if (detail == null) {
        errorMessage = 'Không thể tải thông tin bệnh nhân lúc này.';
      } else {
        // --- LOGIC QUAN TRỌNG: Sắp xếp "Me" lên đầu ---
        if (detail.relatives.isNotEmpty) {
          detail.relatives.sort((a, b) {
            // Giả sử field 'relationship' lưu giá trị 'Me' (hoặc bạn có thể check theo logic riêng)
            bool isAMe = a.relationship?.toLowerCase() == 'me';
            bool isBMe = b.relationship?.toLowerCase() == 'me';
            if (isAMe) return -1;
            if (isBMe) return 1;
            return 0;
          });
        }
        
        _detail = detail;
        
        final hasPreferred = relativeToSelect != null &&
            detail.relatives.any((rel) => rel.id == relativeToSelect);
        if (hasPreferred) {
          selectedRelativeId = relativeToSelect;
        } else {
          selectedRelativeId =
              detail.relatives.isNotEmpty ? detail.relatives.first.id : null;
        }
      }
    } catch (e) {
      errorMessage = 'Đã xảy ra lỗi: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectRelative(String relativeId) {
    if (selectedRelativeId == relativeId) return;
    selectedRelativeId = relativeId;
    notifyListeners();
  }
}