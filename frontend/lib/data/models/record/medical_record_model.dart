import 'dart:convert' as Convert;

class MedicalRecordModel {
  final String? id;
  final String title;
  final String type; // 'Test', 'Prescription', 'Diagnosis'
  final List<String> tags;
  final String notes;
  final bool isImportant;
  final DateTime createdAt;
  final String patientId; // ID của người thân hoặc bản thân

  MedicalRecordModel({
    this.id,
    required this.title,
    required this.type,
    required this.tags,
    required this.notes,
    required this.isImportant,
    required this.createdAt,
    required this.patientId,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'type': type,
    'tags': tags,
    'notes': notes,
    'isImportant': isImportant,
    'patientId': patientId,
  };

  String toJson() => Convert.jsonEncode(toMap());

  factory MedicalRecordModel.fromMap(Map<String, dynamic> map) {
    return MedicalRecordModel(
      id: map['id'],
      title: map['title'],
      type: map['type'],
      tags: List<String>.from(map['tags'] ?? []),
      notes: map['notes'] ?? '',
      isImportant: map['important'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      patientId: map['patientId'],
    );
  }
}