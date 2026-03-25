import 'package:flutter/material.dart';
import 'package:frontend/data/models/hospital/hospital_model.dart';
import 'package:frontend/data/repositories/hospital_repository.dart';

class AdminHospitalViewModel extends ChangeNotifier {
  final HospitalRepository _repository;

  AdminHospitalViewModel({required HospitalRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  List<HospitalModel> _hospitals = [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<HospitalModel> get hospitals => List.unmodifiable(_hospitals);

  Future<void> loadHospitals() async {
    _errorMessage = null;
    _setLoading(true);
    try {
      _hospitals = await _repository.getAllHospitals();
      _successMessage = null;
    } catch (_) {
      _errorMessage = 'Không thể tải danh sách bệnh viện.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createHospital(String name) async {
    _errorMessage = null;
    _successMessage = null;
    _setSaving(true);
    try {
      final created = await _repository.createHospital(name);
      if (created == null) {
        _errorMessage = 'Thêm bệnh viện thất bại.';
        return false;
      }
      _hospitals = [..._hospitals, created];
      _successMessage = 'Thêm bệnh viện thành công.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> updateHospital(int id, String name) async {
    _errorMessage = null;
    _successMessage = null;
    _setSaving(true);
    try {
      final updated = await _repository.updateHospital(id, name);
      if (updated == null) {
        _errorMessage = 'Cập nhật bệnh viện thất bại.';
        return false;
      }
      _hospitals = _hospitals.map((h) => h.id == id ? updated : h).toList();
      _successMessage = 'Cập nhật bệnh viện thành công.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  Future<bool> deleteHospital(int id) async {
    _errorMessage = null;
    _successMessage = null;
    _setSaving(true);
    try {
      await _repository.deleteHospital(id);
      _hospitals = _hospitals.where((h) => h.id != id).toList();
      _successMessage = 'Xóa bệnh viện thành công.';
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
