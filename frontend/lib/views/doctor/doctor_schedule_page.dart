// doctor_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/models/doctor/appointment_slot_model.dart';
import 'package:frontend/data/models/doctor/doctor_schedule_day_model.dart';
import 'package:frontend/viewmodels/schedule_viewmodel.dart';
import 'package:frontend/viewmodels/user_viewmodel.dart';
import 'package:frontend/utils/app_theme.dart';
import 'doctor_schedule_widgets.dart';

class DoctorSchedulePage extends StatefulWidget {
  const DoctorSchedulePage({super.key});

  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  late DateTime _selectedDate;
  int _currentWeekOffset = 0;

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekdayKey(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'MONDAY';
      case DateTime.tuesday:
        return 'TUESDAY';
      case DateTime.wednesday:
        return 'WEDNESDAY';
      case DateTime.thursday:
        return 'THURSDAY';
      case DateTime.friday:
        return 'FRIDAY';
      case DateTime.saturday:
        return 'SATURDAY';
      case DateTime.sunday:
        return 'SUNDAY';
      default:
        return 'MONDAY';
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = _normalizeDate(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedule();
      _ensureDoctorProfileLoaded();
    });
  }

  void _ensureDoctorProfileLoaded() {
    final userVM = context.read<UserViewModel>();
    if (!userVM.isLoading && userVM.profile == null) {
      userVM.loadMyProfile();
    }
  }

  void _loadSchedule() {
    context.read<ScheduleViewModel>().fetchSchedule(
      daysOffset: _currentWeekOffset,
      doctorId: null,
      overrideDoctor: true,
    );
  }

  void _goToPreviousWeek() {
    setState(() {
      _currentWeekOffset -= 7;
      _selectedDate = _normalizeDate(
        _selectedDate.subtract(const Duration(days: 7)),
      );
    });
    _loadSchedule();
  }

  void _goToNextWeek() {
    setState(() {
      _currentWeekOffset += 7;
      _selectedDate = _normalizeDate(
        _selectedDate.add(const Duration(days: 7)),
      );
    });
    _loadSchedule();
  }

  void _goToToday() {
    setState(() {
      _currentWeekOffset = 0;
      _selectedDate = _normalizeDate(DateTime.now());
    });
    _loadSchedule();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = _normalizeDate(date);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      final normalizedPicked = _normalizeDate(picked);
      final today = _normalizeDate(DateTime.now());
      setState(() {
        _selectedDate = normalizedPicked;
        _currentWeekOffset = normalizedPicked.difference(today).inDays;
      });
      _loadSchedule();
    }
  }

  String _getDayName(DateTime date) {
    const dayNames = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'CN',
    ];
    return dayNames[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _openAppointmentDetail(AppointmentSlotModel slot, DateTime date) {
    if (slot.id == 0) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppointmentDetailDialog(slot: slot, date: date),
    );
  }

  void _openManualAppointmentSheet(
      DoctorScheduleDayModel day, {
        AppointmentSlotModel? initialSlot,
      }) {
    final doctorId = context.read<UserViewModel>().profile?.id;
    if (doctorId == null || doctorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không tìm thấy thông tin bác sĩ. Vui lòng thử lại.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManualAppointmentSheet(
        date: day.date,
        slots: day.slots,
        doctorId: doctorId,
        initialSlot: initialSlot,
      ),
    );
  }

  void _handleSlotTap(AppointmentSlotModel slot, DoctorScheduleDayModel day) {
    if (slot.isAvailable) {
      _openManualAppointmentSheet(day, initialSlot: slot);
    } else if (slot.id != 0) {
      _openAppointmentDetail(slot, day.date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Lịch khám bệnh nhân',
          style: TextStyle(
            color: Color(0xFF1A2C3E),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF1A2C3E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ScheduleViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${viewModel.errorMessage}',
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSchedule,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final selectedDaySchedule = viewModel.schedule.firstWhere(
                (day) => _isSameDay(day.date, _selectedDate),
            orElse: () => DoctorScheduleDayModel(
              date: _selectedDate,
              dayOfWeek: _weekdayKey(_selectedDate),
              slots: [],
              pendingCount: 0,
              bookedCount: 0,
            ),
          );

          return Column(
            children: [
              // Modern Date Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    // Week Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          onPressed: _goToPreviousWeek,
                        ),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatDate(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A2C3E),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          onPressed: _goToNextWeek,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Week Days Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(7, (index) {
                          final today = _normalizeDate(DateTime.now());
                          final date = today.add(
                            Duration(days: _currentWeekOffset + index),
                          );
                          final isSelected = _isSameDay(date, _selectedDate);
                          final isToday = _isSameDay(date, _normalizeDate(DateTime.now()));

                          return GestureDetector(
                            onTap: () => _selectDate(date),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _getDayName(date),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isToday && !isSelected
                                          ? AppTheme.primaryColor.withOpacity(0.1)
                                          : null,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        date.day.toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : isToday
                                              ? AppTheme.primaryColor
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                    onPressed: selectedDaySchedule.slots.isEmpty
                        ? null
                        : () => _openManualAppointmentSheet(selectedDaySchedule),
                    elevation: 0,
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tạo lịch thủ công',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Appointments List
              Expanded(
                child: selectedDaySchedule.slots.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có lịch khám trong ngày này',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: selectedDaySchedule.slots.length,
                  itemBuilder: (context, index) {
                    final slot = selectedDaySchedule.slots[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppointmentSlotWidget(
                        slot: slot,
                        onTap: () => _handleSlotTap(slot, selectedDaySchedule),
                        showActions: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}