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

enum SlotFilter { all, pending, booked, available }

class DoctorSchedulePage extends StatefulWidget {
  const DoctorSchedulePage({super.key});

  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  late DateTime _selectedDate;
  int _currentWeekOffset = 0;
  SlotFilter _slotFilter = SlotFilter.all;

  // Date utilities
  DateTime get _today => _normalizeDate(DateTime.now());

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _getWeekdayKey(DateTime date) {
    const weekdays = {
      DateTime.monday: 'MONDAY',
      DateTime.tuesday: 'TUESDAY',
      DateTime.wednesday: 'WEDNESDAY',
      DateTime.thursday: 'THURSDAY',
      DateTime.friday: 'FRIDAY',
      DateTime.saturday: 'SATURDAY',
      DateTime.sunday: 'SUNDAY',
    };
    return weekdays[date.weekday] ?? 'MONDAY';
  }

  String _getDayName(DateTime date) {
    const dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    return dayNames[date.weekday - 1];
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

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
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
    _loadSchedule();
  }

  void _goToNextWeek() {
    setState(() {
      _currentWeekOffset += 7;
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    });
    _loadSchedule();
  }

  void _goToToday() {
    setState(() {
      _currentWeekOffset = 0;
      _selectedDate = _today;
    });
    _loadSchedule();
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = _normalizeDate(date));
  }

  List<AppointmentSlotModel> _filterSlots(List<AppointmentSlotModel> slots) {
    switch (_slotFilter) {
      case SlotFilter.pending:
        return slots.where((slot) => slot.isPending).toList();
      case SlotFilter.booked:
        return slots.where((slot) => slot.isBooked).toList();
      case SlotFilter.available:
        return slots.where((slot) => slot.isAvailable).toList();
      case SlotFilter.all:
        return slots;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = _normalizeDate(picked);
        _currentWeekOffset = _selectedDate.difference(_today).inDays;
      });
      _loadSchedule();
    }
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
      _showErrorSnackBar('Không tìm thấy thông tin bác sĩ. Vui lòng thử lại.');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade400,
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
      appBar: _buildAppBar(),
      body: Consumer<ScheduleViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const _LoadingState();
          }

          if (viewModel.errorMessage != null) {
            return _ErrorState(
              errorMessage: viewModel.errorMessage!,
              onRetry: _loadSchedule,
            );
          }

          final selectedDaySchedule = _getSelectedDaySchedule(viewModel);
          final dayStats = _DayStats.fromSlots(selectedDaySchedule.slots);
          final filteredSlots = _filterSlots(selectedDaySchedule.slots);

          return Column(
            children: [
              _DateHeader(
                selectedDate: _selectedDate,
                currentWeekOffset: _currentWeekOffset,
                onPreviousWeek: _goToPreviousWeek,
                onNextWeek: _goToNextWeek,
                onDateSelected: _pickDate,
                onSelectDate: _selectDate,
                getDayName: _getDayName,
                formatDate: _formatDate,
                isSameDay: _isSameDay,
                normalizeDate: _normalizeDate,
              ),
              _PendingOverviewCard(
                totalPending: viewModel.pendingApprovalCount,
                todayPending: dayStats.pendingCount,
                onRefresh: viewModel.refreshPendingCount,
              ),
              _CreateAppointmentButton(
                onPressed: selectedDaySchedule.slots.isEmpty
                    ? null
                    : () => _openManualAppointmentSheet(selectedDaySchedule),
              ),
              if (selectedDaySchedule.slots.isNotEmpty)
                _SlotFilterBar(
                  totalSlots: selectedDaySchedule.slots.length,
                  pendingCount: dayStats.pendingCount,
                  bookedCount: dayStats.bookedCount,
                  availableCount: dayStats.availableCount,
                  currentFilter: _slotFilter,
                  onFilterChanged: (filter) {
                    setState(() => _slotFilter = filter);
                  },
                ),
              Expanded(
                child: _AppointmentList(
                  slots: filteredSlots,
                  onSlotTap: (slot) => _handleSlotTap(slot, selectedDaySchedule),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  DoctorScheduleDayModel _getSelectedDaySchedule(ScheduleViewModel viewModel) {
    return viewModel.schedule.firstWhere(
          (day) => _isSameDay(day.date, _selectedDate),
      orElse: () => DoctorScheduleDayModel(
        date: _selectedDate,
        dayOfWeek: _getWeekdayKey(_selectedDate),
        slots: [],
        pendingCount: 0,
        bookedCount: 0,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }
}

// MARK: - Date Header Component
class _DateHeader extends StatelessWidget {
  final DateTime selectedDate;
  final int currentWeekOffset;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onDateSelected;
  final Function(DateTime) onSelectDate;
  final String Function(DateTime) getDayName;
  final String Function(DateTime) formatDate;
  final bool Function(DateTime, DateTime) isSameDay;
  final DateTime Function(DateTime) normalizeDate;

  const _DateHeader({
    required this.selectedDate,
    required this.currentWeekOffset,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onDateSelected,
    required this.onSelectDate,
    required this.getDayName,
    required this.formatDate,
    required this.isSameDay,
    required this.normalizeDate,
  });

  @override
  Widget build(BuildContext context) {
    final today = normalizeDate(DateTime.now());

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          _WeekNavigation(
            selectedDate: selectedDate,
            formatDate: formatDate,
            onPreviousWeek: onPreviousWeek,
            onNextWeek: onNextWeek,
            onDateSelected: onDateSelected,
          ),
          const SizedBox(height: 16),
          _WeekDaysRow(
            currentWeekOffset: currentWeekOffset,
            selectedDate: selectedDate,
            today: today,
            onSelectDate: onSelectDate,
            getDayName: getDayName,
            isSameDay: isSameDay,
            normalizeDate: normalizeDate,
          ),
        ],
      ),
    );
  }
}

class _WeekNavigation extends StatelessWidget {
  final DateTime selectedDate;
  final String Function(DateTime) formatDate;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onDateSelected;

  const _WeekNavigation({
    required this.selectedDate,
    required this.formatDate,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavigationIconButton(icon: Icons.chevron_left, onPressed: onPreviousWeek),
        GestureDetector(
          onTap: onDateSelected,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatDate(selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2C3E),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
        _NavigationIconButton(icon: Icons.chevron_right, onPressed: onNextWeek),
      ],
    );
  }
}

class _NavigationIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _NavigationIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 24),
      ),
      onPressed: onPressed,
    );
  }
}

class _WeekDaysRow extends StatelessWidget {
  final int currentWeekOffset;
  final DateTime selectedDate;
  final DateTime today;
  final Function(DateTime) onSelectDate;
  final String Function(DateTime) getDayName;
  final bool Function(DateTime, DateTime) isSameDay;
  final DateTime Function(DateTime) normalizeDate;

  const _WeekDaysRow({
    required this.currentWeekOffset,
    required this.selectedDate,
    required this.today,
    required this.onSelectDate,
    required this.getDayName,
    required this.isSameDay,
    required this.normalizeDate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(7, (index) {
          final date = normalizeDate(today.add(Duration(days: currentWeekOffset + index)));
          final isSelected = isSameDay(date, selectedDate);
          final isToday = isSameDay(date, today);

          return _DayChip(
            date: date,
            dayName: getDayName(date),
            isSelected: isSelected,
            isToday: isToday,
            onTap: () => onSelectDate(date),
          );
        }),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final String dayName;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayChip({
    required this.date,
    required this.dayName,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
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
  }
}

// MARK: - Pending Overview Card
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
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
              onPressed: () => onRefresh(),
              icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - Create Appointment Button
class _CreateAppointmentButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _CreateAppointmentButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: MaterialButton(
          onPressed: onPressed,
          elevation: 0,
          color: AppTheme.primaryColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    );
  }
}

// MARK: - Slot Filter Bar
class _SlotFilterBar extends StatelessWidget {
  final int totalSlots;
  final int pendingCount;
  final int bookedCount;
  final int availableCount;
  final SlotFilter currentFilter;
  final Function(SlotFilter) onFilterChanged;

  const _SlotFilterBar({
    required this.totalSlots,
    required this.pendingCount,
    required this.bookedCount,
    required this.availableCount,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Tất cả',
              count: totalSlots,
              selected: currentFilter == SlotFilter.all,
              onTap: () => onFilterChanged(SlotFilter.all),
            ),
            _FilterChip(
              label: 'Chờ duyệt',
              count: pendingCount,
              selected: currentFilter == SlotFilter.pending,
              onTap: () => onFilterChanged(SlotFilter.pending),
            ),
            _FilterChip(
              label: 'Đã duyệt',
              count: bookedCount,
              selected: currentFilter == SlotFilter.booked,
              onTap: () => onFilterChanged(SlotFilter.booked),
            ),
            _FilterChip(
              label: 'Trống',
              count: availableCount,
              selected: currentFilter == SlotFilter.available,
              onTap: () => onFilterChanged(SlotFilter.available),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
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

// MARK: - Appointment List
class _AppointmentList extends StatelessWidget {
  final List<AppointmentSlotModel> slots;
  final Function(AppointmentSlotModel) onSlotTap;

  const _AppointmentList({
    required this.slots,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có lịch khám với bộ lọc này',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppointmentSlotWidget(
            slot: slot,
            onTap: () => onSlotTap(slot),
            showActions: true,
          ),
        );
      },
    );
  }
}

// MARK: - Utility Classes
class _DayStats {
  final int pendingCount;
  final int bookedCount;
  final int availableCount;

  _DayStats({
    required this.pendingCount,
    required this.bookedCount,
    required this.availableCount,
  });

  factory _DayStats.fromSlots(List<AppointmentSlotModel> slots) {
    return _DayStats(
      pendingCount: slots.where((slot) => slot.isPending).length,
      bookedCount: slots.where((slot) => slot.isBooked).length,
      availableCount: slots.where((slot) => slot.isAvailable).length,
    );
  }
}

// MARK: - State Widgets
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
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
            'Lỗi: $errorMessage',
            style: TextStyle(color: Colors.red.shade400),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}