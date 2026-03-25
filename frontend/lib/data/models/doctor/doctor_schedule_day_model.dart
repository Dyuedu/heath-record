import 'dart:convert' as convert;
import 'appointment_slot_model.dart';

class DoctorScheduleDayModel {
  final DateTime date;
  final String dayOfWeek; // Monday, Tuesday, ...
  final List<AppointmentSlotModel> slots;
  final int pendingCount;
  final int bookedCount;

  DoctorScheduleDayModel({
    required this.date,
    required this.dayOfWeek,
    required this.slots,
    this.pendingCount = 0,
    this.bookedCount = 0,
  });

  int get availableCount => slots.where((s) => s.isAvailable).length;
  int get totalSlots => slots.length;

  String get displayDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get dayName {
    switch (dayOfWeek) {
      case 'MONDAY':
        return 'Thứ 2';
      case 'TUESDAY':
        return 'Thứ 3';
      case 'WEDNESDAY':
        return 'Thứ 4';
      case 'THURSDAY':
        return 'Thứ 5';
      case 'FRIDAY':
        return 'Thứ 6';
      case 'SATURDAY':
        return 'Thứ 7';
      case 'SUNDAY':
        return 'Chủ nhật';
      default:
        return dayOfWeek;
    }
  }

  factory DoctorScheduleDayModel.fromMap(Map<String, dynamic> map) {
    final dateStr = map['date'] ?? '';
    final parsedDate = dateStr.isNotEmpty
        ? DateTime.parse(dateStr.toString())
        : DateTime.now();

    final rawSlots = map['slots'];
    final slots = (rawSlots is List)
        ? rawSlots
              .map(
                (e) => AppointmentSlotModel.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList()
        : <AppointmentSlotModel>[];

    return DoctorScheduleDayModel(
      date: parsedDate,
      dayOfWeek: (map['dayOfWeek'] ?? 'MONDAY').toString(),
      slots: slots,
      pendingCount: (map['pendingCount'] as num?)?.toInt() ?? 0,
      bookedCount: (map['bookedCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'dayOfWeek': dayOfWeek,
      'slots': slots.map((s) => s.toMap()).toList(),
      'pendingCount': pendingCount,
      'bookedCount': bookedCount,
    };
  }

  String toJson() => convert.jsonEncode(toMap());

  factory DoctorScheduleDayModel.fromJson(String source) =>
      DoctorScheduleDayModel.fromMap(
        convert.jsonDecode(source) as Map<String, dynamic>,
      );
}
