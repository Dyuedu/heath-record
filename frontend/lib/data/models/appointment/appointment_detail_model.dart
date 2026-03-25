import 'dart:convert' as convert;

class BasicUserInfoModel {
  final String id;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? avatarUrl;

  const BasicUserInfoModel({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.avatarUrl,
  });

  factory BasicUserInfoModel.fromMap(Map<String, dynamic> map) {
    return BasicUserInfoModel(
      id: (map['id'] ?? '').toString(),
      fullName: (map['fullName'] ?? map['full_name'] ?? '').toString(),
      phoneNumber:
          map['phoneNumber']?.toString() ?? map['phone_number']?.toString(),
      email: map['email']?.toString(),
      avatarUrl: map['avatarUrl']?.toString() ?? map['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }
}

class AppointmentDetailModel {
  final int appointmentId;
  final DateTime appointmentDate;
  final int slotNumber;
  final String slotStartTime;
  final String slotEndTime;
  final String status;
  final BasicUserInfoModel? doctor;
  final BasicUserInfoModel? patient;
  final String? patientName;
  final String? patientPhone;
  final String? notes;
  final String? decisionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? respondedAt;

  AppointmentDetailModel({
    required this.appointmentId,
    required this.appointmentDate,
    required this.slotNumber,
    required this.slotStartTime,
    required this.slotEndTime,
    required this.status,
    this.doctor,
    this.patient,
    this.patientName,
    this.patientPhone,
    this.notes,
    this.decisionReason,
    this.createdAt,
    this.updatedAt,
    this.respondedAt,
  });

  factory AppointmentDetailModel.fromMap(Map<String, dynamic> map) {
    BasicUserInfoModel? _parseUser(dynamic raw) {
      if (raw is Map<String, dynamic>) {
        return BasicUserInfoModel.fromMap(raw);
      }
      return null;
    }

    DateTime? _parseDateTime(dynamic value) {
      if (value == null) return null;
      final str = value.toString();
      if (str.isEmpty) return null;
      return DateTime.tryParse(str);
    }

    return AppointmentDetailModel(
      appointmentId: (map['appointmentId'] as num?)?.toInt() ?? 0,
      appointmentDate: DateTime.parse(map['appointmentDate'].toString()),
      slotNumber: (map['slotNumber'] as num?)?.toInt() ?? 0,
      slotStartTime: map['slotStartTime']?.toString() ?? '',
      slotEndTime: map['slotEndTime']?.toString() ?? '',
      status: (map['status'] ?? '').toString(),
      doctor: _parseUser(map['doctor']),
      patient: _parseUser(map['patient']),
      patientName: map['patientName']?.toString(),
      patientPhone: map['patientPhone']?.toString(),
      notes: map['notes']?.toString(),
      decisionReason: map['decisionReason']?.toString(),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      respondedAt: _parseDateTime(map['respondedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'slotNumber': slotNumber,
      'slotStartTime': slotStartTime,
      'slotEndTime': slotEndTime,
      'status': status,
      'doctor': doctor?.toMap(),
      'patient': patient?.toMap(),
      'patientName': patientName,
      'patientPhone': patientPhone,
      'notes': notes,
      'decisionReason': decisionReason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  String toJson() => convert.jsonEncode(toMap());

  factory AppointmentDetailModel.fromJson(String source) =>
      AppointmentDetailModel.fromMap(
        convert.jsonDecode(source) as Map<String, dynamic>,
      );
}
