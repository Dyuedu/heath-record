// doctor_schedule_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:frontend/data/models/doctor/appointment_slot_model.dart';
import 'package:frontend/data/models/doctor/doctor_schedule_day_model.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/viewmodels/schedule_viewmodel.dart';

class AppointmentSlotWidget extends StatefulWidget {
  final AppointmentSlotModel slot;
  final VoidCallback onTap;
  final bool showActions;

  const AppointmentSlotWidget({
    super.key,
    required this.slot,
    required this.onTap,
    this.showActions = true,
  });

  @override
  State<AppointmentSlotWidget> createState() => _AppointmentSlotWidgetState();
}

class _AppointmentSlotWidgetState extends State<AppointmentSlotWidget> {
  bool _isProcessing = false;

  bool get _canManage =>
      widget.showActions && widget.slot.isPending && widget.slot.id != 0;

  Color get _statusColor {
    if (widget.slot.isAvailable) return const Color(0xFFE8F0FE);
    if (widget.slot.isPending) return const Color(0xFFFFF3E0);
    return const Color(0xFFE8F5E9);
  }

  Color get _statusTextColor {
    if (widget.slot.isAvailable) return const Color(0xFF1976D2);
    if (widget.slot.isPending) return const Color(0xFFF57C00);
    return const Color(0xFF2E7D32);
  }

  String get _statusText {
    if (widget.slot.isAvailable) return 'Trống';
    if (widget.slot.isPending) return 'Chờ duyệt';
    return 'Đã đặt';
  }

  IconData get _statusIcon {
    if (widget.slot.isAvailable) return Icons.access_time;
    if (widget.slot.isPending) return Icons.hourglass_empty;
    return Icons.check_circle;
  }

  Future<void> _handleDecision(bool approve) async {
    if (!_canManage || _isProcessing) return;
    setState(() => _isProcessing = true);
    final viewModel = context.read<ScheduleViewModel>();
    final success = approve
        ? await viewModel.approveAppointment(appointmentId: widget.slot.id)
        : await viewModel.rejectAppointment(appointmentId: widget.slot.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve ? 'Đã duyệt lịch khám' : 'Đã từ chối lịch khám',
          ),
          backgroundColor: approve ? Colors.green.shade600 : Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Không thể xử lý yêu cầu này',
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    final patientName = slot.patientName?.trim();
    final patientPhone = slot.patientPhone?.trim();
    final notes = slot.notes?.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: widget.onTap,
        child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time and Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${slot.slotStartTime} - ${slot.slotEndTime}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon,
                          size: 14,
                          color: _statusTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Content
              if (slot.isAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nhấn để tạo lịch khám mới',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _InfoTile(
                  icon: Icons.person_outline,
                  label: 'Bệnh nhân',
                  value: patientName ?? 'Chưa có',
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Điện thoại',
                  value: patientPhone ?? 'Chưa có',
                ),
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.description_outlined,
                    label: 'Ghi chú',
                    value: notes,
                    maxLines: 2,
                  ),
                ],
              ],

              // Actions
              if (_canManage) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing ? null : () => _handleDecision(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Từ chối'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : () => _handleDecision(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text('Duyệt'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int? maxLines;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A2C3E),
                ),
                maxLines: maxLines ?? 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AppointmentDetailDialog extends StatefulWidget {
  final AppointmentSlotModel slot;
  final DateTime date;

  const AppointmentDetailDialog({
    super.key,
    required this.slot,
    required this.date,
  });

  @override
  State<AppointmentDetailDialog> createState() =>
      _AppointmentDetailDialogState();
}

class _AppointmentDetailDialogState extends State<AppointmentDetailDialog> {
  bool _isProcessing = false;

  bool get _canManage => widget.slot.isPending && widget.slot.id != 0;

  Future<void> _handleDecision(bool approve) async {
    if (!_canManage || _isProcessing) return;
    setState(() => _isProcessing = true);
    final viewModel = context.read<ScheduleViewModel>();
    final success = approve
        ? await viewModel.approveAppointment(appointmentId: widget.slot.id)
        : await viewModel.rejectAppointment(appointmentId: widget.slot.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve ? 'Đã duyệt lịch khám' : 'Đã từ chối lịch khám',
          ),
          backgroundColor: approve ? Colors.green.shade600 : Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Không thể xử lý yêu cầu này',
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const weekdayLabel = {
      DateTime.monday: 'Thứ 2',
      DateTime.tuesday: 'Thứ 3',
      DateTime.wednesday: 'Thứ 4',
      DateTime.thursday: 'Thứ 5',
      DateTime.friday: 'Thứ 6',
      DateTime.saturday: 'Thứ 7',
      DateTime.sunday: 'Chủ nhật',
    };
    final dateDisplay =
        '${weekdayLabel[widget.date.weekday] ?? ''}, ${DateFormat('dd/MM/yyyy').format(widget.date)}';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết lịch khám',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2C3E),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade500),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Text(
                    dateDisplay,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _DetailItem(
                    label: 'Khung giờ',
                    value: '${widget.slot.slotStartTime} - ${widget.slot.slotEndTime}',
                    icon: Icons.schedule,
                  ),
                  const SizedBox(height: 16),
                  _DetailItem(
                    label: 'Trạng thái',
                    value: widget.slot.status,
                    icon: Icons.info_outline,
                    valueColor: widget.slot.isPending
                        ? Colors.orange.shade600
                        : Colors.green.shade600,
                  ),
                  const SizedBox(height: 16),
                  _DetailItem(
                    label: 'Bệnh nhân',
                    value: widget.slot.patientName ?? 'Chưa có',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _DetailItem(
                    label: 'Số điện thoại',
                    value: widget.slot.patientPhone ?? 'Chưa có',
                    icon: Icons.phone_outlined,
                  ),
                  if ((widget.slot.notes ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _DetailItem(
                      label: 'Ghi chú',
                      value: widget.slot.notes ?? '',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Actions
            if (_canManage)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing ? null : () => _handleDecision(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Từ chối'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : () => _handleDecision(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text('Chấp thuận'),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Đóng'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final int? maxLines;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? const Color(0xFF1A2C3E),
                ),
                maxLines: maxLines ?? 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ManualAppointmentSheet extends StatefulWidget {
  final DateTime date;
  final List<AppointmentSlotModel> slots;
  final String doctorId;
  final AppointmentSlotModel? initialSlot;
  final String? initialPatientName;
  final String? initialPatientPhone;
  final bool lockPatientInfo;
  final bool enableAutoApproveToggle;
  final bool autoApproveDefault;

  const ManualAppointmentSheet({
    super.key,
    required this.date,
    required this.slots,
    required this.doctorId,
    this.initialSlot,
    this.initialPatientName,
    this.initialPatientPhone,
    this.lockPatientInfo = false,
    this.enableAutoApproveToggle = true,
    this.autoApproveDefault = true,
  });

  @override
  State<ManualAppointmentSheet> createState() => _ManualAppointmentSheetState();
}

class _ManualAppointmentSheetState extends State<ManualAppointmentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _noteController;
  int? _selectedSlot;
  late bool _autoApprove;
  bool _isSubmitting = false;

  List<AppointmentSlotModel> get _slotOptions {
    final selected = _selectedSlot;
    return widget.slots
        .where(
          (slot) =>
      slot.isAvailable ||
          (selected != null && slot.slotNumber == selected),
    )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialPatientName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialPatientPhone ?? '',
    );
    _noteController = TextEditingController();
    _autoApprove = widget.autoApproveDefault;
    if (widget.initialSlot != null) {
      _selectedSlot = widget.initialSlot!.slotNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final slotNumber = _selectedSlot;
    if (slotNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một khung giờ.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final scheduleVM = context.read<ScheduleViewModel>();
    final appointmentDate = DateFormat('yyyy-MM-dd').format(widget.date);

    final createdSlot = await scheduleVM.requestAppointment(
      doctorId: widget.doctorId,
      appointmentDate: appointmentDate,
      slotNumber: slotNumber,
      patientName: _nameController.text.trim(),
      patientPhone: _phoneController.text.trim(),
      notes: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (!mounted) return;

    if (createdSlot == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            scheduleVM.errorMessage ?? 'Không thể tạo lịch khám mới',
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_autoApprove && createdSlot.id != 0) {
      await scheduleVM.approveAppointment(appointmentId: createdSlot.id);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _autoApprove
              ? 'Đã tạo và xác nhận lịch mới'
              : 'Đã tạo yêu cầu lịch khám',
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(widget.date);
    final slots = _slotOptions;
    final hasSlotOptions = slots.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tạo lịch thủ công',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2C3E),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade500),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      dateLabel,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Form Fields
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (hasSlotOptions)
                      DropdownButtonFormField<int>(
                        value: _selectedSlot,
                        decoration: InputDecoration(
                          labelText: 'Khung giờ',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
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
                        items: slots
                            .map(
                              (slot) => DropdownMenuItem<int>(
                            value: slot.slotNumber,
                            child: Text(
                              'Slot ${slot.slotNumber} • ${slot.slotStartTime}-${slot.slotEndTime}',
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: widget.initialSlot != null
                            ? null
                            : (value) => setState(() => _selectedSlot = value),
                        validator: (value) =>
                        value == null ? 'Vui lòng chọn khung giờ' : null,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade400),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Không còn slot trống trong ngày này',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      readOnly: widget.lockPatientInfo,
                      enableInteractiveSelection: !widget.lockPatientInfo,
                      decoration: InputDecoration(
                        labelText: 'Tên bệnh nhân',
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
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
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Nhập tên bệnh nhân'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      readOnly: widget.lockPatientInfo,
                      enableInteractiveSelection: !widget.lockPatientInfo,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
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
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Nhập số điện thoại'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú (tuỳ chọn)',
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
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
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    if (widget.enableAutoApproveToggle) ...[
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Tự động duyệt lịch sau khi tạo',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: _autoApprove,
                        onChanged: (value) => setState(() => _autoApprove = value),
                        activeColor: AppTheme.primaryColor,
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Yêu cầu sẽ được gửi ở trạng thái chờ duyệt',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting || !hasSlotOptions
                            ? null
                            : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text(
                          'Lưu lịch mới',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}