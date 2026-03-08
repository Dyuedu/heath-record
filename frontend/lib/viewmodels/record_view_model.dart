import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/repositories/record_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class RecordViewModel extends ChangeNotifier {
  final RecordRepository _repository = RecordRepository();
  final ImagePicker _picker = ImagePicker();

  // State
  List<File> selectedFiles = [];
  List<String> selectedTags = [];
  bool isImportant = false;
  bool isLoading = false;

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
    isLoading = true;
    notifyListeners();

    bool success = await _repository.saveMedicalRecord(
      title: title,
      tags: selectedTags,
      notes: notes,
      isImportant: isImportant,
      files: selectedFiles,
    );

    isLoading = false;
    notifyListeners();
    return success;
  }
}
