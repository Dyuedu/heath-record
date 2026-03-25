import 'package:flutter/material.dart';
import 'package:frontend/data/models/appointment/appointment_detail_model.dart';
import 'package:frontend/data/repositories/appointment_repository.dart';

class AppointmentListViewModel extends ChangeNotifier {
  final AppointmentRepository _appointmentRepository;

  AppointmentListViewModel(this._appointmentRepository);

  List<AppointmentDetailModel> _appointments = [];
  bool _isLoading = false;
  String _currentFilter = 'ALL';
  String? _errorMessage;

  List<AppointmentDetailModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String get currentFilter => _currentFilter;
  String? get errorMessage => _errorMessage;

  Future<void> loadAppointments({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentFilter = status ?? 'ALL';
      final normalizedStatus = _currentFilter == 'ALL' ? null : _currentFilter;
      _appointments = await _appointmentRepository.getMyAppointments(
        status: normalizedStatus,
      );
    } catch (error) {
      _errorMessage = 'Không thể tải danh sách lịch khám: $error';
      _appointments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppointmentDetailModel?> fetchAppointmentDetail(
    int appointmentId,
  ) async {
    return _appointmentRepository.getAppointmentDetail(appointmentId);
  }
}
