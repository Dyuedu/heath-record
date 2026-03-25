import 'package:frontend/data/models/appointment/appointment_detail_model.dart';
import 'package:frontend/data/models/doctor/appointment_slot_model.dart';
import 'package:frontend/data/models/doctor/doctor_schedule_day_model.dart';

abstract class AppointmentRepository {
  /// Lấy lịch của bác sĩ (7 ngày)
  /// [daysOffset] - Số ngày offset từ hôm nay (0 = hôm nay, 1 = ngày mai)
  Future<List<DoctorScheduleDayModel>> getDoctorSchedule({
    required int daysOffset,
    String? doctorId,
  });

  /// Bệnh nhân yêu cầu lịch khám
  /// [doctorId] - ID của bác sĩ
  /// [appointmentDate] - Ngày khám (format: yyyy-MM-dd)
  /// [slotNumber] - Số slot (1-8)
  /// [patientName] - Tên bệnh nhân
  /// [patientPhone] - SĐT bệnh nhân
  /// [notes] - Ghi chú
  Future<AppointmentSlotModel?> createAppointmentRequest({
    required String doctorId,
    required String appointmentDate,
    required int slotNumber,
    required String patientName,
    required String patientPhone,
    String? notes,
  });

  /// Bác sĩ chấp thuận hoặc từ chối lịch khám
  /// [appointmentId] - ID của lịch khám
  /// [approve] - true = chấp thuận, false = từ chối
  /// [notes] - Ghi chú
  Future<AppointmentSlotModel?> approveOrRejectAppointment({
    required int appointmentId,
    required bool approve,
    String? notes,
  });

  /// Lấy số lượng lịch đang chờ duyệt của bác sĩ hiện tại
  Future<int> getPendingAppointmentCount();

  /// Lấy danh sách lịch khám của người dùng hiện tại
  Future<List<AppointmentDetailModel>> getMyAppointments({String? status});

  /// Lấy chi tiết một lịch khám cụ thể
  Future<AppointmentDetailModel?> getAppointmentDetail(int appointmentId);
}
