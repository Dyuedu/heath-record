import 'package:flutter/material.dart';
import 'package:frontend/data/models/doctor/appointment_slot_model.dart';
import 'package:frontend/data/models/doctor/doctor_schedule_day_model.dart';
import 'package:frontend/data/repositories/appointment_repository.dart';

class ScheduleViewModel extends ChangeNotifier {
  final AppointmentRepository _appointmentRepository;

  List<DoctorScheduleDayModel> _schedule = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentDaysOffset = 0;
  String? _currentDoctorId;

  ScheduleViewModel(this._appointmentRepository);

  // Getters
  List<DoctorScheduleDayModel> get schedule => _schedule;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentDaysOffset => _currentDaysOffset;

  /// Tải lịch khám cho 7 ngày từ hôm nay + offset
  Future<void> fetchSchedule({
    int daysOffset = 0,
    String? doctorId,
    bool overrideDoctor = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentDaysOffset = daysOffset;
    if (overrideDoctor) {
      _currentDoctorId = doctorId;
    }
    final targetDoctorId = overrideDoctor ? doctorId : _currentDoctorId;
    notifyListeners();

    try {
      _schedule = await _appointmentRepository.getDoctorSchedule(
        daysOffset: daysOffset,
        doctorId: targetDoctorId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải lịch khám: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải lịch tuần trước
  Future<void> goToPreviousWeek() async {
    int newOffset = _currentDaysOffset - 7;
    if (newOffset < -7) {
      _errorMessage = 'Không thể xem lịch quá xa trong quá khứ';
      notifyListeners();
      return;
    }
    await fetchSchedule(daysOffset: newOffset);
  }

  /// Tải lịch tuần tiếp theo
  Future<void> goToNextWeek() async {
    await fetchSchedule(daysOffset: _currentDaysOffset + 7);
  }

  /// Tải lịch hôm nay
  Future<void> goToToday() async {
    await fetchSchedule(daysOffset: 0);
  }

  /// Bệnh nhân yêu cầu lịch khám
  Future<AppointmentSlotModel?> requestAppointment({
    required String doctorId,
    required String appointmentDate,
    required int slotNumber,
    required String patientName,
    required String patientPhone,
    String? notes,
  }) async {
    try {
      final result = await _appointmentRepository.createAppointmentRequest(
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        slotNumber: slotNumber,
        patientName: patientName,
        patientPhone: patientPhone,
        notes: notes,
      );

      if (result != null) {
        // Cập nhật schedule nếu thành công
        await fetchSchedule(daysOffset: _currentDaysOffset);
        return result;
      }
      _errorMessage = 'Yêu cầu lịch khám thất bại';
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      notifyListeners();
      return null;
    }
  }

  /// Bác sĩ chấp thuận lịch khám
  Future<bool> approveAppointment({
    required int appointmentId,
    String? notes,
  }) async {
    try {
      final result = await _appointmentRepository.approveOrRejectAppointment(
        appointmentId: appointmentId,
        approve: true,
        notes: notes,
      );

      if (result != null) {
        // Cập nhật schedule
        await fetchSchedule(daysOffset: _currentDaysOffset);
        return true;
      }
      _errorMessage = 'Duyệt lịch khám thất bại';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      notifyListeners();
      return false;
    }
  }

  /// Bác sĩ từ chối lịch khám
  Future<bool> rejectAppointment({
    required int appointmentId,
    String? notes,
  }) async {
    try {
      final result = await _appointmentRepository.approveOrRejectAppointment(
        appointmentId: appointmentId,
        approve: false,
        notes: notes,
      );

      if (result != null) {
        // Cập nhật schedule
        await fetchSchedule(daysOffset: _currentDaysOffset);
        return true;
      }
      _errorMessage = 'Từ chối lịch khám thất bại';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi: $e';
      notifyListeners();
      return false;
    }
  }

  /// Lấy số lượng lịch chờ duyệt toàn bộ tuần
  int getTotalPendingCount() {
    return _schedule.fold(0, (sum, day) => sum + day.pendingCount);
  }

  /// Lấy số lượng lịch đã đặt toàn bộ tuần
  int getTotalBookedCount() {
    return _schedule.fold(0, (sum, day) => sum + day.bookedCount);
  }
}
