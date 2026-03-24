import 'package:frontend/data/models/record/relative_history_model.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';

class DoctorPatientDetailModel {
  final UserProfileModel patient;
  final List<RelativeHistoryModel> relatives;

  const DoctorPatientDetailModel({
    required this.patient,
    required this.relatives,
  });

  factory DoctorPatientDetailModel.fromMap(Map<String, dynamic> map) {
    final rawRelatives = map['relatives'];
    return DoctorPatientDetailModel(
      patient: UserProfileModel.fromMap(
        Map<String, dynamic>.from(map['patient'] ?? const {}),
      ),
      relatives: rawRelatives is List
          ? rawRelatives
                .map(
                  (e) => RelativeHistoryModel.fromMap(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList()
          : const [],
    );
  }
}