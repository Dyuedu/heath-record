import 'dart:convert' as convert;

class AppointmentSlotModel {
  final int id;
  final int slotNumber;
  final String slotStartTime; // "08:00" format
  final String slotEndTime; // "09:30" format
  final String status; // AVAILABLE, PENDING, BOOKED, REJECTED, CANCELLED
  final String? patientName;
  final String? patientPhone;
  final String? notes;

  AppointmentSlotModel({
    required this.id,
    required this.slotNumber,
    required this.slotStartTime,
    required this.slotEndTime,
    required this.status,
    this.patientName,
    this.patientPhone,
    this.notes,
  });

  bool get isAvailable => status == 'AVAILABLE';
  bool get isPending => status == 'PENDING';
  bool get isBooked => status == 'BOOKED';
  bool get isRejected => status == 'REJECTED';

  factory AppointmentSlotModel.fromMap(Map<String, dynamic> map) {
    return AppointmentSlotModel(
      id: (map['appointmentId'] as num?)?.toInt() ?? 0,
      slotNumber: (map['slotNumber'] as num?)?.toInt() ?? 0,
      slotStartTime: (map['slotStartTime'] ?? '').toString(),
      slotEndTime: (map['slotEndTime'] ?? '').toString(),
      status: (map['status'] ?? 'AVAILABLE').toString(),
      patientName: map['patientName']?.toString(),
      patientPhone: map['patientPhone']?.toString(),
      notes: map['notes']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': id,
      'slotNumber': slotNumber,
      'slotStartTime': slotStartTime,
      'slotEndTime': slotEndTime,
      'status': status,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'notes': notes,
    };
  }

  String toJson() => convert.jsonEncode(toMap());

  factory AppointmentSlotModel.fromJson(String source) =>
      AppointmentSlotModel.fromMap(
        convert.jsonDecode(source) as Map<String, dynamic>,
      );

  AppointmentSlotModel copyWith({
    int? id,
    int? slotNumber,
    String? slotStartTime,
    String? slotEndTime,
    String? status,
    String? patientName,
    String? patientPhone,
    String? notes,
  }) {
    return AppointmentSlotModel(
      id: id ?? this.id,
      slotNumber: slotNumber ?? this.slotNumber,
      slotStartTime: slotStartTime ?? this.slotStartTime,
      slotEndTime: slotEndTime ?? this.slotEndTime,
      status: status ?? this.status,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      notes: notes ?? this.notes,
    );
  }
}
