import 'package:frontend/data/models/record/diagnostic_model.dart';

class EncounterModel {
  final int? id;
  final String title;
  final String? tag;
  final String? note;
  final String? hospitalName;
  final DateTime? datetimeStart;
  final DateTime? datetimeEnd;
  final List<String> tagNames;
  final List<DiagnosticModel> diagnostics;

  EncounterModel({
    required this.id,
    required this.title,
    required this.tag,
    required this.note,
    required this.hospitalName,
    required this.datetimeStart,
    required this.datetimeEnd,
    required this.tagNames,
    required this.diagnostics,
  });

  factory EncounterModel.fromMap(Map<String, dynamic> map) {
    final diagnostics = map['diagnosticRecords'];
    return EncounterModel(
      id: map['id'] is num ? (map['id'] as num).toInt() : int.tryParse('${map['id']}'),
      title: (map['title'] ?? '').toString(),
      tag: map['tag']?.toString(),
      note: map['note']?.toString(),
      hospitalName: map['hospitalName']?.toString(),
      datetimeStart: map['datetimeStart'] != null ? DateTime.tryParse(map['datetimeStart'].toString()) : null,
      datetimeEnd: map['datetimeEnd'] != null ? DateTime.tryParse(map['datetimeEnd'].toString()) : null,
      tagNames: List<String>.from((map['tagNames'] as List? ?? const []).map((e) => e.toString())),
      diagnostics: diagnostics is List
          ? diagnostics
              .map((e) => DiagnosticModel.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }
}
