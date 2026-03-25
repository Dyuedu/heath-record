import 'package:dio/dio.dart';
import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/tag/tag_model.dart';
import 'package:frontend/data/repositories/tag_repository.dart';

class TagRepositoryImp implements TagRepository {
  final DioClient _dioClient;

  TagRepositoryImp(this._dioClient);

  @override
  Future<List<TagModel>> getAllTags() async {
    try {
      final response = await _dioClient.dio.get('/api/admin/tags');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => TagModel.fromJson(item))
            .toList();
      }
    } on DioException catch (error) {
      print('Get tags failed: ${error.message}');
    } catch (error) {
      print('Unexpected error fetching tags: $error');
    }
    return [];
  }

  @override
  Future<TagModel?> createTag(String name, String description) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/admin/tags',
        data: {'name': name, 'description': description},
      );
      if (response.statusCode == 201 && response.data != null) {
        return TagModel.fromJson(response.data);
      }
    } on DioException catch (error) {
      print('Create tag failed: ${error.message}');
      throw Exception(error.response?.data?['message'] ?? 'Thêm tag thất bại');
    } catch (error) {
      print('Unexpected error adding tag: $error');
      throw Exception('Thêm tag thất bại');
    }
    return null;
  }

  @override
  Future<TagModel?> updateTag(int id, String name, String description) async {
    try {
      final response = await _dioClient.dio.put(
        '/api/admin/tags/$id',
        data: {'name': name, 'description': description},
      );
      if (response.statusCode == 200 && response.data != null) {
        return TagModel.fromJson(response.data);
      }
    } on DioException catch (error) {
      print('Update tag failed: ${error.message}');
      throw Exception(error.response?.data?['message'] ?? 'Cập nhật tag thất bại');
    } catch (error) {
      print('Unexpected error updating tag: $error');
      throw Exception('Cập nhật tag thất bại');
    }
    return null;
  }

  @override
  Future<void> deleteTag(int id) async {
    try {
      final response = await _dioClient.dio.delete('/api/admin/tags/$id');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Xóa tag thất bại');
      }
    } on DioException catch (error) {
       print('Delete tag failed: ${error.message}');
       throw Exception(error.response?.data?['message'] ?? 'Xóa tag thất bại');
    } catch (error) {
       print('Unexpected error deleting tag: $error');
       throw Exception('Xóa tag thất bại');
    }
  }
}
