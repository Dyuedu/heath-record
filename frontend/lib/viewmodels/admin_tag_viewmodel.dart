import 'package:flutter/material.dart';
import 'package:frontend/data/models/tag/tag_model.dart';
import 'package:frontend/data/repositories/tag_repository.dart';

class AdminTagViewModel extends ChangeNotifier {
  final TagRepository _repository;

  AdminTagViewModel({required TagRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  List<TagModel> _tags = [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<TagModel> get tags => List.unmodifiable(_tags);

  Future<void> loadTags() async {
    _errorMessage = null;
    _setLoading(true);
    try {
      _tags = await _repository.getAllTags();
      _successMessage = null;
    } catch (_) {
      _errorMessage = 'Không thể tải danh sách tag.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTag(String name, String description) async {
    _errorMessage = null;
    _successMessage = null;
    _setSaving(true);
    try {
      final created = await _repository.createTag(name, description);
      if (created == null) {
        _errorMessage = 'Thêm tag thất bại.';
        return false;
      }
      _tags = [..._tags, created];
      _successMessage = 'Thêm tag thành công.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> updateTag(int id, String name, String description) async {
    _errorMessage = null;
    _successMessage = null;
    _setSaving(true);
    try {
      final updated = await _repository.updateTag(id, name, description);
      if (updated == null) {
        _errorMessage = 'Cập nhật tag thất bại.';
        return false;
      }
      _tags = _tags.map((t) => t.id == id ? updated : t).toList();
      _successMessage = 'Cập nhật tag thành công.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> deleteTag(int id) async {
    _errorMessage = null;
    _successMessage = null;
    _setSaving(true);
    try {
      await _repository.deleteTag(id);
      _tags = _tags.where((t) => t.id != id).toList();
      _successMessage = 'Xóa tag thành công.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }
}
