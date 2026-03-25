import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/doctor/appointment_slot_model.dart';
import 'package:frontend/data/models/doctor/doctor_schedule_day_model.dart';
import 'package:frontend/data/repositories/appointment_repository.dart';

class AppointmentRepositoryImp implements AppointmentRepository {
  final DioClient _dioClient;

  AppointmentRepositoryImp(this._dioClient);

  @override
  Future<List<DoctorScheduleDayModel>> getDoctorSchedule({
    required int daysOffset,
    String? doctorId,
  }) async {
    try {
      final path = doctorId == null
          ? '/api/v1/appointments/doctor/schedule'
          : '/api/v1/appointments/doctor/$doctorId/schedule';
      final response = await _dioClient.dio.get(
        path,
        queryParameters: {'days_offset': daysOffset},
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (e) => DoctorScheduleDayModel.fromMap(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }
      return const [];
    } catch (e) {
      print('Error fetching doctor schedule: $e');
      return const [];
    }
  }

  @override
  Future<AppointmentSlotModel?> createAppointmentRequest({
    required String doctorId,
    required String appointmentDate,
    required int slotNumber,
    required String patientName,
    required String patientPhone,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/appointments/request/$doctorId',
        data: {
          'appointmentDate': appointmentDate,
          'slotNumber': slotNumber,
          'patientName': patientName,
          'patientPhone': patientPhone,
          'notes': notes ?? '',
        },
      );

      if (response.statusCode == 201 && response.data != null) {
        return AppointmentSlotModel.fromMap(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return null;
    } catch (e) {
      print('Error creating appointment request: $e');
      return null;
    }
  }

  @override
  Future<AppointmentSlotModel?> approveOrRejectAppointment({
    required int appointmentId,
    required bool approve,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/appointments/$appointmentId/approval',
        data: {
          'appointmentId': appointmentId,
          'approve': approve,
          'notes': notes ?? '',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseMap = Map<String, dynamic>.from(response.data as Map);
        final slotDetails = responseMap['slotDetails'];
        if (slotDetails != null) {
          return AppointmentSlotModel.fromMap(
            Map<String, dynamic>.from(slotDetails as Map),
          );
        }
      }
      return null;
    } catch (e) {
      print('Error approving/rejecting appointment: $e');
      return null;
    }
  }
}
