import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/models/record/medical_record_model.dart';
import 'package:frontend/data/models/record/relative.dart';
import 'package:frontend/data/repositories/record_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class RecordViewModel extends ChangeNotifier {
  final RecordRepository _repository;
  final ImagePicker _picker = ImagePicker();

  RecordViewModel({required RecordRepository repository})
    : _repository = repository;

  // State
  List<File> selectedFiles = [];
  List<String> selectedTags = [];
  List<Relative> relatives = [];
  List<MedicalRecordModel> records = [];
  bool isImportant = false;
  bool isLoading = false;
  String? selectedRelativeId;
  String? errorMessage;

  Future<void> initData() async {
    _setLoading(true);
    relatives = await _repository.getMyRelatives();
    if (relatives.isNotEmpty) {
      await fetchRecords(relatives.first.id.toString());
    }
    _setLoading(false);
  }

  Future<void> fetchRecords(String relativeId) async {
    selectedRelativeId = relativeId;
    _setLoading(true);

    // Gọi repo và nhận về List<MedicalRecordModel>
    records = await _repository.getRecordsByRelative(relativeId);

    _setLoading(false);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void toggleImportance(bool value) {
    isImportant = value;
    notifyListeners();
  }

  void addTag(String tag) {
    if (!selectedTags.contains(tag)) {
      selectedTags.add(tag);
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    selectedTags.remove(tag);
    notifyListeners();
  }

  // Xử lý chọn ảnh từ Camera
  Future<void> pickFromCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      selectedFiles.add(File(photo.path));
      notifyListeners();
    }
  }

  // Xử lý chọn File (nhiều file cùng lúc)
  Future<void> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        // Đảm bảo không để khoảng trắng trong list extensions
        allowedExtensions: ['jpg', 'pdf', 'doc', 'png', 'docx'],
      );

      if (result != null && result.paths.isNotEmpty) {
        selectedFiles.addAll(
          result.paths
              .where((path) => path != null) // Kiểm tra path không null
              .map((path) => File(path!))
              .toList(),
        );
        notifyListeners();
      }
    } on PlatformException catch (e) {
      debugPrint("Lỗi hệ thống: ${e.message}");
    } catch (e) {
      debugPrint("Lỗi không xác định: $e");
    }
  }

  void removeFile(int index) {
    selectedFiles.removeAt(index);
    notifyListeners();
  }

  Future<bool> saveRecord(String title, String notes) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      errorMessage = "Title is required";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.saveMedicalRecord(
        relativeId: "65c3bfdb-e729-451e-8934-3399499a40a3",
        title: trimmedTitle,
        tags: List<String>.from(selectedTags),
        notes: notes,
        isImportant: isImportant,
        files: List<File>.from(selectedFiles),
      );

      if (success) {
        _resetFormState();
      } else {
        errorMessage = "Không thể lưu hồ sơ. Vui lòng thử lại.";
      }

      return success;
    } catch (e) {
      errorMessage = "Đã xảy ra lỗi không mong muốn.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _resetFormState() {
    selectedFiles.clear();
    selectedTags.clear();
    isImportant = false;
  }
}
