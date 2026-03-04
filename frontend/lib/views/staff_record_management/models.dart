class MedicalRecord {
  final String id;

  final String patientName;
  final String patientCode;

  final String title;
  final String type;
  final DateTime date;

  final String doctor;
  final String description;

  final List<String> tags;
  final List<String> imagePaths;

  MedicalRecord({
    required this.id,
    required this.patientName,
    required this.patientCode,
    required this.title,
    required this.type,
    required this.date,
    required this.doctor,
    required this.description,
    required this.tags,
    required this.imagePaths,
  });
}