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

  List<DoctorModel> _doctors = [];
  List<String> _availableDepartments = [];
  bool _isLoadingDoctors = false;
  String? _doctorErrorMessage;
  DoctorModel? _selectedDoctor;
  String? _selectedDepartmentFilter;

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
      final departments =
          doctors
              .map((doc) => doc.specialty.trim())
              .where((dept) => dept.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      if (!mounted) return;
      final previousDoctorId = _selectedDoctor?.id;
      setState(() {
        _doctors = doctors;
        _availableDepartments = departments;
        if (_selectedDepartmentFilter != null &&
            !_availableDepartments.contains(_selectedDepartmentFilter)) {
          _selectedDepartmentFilter = null;
        }
        if (previousDoctorId != null) {
          final matchedIndex = doctors.indexWhere(
            (doc) => doc.id == previousDoctorId,
          );
          _selectedDoctor = matchedIndex == -1 ? null : doctors[matchedIndex];
        }
      });
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
    List<DoctorModel> doctors = _doctors;
    if (_selectedDepartmentFilter != null &&
        _selectedDepartmentFilter!.isNotEmpty) {
      final target = _selectedDepartmentFilter!.toLowerCase();
      doctors = doctors
          .where((doc) => doc.specialty.trim().toLowerCase() == target)
          .toList();
    }

    final query = _doctorSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return doctors;

    return doctors
        .where(
          (doc) =>
              doc.name.toLowerCase().contains(query) ||
              doc.contactEmail.toLowerCase().contains(query),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Xác nhận đặt lịch',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfirmRow('Bác sĩ', doctor.name),
                _buildConfirmRow(
                  'Ngày khám',
                  DateFormat('dd/MM/yyyy').format(day.date),
                ),
                _buildConfirmRow(
                  'Khung giờ',
                  '${slot.slotStartTime} - ${slot.slotEndTime}',
                ),
                _buildConfirmRow('Bệnh nhân', name),
                _buildConfirmRow('SĐT', phone),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return ChangeNotifierProvider<ScheduleViewModel>.value(
      value: _scheduleViewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            'Đặt lịch khám',
            style: TextStyle(
              color: Color(0xFF1A2C3E),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1A2C3E),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<ScheduleViewModel>(
          builder: (context, scheduleVM, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Thông tin bệnh nhân'),
                  const SizedBox(height: 12),
                  _buildPatientInfoCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Chọn bác sĩ'),
                  const SizedBox(height: 12),
                  _buildDoctorPicker(),
                  const SizedBox(height: 24),
                  if (_selectedDoctor != null) ...[
                    _buildSectionHeader('Lịch khả dụng'),
                    const SizedBox(height: 12),
                    _buildDateNavigator(scheduleVM),
                    const SizedBox(height: 20),
                    _buildSlotList(scheduleVM),
                  ] else ...[
                    _buildEmptyState('Chọn bác sĩ để xem lịch khả dụng'),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A2C3E),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    final userVM = context.watch<UserViewModel>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Họ và tên',
              labelStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.person_outline, color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Số điện thoại liên hệ',
              labelStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Ghi chú (tuỳ chọn)',
              labelStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(
                Icons.description_outlined,
                color: Colors.grey[500],
              ),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          if (userVM.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDoctorPicker() {
    if (_isLoadingDoctors) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }

    if (_doctorErrorMessage != null) {
      return Column(
        children: [
          _buildErrorBanner(_doctorErrorMessage!),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loadDoctors,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Thử lại'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      );
    }

    if (_doctors.isEmpty) {
      return _buildEmptyState('Chưa có bác sĩ nào khả dụng.');
    }

    final doctors = _filteredDoctors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCompact) ...[
              _buildDepartmentDropdown(),
              const SizedBox(height: 12),
              _buildDoctorSearchField(),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _buildDepartmentDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDoctorSearchField()),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (doctors.isEmpty)
              _buildEmptyState('Không tìm thấy bác sĩ phù hợp.')
            else
              _buildDoctorCarousel(doctors, isCompact),
            if (_selectedDoctor != null) ...[
              const SizedBox(height: 16),
              _buildSelectedDoctorCard(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDoctorCarousel(List<DoctorModel> doctors, bool isCompact) {
    final listHeight = isCompact ? 150.0 : 120.0;
    final cardWidth = isCompact ? 170.0 : 140.0;
    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return _DoctorCard(
            doctor: doctor,
            isSelected: _selectedDoctor?.id == doctor.id,
            onTap: () => _selectDoctor(doctor),
            width: cardWidth,
          );
        },
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDepartmentFilter ?? '',
      items: [
        const DropdownMenuItem(value: '', child: Text('Tất cả khoa')),
        ..._availableDepartments.map(
          (dept) => DropdownMenuItem(value: dept, child: Text(dept)),
        ),
      ],
      onChanged: _availableDepartments.isEmpty
          ? null
          : (value) {
              setState(() {
                final resolved = value == null || value.isEmpty ? null : value;
                _selectedDepartmentFilter = resolved;
                if (_selectedDoctor != null &&
                    _filteredDoctors.every(
                      (doc) => doc.id != _selectedDoctor!.id,
                    )) {
                  _selectedDoctor = null;
                }
              });
            },
      decoration: InputDecoration(
        labelText: 'Chọn khoa',
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(
          Icons.local_hospital_outlined,
          color: Colors.grey[500],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDoctorSearchField() {
    return TextField(
      controller: _doctorSearchController,
      decoration: InputDecoration(
        labelText: 'Tìm bác sĩ theo tên',
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
        suffixIcon: _doctorSearchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  setState(() {
                    _doctorSearchController.clear();
                  });
                },
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildSelectedDoctorCard() {
    final doctor = _selectedDoctor!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(doctor.imageUrl),
              backgroundColor: Colors.grey[200],
              child: doctor.imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 28, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2C3E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${doctor.rating.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.work_outline, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${doctor.experienceYears}+ năm',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
                    ? Colors.grey.shade300
                    : AppTheme.primaryColor,
                size: 28,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2C3E),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _goToNextWeek,
              icon: Icon(
                Icons.chevron_right,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
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
                  width: 65,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey.shade200,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
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
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : isToday
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : Colors.grey.shade100,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
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
      return _buildEmptyState('Chọn bác sĩ trước khi xem lịch.');
    }

    if (scheduleVM.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }

    if (scheduleVM.errorMessage != null) {
      return _buildErrorBanner(scheduleVM.errorMessage!);
    }

    final selectedDay = scheduleVM.schedule.firstWhere(
      (day) => _isSameDay(day.date, _selectedDate),
      orElse: () => DoctorScheduleDayModel(
        date: _selectedDate,
        dayOfWeek: _weekdayKey(_selectedDate),
        slots: [],
      ),
    );

    final availableSlots = selectedDay.slots
        .where((slot) => slot.isAvailable)
        .toList();

    if (availableSlots.isEmpty) {
      return _buildEmptyState(
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

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const _DoctorCard({
    required this.doctor,
    required this.isSelected,
    required this.onTap,
    this.width = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: isSelected ? Colors.white : AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                doctor.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1A2C3E),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                doctor.specialty,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.schedule,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot.slotStartTime} - ${slot.slotEndTime}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1A2C3E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, dd/MM/yyyy').format(date),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Còn trống',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Đặt lịch',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
