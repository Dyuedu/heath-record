import 'package:flutter/material.dart';
import 'package:frontend/data/models/admin/admin_user_payload.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/admin_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _repository;

  AdminViewModel({required AdminRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  List<UserProfileModel> _users = const [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<UserProfileModel> get users => List.unmodifiable(_users);

  Future<void> loadAllUsers() async {
    _errorMessage = null;
    _setLoading(true);
    try {
      _users = await _repository.getAllUsers();
      _successMessage = null;
    } catch (_) {
      _errorMessage = 'Không thể tải danh sách người dùng.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createUser(AdminUserPayload payload) async {
    _errorMessage = null;
    _successMessage = null;
    _setSaving(true);
    try {
      final created = await _repository.createUser(payload);
      if (created == null) {
        _errorMessage = 'Không thể tạo người dùng mới.';
        return false;
      }
      _users = [..._users, created];
      _successMessage = 'Tạo người dùng thành công.';
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Không thể tạo người dùng mới.';
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> updateUser({
    required String id,
    required AdminUserPayload payload,
  }) async {
    _errorMessage = null;
    _successMessage = null;
    _setSaving(true);
    try {
      final updated = await _repository.updateUser(id: id, payload: payload);
      if (updated == null) {
        _errorMessage = 'Không thể cập nhật người dùng.';
        return false;
      }
      _users = _users.map((user) => user.id == id ? updated : user).toList();
      _successMessage = 'Cập nhật người dùng thành công.';
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Không thể cập nhật người dùng.';
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
