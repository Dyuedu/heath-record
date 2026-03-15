class MedicalRecordListItemModel {
  final String id; // UUIDs are handled as Strings in Dart
  final String title;
  final DateTime? datetimeStart;
  final String? doctorName;
  final String? hospitalName;
  final List<String> tags;

  MedicalRecordListItemModel({
    required this.id,
    required this.title,
    this.datetimeStart,
    this.doctorName,
    this.hospitalName,
    required this.tags,
  });

  /// Factory to create an instance from a JSON map
  factory MedicalRecordListItemModel.fromMap(Map<String, dynamic> map) {
    return MedicalRecordListItemModel(
      id: map['id'] as String,
      title: map['title'] ?? 'No Title',
      // Parsing ISO-8601 string from Java LocalDateTime
      datetimeStart: map['datetimeStart'] != null
          ? DateTime.parse(map['datetimeStart'])
          : null,
      doctorName: map['doctorName'],
      hospitalName: map['hospitalName'],
      // Safely converting the JSON array to a List<String>
      tags: map['tags'] != null
          ? List<String>.from(map['tags'])
          : [],
    );
  }

  /// Helper to convert the model back to a Map (useful for testing/caching)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'datetimeStart': datetimeStart?.toIso8601String(),
      'doctorName': doctorName,
      'hospitalName': hospitalName,
      'tags': tags,
    };
  }
}