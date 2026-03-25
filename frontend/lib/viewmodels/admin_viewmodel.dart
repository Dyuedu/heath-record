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
  bool _userLoading = false;
  bool _recordLoading = false;
  String? _errorMessage;
  String? _successMessage;
  List<UserProfileModel> _users = const [];
  List<UserProfileModel> _pendingUsers = const [];
  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? _recordStats;
  Map<String, dynamic>? _userStats;
  String _selectedPeriod = 'month';
  String _userPeriod = 'month';
  String _recordPeriod = 'month';
  String _recordChartType = 'bar'; // 'bar' or 'line'
  String _userChartType = 'bar';

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get userLoading => _userLoading;
  bool get recordLoading => _recordLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<UserProfileModel> get users => List.unmodifiable(_users);
  List<UserProfileModel> get pendingUsers => List.unmodifiable(_pendingUsers);
  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  Map<String, dynamic>? get recordStats => _recordStats;
  Map<String, dynamic>? get userStats => _userStats;
  String get selectedPeriod => _selectedPeriod;
  String get userPeriod => _userPeriod;
  String get recordPeriod => _recordPeriod;
  String get recordChartType => _recordChartType;
  String get userChartType => _userChartType;

  Future<void> loadDashboardStats() async {
    _errorMessage = null;
    try {
      _dashboardStats = await _repository.getDashboardStats();
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Không thể tải thống kê dashboard.';
    }
  }

  Future<void> loadRecordStats({String? period}) async {
    if (period != null) _selectedPeriod = period;
    _errorMessage = null;
    _setLoading(true);
    try {
      _recordStats = await _repository.getRecordStats(_selectedPeriod);
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Không thể tải dữ liệu thống kê.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserStats({String? period}) async {
    if (period != null) _userPeriod = period;
    _errorMessage = null;
    _setUserLoading(true);
    try {
      _userStats = await _repository.getStats(_userPeriod, 'user');
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Không thể tải dữ liệu thống kê người dùng.';
    } finally {
      _setUserLoading(false);
    }
  }

  Future<void> loadRecordStatsSeparate({String? period}) async {
    if (period != null) _recordPeriod = period;
    _errorMessage = null;
    _setRecordLoading(true);
    try {
      _recordStats = await _repository.getStats(_recordPeriod, 'record');
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Không thể tải dữ liệu thống kê bệnh án.';
    } finally {
      _setRecordLoading(false);
    }
  }

  void setRecordChartType(String type) {
    _recordChartType = type;
    notifyListeners();
  }

  void setUserChartType(String type) {
    _userChartType = type;
    notifyListeners();
  }

  Future<void> searchUsers({String? search, String? role, String? status}) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      _users = await _repository.searchUsers(search: search, role: role, status: status);
      _successMessage = null;
    } catch (_) {
      _errorMessage = 'Không thể tải danh sách người dùng.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPendingUsers({String? search, String? role}) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      _pendingUsers = await _repository.getPendingApprovals(search: search, role: role);
      _successMessage = null;
    } catch (_) {
      _errorMessage = 'Không thể tải danh sách chờ duyệt.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserStatus(String id, String status) async {
    _errorMessage = null;
    _successMessage = null;
    _setSaving(true);
    try {
      final updated = await _repository.updateUserStatus(id, status);
      if (updated == null) {
        _errorMessage = 'Không thể cập nhật trạng thái.';
        return false;
      }
      // Update local lists
      _users = _users.map((u) => u.id == id ? updated : u).toList();
      _successMessage = 'Cập nhật trạng thái thành công.';
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Lỗi cập nhật trạng thái.';
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> approveUser(String id) async {
    _errorMessage = null;
    _successMessage = null;
    _setSaving(true);
    try {
      final approved = await _repository.approveUser(id);
      if (approved == null) {
        _errorMessage = 'Không thể duyệt người dùng.';
        return false;
      }
      _pendingUsers = _pendingUsers.where((u) => u.id != id).toList();
      _successMessage = 'Đã duyệt tài khoản.';
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Lỗi duyệt tài khoản.';
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> rejectUser(String id) async {
    _errorMessage = null;
    _successMessage = null;
    _setSaving(true);
    try {
      final rejected = await _repository.rejectUser(id);
      if (rejected == null) {
        _errorMessage = 'Không thể từ chối người dùng.';
        return false;
      }
      _pendingUsers = _pendingUsers.where((u) => u.id != id).toList();
      _successMessage = 'Đã từ chối tài khoản.';
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Lỗi từ chối tài khoản.';
      return false;
    } finally {
      _setSaving(false);
    }
  }

  // Legacy loadAllUsers mapping to searchUsers for backward compatibility if needed, 
  // but we usually call searchUsers directly now.
  Future<void> loadAllUsers() async {
    await searchUsers();
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

  void _setUserLoading(bool value) {
    _userLoading = value;
    notifyListeners();
  }

  void _setRecordLoading(bool value) {
    _recordLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }
}
