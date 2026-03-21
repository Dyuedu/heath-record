import 'package:frontend/data/models/record/encounter_model.dart';

class RelativeHistoryModel {
  final String relativeId;
  final String profileId;
  final String relativeName;
  final String relationship;
  final String dateOfBirth;
  final String avatarUrl;
  final List<EncounterModel> encounters;

  RelativeHistoryModel({
    required this.relativeId,
    required this.profileId,
    required this.relativeName,
    required this.relationship,
    required this.dateOfBirth,
    required this.avatarUrl,
    required this.encounters,
  });

  factory RelativeHistoryModel.fromMap(Map<String, dynamic> map) {
    final history = map['history'];
    return RelativeHistoryModel(
      relativeId: map['relativeId']?.toString() ?? '',
      profileId: map['profileId']?.toString() ?? '',
      relativeName: map['relativeName']?.toString() ?? '',
      relationship: map['relationship']?.toString() ?? '',
      dateOfBirth: map['dateOfBirth']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString() ?? '',
      encounters: history is List
          ? history
                .map(
                  (e) => EncounterModel.fromMap(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList()
          : const [],
    );
  }
}
