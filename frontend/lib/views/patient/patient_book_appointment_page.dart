import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:frontend/data/models/doctor/appointment_slot_model.dart';
import 'package:frontend/data/models/doctor/doctor_model.dart';
import 'package:frontend/data/models/doctor/doctor_schedule_day_model.dart';
import 'package:frontend/data/repositories/appointment_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/viewmodels/schedule_viewmodel.dart';
import 'package:frontend/viewmodels/user_viewmodel.dart';

class PatientBookAppointmentPage extends StatefulWidget {
  const PatientBookAppointmentPage({super.key});

  @override
  State<PatientBookAppointmentPage> createState() =>
      _PatientBookAppointmentPageState();
}

class _PatientBookAppointmentPageState
    extends State<PatientBookAppointmentPage> {
  late final ScheduleViewModel _scheduleViewModel;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;
  late final TextEditingController _doctorSearchController;

  List<DoctorModel> _doctors = const <DoctorModel>[];
  bool _isLoadingDoctors = false;
  String? _doctorErrorMessage;
  DoctorModel? _selectedDoctor;

  DateTime _selectedDate = _normalize(DateTime.now());
  int _currentWeekOffset = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _scheduleViewModel = ScheduleViewModel(
      context.read<AppointmentRepository>(),
    );
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _notesController = TextEditingController();
    _doctorSearchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureProfilePrefilled();
      _loadDoctors();
    });
  }

  @override
  void dispose() {
    _scheduleViewModel.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _doctorSearchController.dispose();
    super.dispose();
  }

  void _ensureProfilePrefilled() {
    final userVM = context.read<UserViewModel>();
    if (userVM.profile != null) {
      _prefillPatientFields();
      return;
    }
    if (!userVM.isLoading) {
      userVM.loadMyProfile().whenComplete(() {
        if (mounted) _prefillPatientFields();
      });
    }
  }

  void _prefillPatientFields() {
    final profile = context.read<UserViewModel>().profile;
    if (profile == null) return;
    final fallbackName = profile.fullName.trim().isEmpty
        ? profile.email.trim()
        : profile.fullName.trim();
    if (_nameController.text.trim().isEmpty && fallbackName.isNotEmpty) {
      _nameController.text = fallbackName;
    }
    if (_phoneController.text.trim().isEmpty &&
        profile.phoneNumber.trim().isNotEmpty) {
      _phoneController.text = profile.phoneNumber.trim();
    }
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoadingDoctors = true;
      _doctorErrorMessage = null;
    });
    try {
      final repo = context.read<UserRepository>();
      final profiles = await repo.fetchDoctors();
      final doctors = profiles.map(DoctorModel.fromUserProfile).toList();
      if (!mounted) return;
      setState(() {
        _doctors = doctors;
      });
      if (doctors.isNotEmpty) {
        _selectDoctor(doctors.first);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _doctorErrorMessage = 'Không thể tải danh sách bác sĩ: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingDoctors = false);
      }
    }
  }

  void _selectDoctor(DoctorModel doctor) {
    setState(() {
      _selectedDoctor = doctor;
      _currentWeekOffset = 0;
      _selectedDate = _normalize(DateTime.now());
    });
    _reloadSchedule();
  }

  void _reloadSchedule() {
    final doctor = _selectedDoctor;
    if (doctor == null) return;
    _scheduleViewModel.fetchSchedule(
      daysOffset: _currentWeekOffset,
      doctorId: doctor.id,
      overrideDoctor: true,
    );
  }

  Future<void> _pickDate() async {
    final doctor = _selectedDoctor;
    if (doctor == null) {
      _showSnack('Vui lòng chọn bác sĩ trước', false);
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _normalize(DateTime.now()),
      lastDate: _normalize(DateTime.now().add(const Duration(days: 60))),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    final normalized = _normalize(picked);
    final today = _normalize(DateTime.now());
    setState(() {
      _selectedDate = normalized;
      _currentWeekOffset = normalized.difference(today).inDays;
    });
    _reloadSchedule();
  }

  void _goToPreviousWeek() {
    if (_selectedDoctor == null || _currentWeekOffset == 0) return;
    setState(() {
      _currentWeekOffset = (_currentWeekOffset - 7).clamp(0, 365);
      _selectedDate = _normalize(
        _selectedDate.subtract(const Duration(days: 7)),
      );
    });
    _reloadSchedule();
  }

  void _goToNextWeek() {
    if (_selectedDoctor == null) return;
    setState(() {
      _currentWeekOffset += 7;
      _selectedDate = _normalize(_selectedDate.add(const Duration(days: 7)));
    });
    _reloadSchedule();
  }

  List<DoctorModel> get _filteredDoctors {
    final query = _doctorSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return _doctors;
    return _doctors
        .where(
          (doc) =>
              doc.name.toLowerCase().contains(query) ||
              doc.specialty.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _handleBookSlot(
    DoctorScheduleDayModel day,
    AppointmentSlotModel slot,
  ) async {
    final doctor = _selectedDoctor;
    if (doctor == null || _isSubmitting) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      _showSnack('Vui lòng nhập đầy đủ họ tên và số điện thoại.', false);
      return;
    }

    final confirmed = await _showConfirmDialog(day, slot, doctor, name, phone);
    if (!confirmed) return;

    setState(() => _isSubmitting = true);
    final result = await _scheduleViewModel.requestAppointment(
      doctorId: doctor.id,
      appointmentDate: DateFormat('yyyy-MM-dd').format(day.date),
      slotNumber: slot.slotNumber,
      patientName: name,
      patientPhone: phone,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result != null) {
      _showSnack('Đặt lịch thành công, vui lòng chờ bác sĩ xác nhận.', true);
      _reloadSchedule();
    } else {
      _showSnack(
        _scheduleViewModel.errorMessage ?? 'Không thể đặt lịch lúc này.',
        false,
      );
    }
  }

  Future<bool> _showConfirmDialog(
    DoctorScheduleDayModel day,
    AppointmentSlotModel slot,
    DoctorModel doctor,
    String name,
    String phone,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận đặt lịch'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _confirmRow('Bác sĩ', doctor.name),
                _confirmRow(
                  'Ngày khám',
                  DateFormat('dd/MM/yyyy').format(day.date),
                ),
                _confirmRow(
                  'Khung giờ',
                  '${slot.slotStartTime} - ${slot.slotEndTime}',
                ),
                _confirmRow('Bệnh nhân', name),
                _confirmRow('SĐT', phone),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.captionTextColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, bool success) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade400,
      ),
    );
  }

  static DateTime _normalize(DateTime date) =>
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
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    return ChangeNotifierProvider<ScheduleViewModel>.value(
      value: _scheduleViewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: const Text(
            'Đặt lịch khám',
            style: TextStyle(
              color: Color(0xFF1A2C3E),
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1A2C3E),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Consumer<ScheduleViewModel>(
            builder: (context, scheduleVM, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Thông tin bệnh nhân'),
                    const SizedBox(height: 12),
                    _buildPatientInfoCard(userVM),
                    const SizedBox(height: 24),
                    _sectionTitle('Chọn bác sĩ'),
                    const SizedBox(height: 12),
                    _buildDoctorPicker(),
                    const SizedBox(height: 24),
                    if (_selectedDoctor != null) ...[
                      _sectionTitle('Lịch khả dụng'),
                      const SizedBox(height: 12),
                      _buildDateNavigator(scheduleVM),
                      const SizedBox(height: 16),
                      _buildSlotList(scheduleVM),
                    ] else ...[
                      _emptyState('Chọn bác sĩ để xem lịch khả dụng.'),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard(UserViewModel userVM) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại liên hệ',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (tuỳ chọn)',
              prefixIcon: Icon(Icons.description_outlined),
            ),
          ),
          if (userVM.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildDoctorPicker() {
    if (_isLoadingDoctors) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }
    if (_doctorErrorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _errorBanner(_doctorErrorMessage!),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _loadDoctors,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử tải lại danh sách bác sĩ'),
          ),
        ],
      );
    }
    if (_doctors.isEmpty) {
      return _emptyState('Chưa có bác sĩ nào khả dụng.');
    }

    final doctors = _filteredDoctors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _doctorSearchController,
          decoration: InputDecoration(
            labelText: 'Tìm bác sĩ theo tên hoặc chuyên môn',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _doctorSearchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _doctorSearchController.clear();
                      setState(() {});
                    },
                  ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        if (doctors.isEmpty)
          _emptyState('Không tìm thấy bác sĩ phù hợp với từ khóa.')
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: doctors
                  .map(
                    (doctor) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _DoctorChip(
                        doctor: doctor,
                        selected: _selectedDoctor?.id == doctor.id,
                        onTap: () => _selectDoctor(doctor),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        if (_selectedDoctor != null) ...[
          const SizedBox(height: 16),
          _SelectedDoctorCard(doctor: _selectedDoctor!),
        ],
      ],
    );
  }

  Widget _buildDateNavigator(ScheduleViewModel scheduleVM) {
    final startDate = _normalize(
      DateTime.now(),
    ).add(Duration(days: _currentWeekOffset));
    final weekDates = List.generate(
      7,
      (index) => startDate.add(Duration(days: index)),
    );
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _currentWeekOffset == 0 ? null : _goToPreviousWeek,
              icon: Icon(
                Icons.chevron_left,
                color: _currentWeekOffset == 0
                    ? Colors.grey.shade400
                    : AppTheme.primaryColor,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2C3E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _goToNextWeek,
              icon: const Icon(
                Icons.chevron_right,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 78,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weekDates.length,
            itemBuilder: (context, index) {
              final date = weekDates[index];
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, _normalize(DateTime.now()));
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey.shade200,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                              ? AppTheme.primaryColor
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isSelected
                            ? Colors.white
                            : isToday
                            ? AppTheme.primaryColor.withOpacity(0.15)
                            : Colors.grey.shade100,
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSlotList(ScheduleViewModel scheduleVM) {
    if (_selectedDoctor == null) {
      return _emptyState('Chọn bác sĩ trước khi xem lịch.');
    }
    if (scheduleVM.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }
    if (scheduleVM.errorMessage != null) {
      return _errorBanner(scheduleVM.errorMessage!);
    }

    final selectedDay = scheduleVM.schedule.firstWhere(
      (day) => _isSameDay(day.date, _selectedDate),
      orElse: () => DoctorScheduleDayModel(
        date: _selectedDate,
        dayOfWeek: _weekdayKey(_selectedDate),
        slots: const <AppointmentSlotModel>[],
      ),
    );

    final availableSlots = selectedDay.slots
        .where((slot) => slot.isAvailable)
        .toList();
    if (availableSlots.isEmpty) {
      return _emptyState(
        'Ngày này không còn khung giờ trống. Vui lòng chọn ngày khác.',
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final slot = availableSlots[index];
        return _SlotCard(
          slot: slot,
          date: selectedDay.date,
          onBook: _isSubmitting
              ? null
              : () => _handleBookSlot(selectedDay, slot),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: availableSlots.length,
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A2C3E),
      ),
    );
  }
}

class _DoctorChip extends StatelessWidget {
  final DoctorModel doctor;
  final bool selected;
  final VoidCallback onTap;

  const _DoctorChip({
    required this.doctor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            doctor.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF1A2C3E),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            doctor.specialty,
            style: TextStyle(
              color: selected ? Colors.white70 : Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
        ),
      ),
    );
  }
}

class _SelectedDoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const _SelectedDoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(doctor.imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2C3E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kinh nghiệm: ${doctor.experienceYears}+ năm • Đánh giá ${doctor.rating.toStringAsFixed(1)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  'Liên hệ: ${doctor.contactPhone}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final AppointmentSlotModel slot;
  final DateTime date;
  final VoidCallback? onBook;

  const _SlotCard({
    required this.slot,
    required this.date,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot.slotStartTime} - ${slot.slotEndTime}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2C3E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, dd MMM').format(date),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Trạng thái: Còn trống',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Đặt lịch'),
          ),
        ],
      ),
    );
  }
}
