class DiagnosticModel {
  final int? id;
  final String category;
  final String? tag;
  final String? doctor;
  final String? data;
  final DateTime? datetimeEnd;
  final String? hospitalName;
  final String? type;
  final List<String> tagNames;
  final List<String> attachmentUrls;

  DiagnosticModel({
    required this.id,
    required this.category,
    required this.tag,
    required this.type,
    required this.doctor,
    required this.data,
    required this.datetimeEnd,
    required this.hospitalName,
    required this.tagNames,
    required this.attachmentUrls,
  });

  factory DiagnosticModel.fromMap(Map<String, dynamic> map) {
    final attachments = map['attachments'];
    return DiagnosticModel(
      id: map['id'] is num ? (map['id'] as num).toInt() : int.tryParse('${map['id']}'),
      category: (map['category'] ?? '').toString(),
      tag: map['tag']?.toString(),
      type: map['type']?.toString(),
      doctor: map['doctor']?.toString(),
      data: map['data']?.toString(),
      datetimeEnd: map['datetimeEnd'] != null ? DateTime.tryParse(map['datetimeEnd'].toString()) : null,
      hospitalName: map['hospitalName']?.toString(),
      tagNames: List<String>.from((map['tagNames'] as List? ?? const []).map((e) => e.toString())),
      attachmentUrls: attachments is List
          ? attachments
              .map((e) => (e as Map?)?['imageUrl'])
              .whereType<String>()
              .toList()
          : const [],
    );
  }
}
