class LinkRequestModel {
  final String requestId;
  final String requesterUserId;
  final String ownerUserId;
  final String targetProfileId;
  final String targetProfileName;
  final String requestType;
  final String? requestedRelationship;
  final String? note;
  final String status;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final DateTime? createdAt;

  const LinkRequestModel({
    required this.requestId,
    required this.requesterUserId,
    required this.ownerUserId,
    required this.targetProfileId,
    required this.targetProfileName,
    required this.requestType,
    this.requestedRelationship,
    this.note,
    required this.status,
    this.expiresAt,
    this.respondedAt,
    this.createdAt,
  });

  factory LinkRequestModel.fromMap(Map<String, dynamic> map) {
    return LinkRequestModel(
      requestId: map['requestId']?.toString() ?? '',
      requesterUserId: map['requesterUserId']?.toString() ?? '',
      ownerUserId: map['ownerUserId']?.toString() ?? '',
      targetProfileId: map['targetProfileId']?.toString() ?? '',
      targetProfileName: map['targetProfileName']?.toString() ?? '',
      requestType: map['requestType']?.toString() ?? 'REGISTER_LINK',
      requestedRelationship: map['requestedRelationship']?.toString(),
      note: map['note']?.toString(),
      status: map['status']?.toString() ?? 'PENDING',
      expiresAt: _parseDate(map['expiresAt']),
      respondedAt: _parseDate(map['respondedAt']),
      createdAt: _parseDate(map['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
