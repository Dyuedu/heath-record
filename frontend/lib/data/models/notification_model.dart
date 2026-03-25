
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? patientName;
  final String? doctorName;
  final String? hospitalName;
  final String? recordId;
  final bool isRead;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.patientName,
    this.doctorName,
    this.hospitalName,
    this.recordId,
    required this.isRead,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      patientName: (json['patientName'] as String?) ?? _extractPatientName(json['message'] as String?),
      doctorName: json['doctorName'] as String?,
      hospitalName: json['hospitalName'] as String?,
      recordId: json['recordId'] as String?,
      isRead: json['read'] ?? json['isRead'] ?? false,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? patientName,
    String? doctorName,
    String? hospitalName,
    String? recordId,
    bool? isRead,
    DateTime? timestamp,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      hospitalName: hospitalName ?? this.hospitalName,
      recordId: recordId ?? this.recordId,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  static String? _extractPatientName(String? message) {
    if (message == null || message.isEmpty) {
      return null;
    }

    const marker = ' cho ';
    final markerIndex = message.lastIndexOf(marker);
    if (markerIndex < 0) {
      return null;
    }

    var candidate = message.substring(markerIndex + marker.length).trim();
    if (candidate.endsWith('.')) {
      candidate = candidate.substring(0, candidate.length - 1).trim();
    }

    return candidate.isEmpty ? null : candidate;
  }
}
