
import 'package:frontend/data/models/record/medical_record_list_item_model.dart';

abstract class MedicalRecordState {}

class MedicalRecordInitial extends MedicalRecordState {}

class MedicalRecordLoading extends MedicalRecordState {}

class MedicalRecordLoaded extends MedicalRecordState {
  final List<MedicalRecordListItemModel> records;
  MedicalRecordLoaded(this.records);
}

class MedicalRecordError extends MedicalRecordState {
  final String message;
  MedicalRecordError(this.message);
}