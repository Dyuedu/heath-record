import 'dart:io';
import 'package:dio/dio.dart';

class RecordRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://your-api-url.com'));

  Future<bool> saveMedicalRecord({
    required String title,
    required List<String> tags,
    required String notes,
    required bool isImportant,
    required List<File> files,
  }) async {
    try {
      // Chuẩn bị FormData để gửi đa phần (Multipart)
      FormData formData = FormData.fromMap({
        "title": title,
        "tags": tags.join(","), // Spring Boot có thể nhận chuỗi cách nhau bởi dấu phẩy
        "notes": notes,
        "isImportant": isImportant,
        // Chuyển đổi List<File> thành List<MultipartFile>
        "files": await Future.wait(files.map((file) async {
          return await MultipartFile.fromFile(file.path, filename: file.path.split('/').last);
        }).toList()),
      });

      Response response = await _dio.post("/api/medical-records", data: formData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error saving record: $e");
      return false;
    }
  }
}