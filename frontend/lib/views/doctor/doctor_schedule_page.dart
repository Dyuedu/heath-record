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

enum _SlotFilter { all, pending, booked, available }

class DoctorSchedulePage extends StatefulWidget {
  const DoctorSchedulePage({super.key});

  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  late DateTime _selectedDate;
  int _currentWeekOffset = 0;
  _SlotFilter _slotFilter = _SlotFilter.all;

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
    final scheduleVM = context.read<ScheduleViewModel>();
    scheduleVM.fetchSchedule(
      daysOffset: _currentWeekOffset,
      doctorId: null,
      overrideDoctor: true,
    );
    scheduleVM.refreshPendingCount();
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

  List<AppointmentSlotModel> _filterSlots(List<AppointmentSlotModel> slots) {
    switch (_slotFilter) {
      case _SlotFilter.pending:
        return slots.where((slot) => slot.isPending).toList();
      case _SlotFilter.booked:
        return slots.where((slot) => slot.isBooked).toList();
      case _SlotFilter.available:
        return slots.where((slot) => slot.isAvailable).toList();
      case _SlotFilter.all:
      default:
        return slots;
    }
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
          content: const Text(
            'Không tìm thấy thông tin bác sĩ. Vui lòng thử lại.',
          ),
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
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Color(0xFF1A2C3E),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ScheduleViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
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
          final daySlots = selectedDaySchedule.slots;
          final filteredSlots = _filterSlots(daySlots);
          final dayPending = daySlots.where((slot) => slot.isPending).length;
          final dayBooked = daySlots.where((slot) => slot.isBooked).length;
          final dayAvailable = daySlots
              .where((slot) => slot.isAvailable)
              .length;

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
                          final isToday = _isSameDay(
                            date,
                            _normalizeDate(DateTime.now()),
                          );

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
                                          ? AppTheme.primaryColor.withOpacity(
                                              0.1,
                                            )
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

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _PendingOverviewCard(
                  totalPending: viewModel.pendingApprovalCount,
                  todayPending: dayPending,
                  onRefresh: viewModel.refreshPendingCount,
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
                        : () =>
                              _openManualAppointmentSheet(selectedDaySchedule),
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

              if (daySlots.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusFilterChip(
                          label: 'Tất cả',
                          count: daySlots.length,
                          selected: _slotFilter == _SlotFilter.all,
                          onTap: () =>
                              setState(() => _slotFilter = _SlotFilter.all),
                        ),
                        _StatusFilterChip(
                          label: 'Chờ duyệt',
                          count: dayPending,
                          selected: _slotFilter == _SlotFilter.pending,
                          onTap: () =>
                              setState(() => _slotFilter = _SlotFilter.pending),
                        ),
                        _StatusFilterChip(
                          label: 'Đã duyệt',
                          count: dayBooked,
                          selected: _slotFilter == _SlotFilter.booked,
                          onTap: () =>
                              setState(() => _slotFilter = _SlotFilter.booked),
                        ),
                        _StatusFilterChip(
                          label: 'Trống',
                          count: dayAvailable,
                          selected: _slotFilter == _SlotFilter.available,
                          onTap: () => setState(
                            () => _slotFilter = _SlotFilter.available,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Appointments List
              Expanded(
                child: daySlots.isEmpty
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
                    : filteredSlots.isEmpty
                    ? Center(
                        child: Text(
                          'Không có lịch với bộ lọc này',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredSlots.length,
                        itemBuilder: (context, index) {
                          final slot = filteredSlots[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppointmentSlotWidget(
                              slot: slot,
                              onTap: () =>
                                  _handleSlotTap(slot, selectedDaySchedule),
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

class _PendingOverviewCard extends StatelessWidget {
  final int totalPending;
  final int todayPending;
  final Future<void> Function() onRefresh;

  const _PendingOverviewCard({
    required this.totalPending,
    required this.todayPending,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_bottom,
              color: AppTheme.primaryColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lịch đang chờ duyệt',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalPending lịch toàn hệ thống',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2C3E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$todayPending lịch trong ngày này',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A6074),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              onRefresh();
            },
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primaryColor,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF1A2C3E),
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
