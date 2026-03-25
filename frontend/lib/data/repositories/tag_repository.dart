import 'package:frontend/data/models/tag/tag_model.dart';

abstract class TagRepository {
  Future<List<TagModel>> getAllTags();
  Future<TagModel?> createTag(String name, String description);
  Future<TagModel?> updateTag(int id, String name, String description);
  Future<void> deleteTag(int id);
}
