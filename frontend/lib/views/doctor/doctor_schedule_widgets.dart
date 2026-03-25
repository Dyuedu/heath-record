// doctor_schedule_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:frontend/data/models/doctor/appointment_slot_model.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/viewmodels/schedule_viewmodel.dart';

// MARK: - Appointment Slot Widget
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

  bool get _canApprove =>
      widget.showActions && widget.slot.isPending && widget.slot.id != 0;

  bool get _canReject =>
      widget.showActions &&
          (widget.slot.isPending || widget.slot.isBooked) &&
          widget.slot.id != 0;

  _SlotStatus get _slotStatus {
    if (widget.slot.isAvailable) return _SlotStatus.available;
    if (widget.slot.isPending) return _SlotStatus.pending;
    return _SlotStatus.booked;
  }

  Future<String?> _showRejectionReasonDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _RejectionReasonDialog(),
    );
  }

  Future<void> _handleDecision(bool approve) async {
    if ((approve && !_canApprove) || (!approve && !_canReject) || _isProcessing) {
      return;
    }

    String? rejectionReason;
    if (!approve) {
      rejectionReason = await _showRejectionReasonDialog(context);
      if (rejectionReason == null || rejectionReason.isEmpty) {
        return;
      }
    }

    setState(() => _isProcessing = true);
    final viewModel = context.read<ScheduleViewModel>();

    final success = approve
        ? await viewModel.approveAppointment(appointmentId: widget.slot.id)
        : await viewModel.rejectAppointment(
      appointmentId: widget.slot.id,
      reason: rejectionReason!,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      _showSnackBar(
        approve ? 'Đã duyệt lịch khám' : 'Đã từ chối lịch khám',
        approve ? Colors.green.shade600 : Colors.red.shade400,
      );
    } else {
      _showSnackBar(
        viewModel.errorMessage ?? 'Không thể xử lý yêu cầu này',
        Colors.red.shade400,
      );
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            mainAxisSize: MainAxisSize.min,
            children: [
              _SlotHeader(
                startTime: widget.slot.slotStartTime,
                endTime: widget.slot.slotEndTime,
                status: _slotStatus,
              ),
              const SizedBox(height: 16),
              _SlotContent(
                isAvailable: widget.slot.isAvailable,
                patientName: widget.slot.patientName,
                patientPhone: widget.slot.patientPhone,
                notes: widget.slot.notes,
              ),
              if (_canApprove || _canReject) ...[
                const SizedBox(height: 20),
                _SlotActions(
                  canApprove: _canApprove,
                  canReject: _canReject,
                  isProcessing: _isProcessing,
                  onApprove: () => _handleDecision(true),
                  onReject: () => _handleDecision(false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// MARK: - Slot Status Helper
enum _SlotStatus { available, pending, booked }

extension _SlotStatusExtension on _SlotStatus {
  Color get backgroundColor {
    switch (this) {
      case _SlotStatus.available:
        return const Color(0xFFE8F0FE);
      case _SlotStatus.pending:
        return const Color(0xFFFFF3E0);
      case _SlotStatus.booked:
        return const Color(0xFFE8F5E9);
    }
  }

  Color get textColor {
    switch (this) {
      case _SlotStatus.available:
        return const Color(0xFF1976D2);
      case _SlotStatus.pending:
        return const Color(0xFFF57C00);
      case _SlotStatus.booked:
        return const Color(0xFF2E7D32);
    }
  }

  IconData get icon {
    switch (this) {
      case _SlotStatus.available:
        return Icons.access_time;
      case _SlotStatus.pending:
        return Icons.hourglass_empty;
      case _SlotStatus.booked:
        return Icons.check_circle;
    }
  }

  String get text {
    switch (this) {
      case _SlotStatus.available:
        return 'Trống';
      case _SlotStatus.pending:
        return 'Chờ duyệt';
      case _SlotStatus.booked:
        return 'Đã đặt';
    }
  }
}

// MARK: - Slot Header Component
class _SlotHeader extends StatelessWidget {
  final String startTime;
  final String endTime;
  final _SlotStatus status;

  const _SlotHeader({
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 14, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Text(
                '$startTime - $endTime',
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: status.backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(status.icon, size: 14, color: status.textColor),
              const SizedBox(width: 4),
              Text(
                status.text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: status.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// MARK: - Slot Content Component
class _SlotContent extends StatelessWidget {
  final bool isAvailable;
  final String? patientName;
  final String? patientPhone;
  final String? notes;

  const _SlotContent({
    required this.isAvailable,
    this.patientName,
    this.patientPhone,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    if (isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 16,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Nhấn để tạo lịch khám mới',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _InfoTile(
          icon: Icons.person_outline,
          label: 'Bệnh nhân',
          value: patientName?.trim() ?? 'Chưa có',
        ),
        const SizedBox(height: 12),
        _InfoTile(
          icon: Icons.phone_outlined,
          label: 'Điện thoại',
          value: patientPhone?.trim() ?? 'Chưa có',
        ),
        if (notes != null && notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.description_outlined,
            label: 'Ghi chú',
            value: notes!.trim(),
            maxLines: 2,
          ),
        ],
      ],
    );
  }
}

// MARK: - Slot Actions Component
class _SlotActions extends StatelessWidget {
  final bool canApprove;
  final bool canReject;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _SlotActions({
    required this.canApprove,
    required this.canReject,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (canReject)
          Expanded(
            child: OutlinedButton(
              onPressed: isProcessing ? null : onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isProcessing
                  ? const _ProcessingIndicator(size: 18)
                  : Text(canApprove ? 'Từ chối' : 'Hủy lịch'),
            ),
          ),
        if (canApprove && canReject) const SizedBox(width: 12),
        if (canApprove)
          Expanded(
            child: ElevatedButton(
              onPressed: isProcessing ? null : onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isProcessing
                  ? const _ProcessingIndicator(
                size: 18,
                color: Colors.white,
              )
                  : const Text('Duyệt'),
            ),
          ),
      ],
    );
  }
}

// MARK: - Info Tile Component
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

// MARK: - Rejection Reason Dialog
class _RejectionReasonDialog extends StatefulWidget {
  const _RejectionReasonDialog();

  @override
  State<_RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<_RejectionReasonDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Vui lòng nhập lý do');
      return;
    }
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nhập lý do'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Nhập lý do từ chối hoặc hủy lịch',
          errorText: _errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}

// MARK: - Appointment Detail Dialog
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
        : await viewModel.rejectAppointment(
      appointmentId: widget.slot.id,
      reason: '',
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      if (mounted) Navigator.pop(context);
      _showSnackBar(
        approve ? 'Đã duyệt lịch khám' : 'Đã từ chối lịch khám',
        approve ? Colors.green.shade600 : Colors.red.shade400,
      );
    } else {
      _showSnackBar(
        viewModel.errorMessage ?? 'Không thể xử lý yêu cầu này',
        Colors.red.shade400,
      );
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _BottomSheetHandle(),
              _DetailHeader(
                date: widget.date,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              _DetailContent(slot: widget.slot),
              const SizedBox(height: 24),
              _DetailActions(
                canManage: _canManage,
                isProcessing: _isProcessing,
                onApprove: () => _handleDecision(true),
                onReject: () => _handleDecision(false),
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// MARK: - Detail Header Component
class _DetailHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback onClose;

  const _DetailHeader({
    required this.date,
    required this.onClose,
  });

  String _getFormattedDate() {
    const weekdayLabels = {
      DateTime.monday: 'Thứ 2',
      DateTime.tuesday: 'Thứ 3',
      DateTime.wednesday: 'Thứ 4',
      DateTime.thursday: 'Thứ 5',
      DateTime.friday: 'Thứ 6',
      DateTime.saturday: 'Thứ 7',
      DateTime.sunday: 'Chủ nhật',
    };
    final weekday = weekdayLabels[date.weekday] ?? '';
    return '$weekday, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            onPressed: onClose,
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}

// MARK: - Detail Content Component
class _DetailContent extends StatelessWidget {
  final AppointmentSlotModel slot;

  const _DetailContent({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _DetailItem(
            label: 'Khung giờ',
            value: '${slot.slotStartTime} - ${slot.slotEndTime}',
            icon: Icons.schedule,
          ),
          const SizedBox(height: 16),
          _DetailItem(
            label: 'Trạng thái',
            value: _getStatusText(),
            icon: Icons.info_outline,
            valueColor: slot.isPending
                ? Colors.orange.shade600
                : Colors.green.shade600,
          ),
          const SizedBox(height: 16),
          _DetailItem(
            label: 'Bệnh nhân',
            value: slot.patientName?.trim() ?? 'Chưa có',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _DetailItem(
            label: 'Số điện thoại',
            value: slot.patientPhone?.trim() ?? 'Chưa có',
            icon: Icons.phone_outlined,
          ),
          if (_hasNotes) ...[
            const SizedBox(height: 16),
            _DetailItem(
              label: 'Ghi chú',
              value: slot.notes!.trim(),
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText() {
    if (slot.isPending) return 'Chờ duyệt';
    if (slot.isBooked) return 'Đã đặt';
    return 'Trống';
  }

  bool get _hasNotes =>
      slot.notes != null && slot.notes!.trim().isNotEmpty;
}

// MARK: - Detail Actions Component
class _DetailActions extends StatelessWidget {
  final bool canManage;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onClose;

  const _DetailActions({
    required this.canManage,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (canManage) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isProcessing ? null : onReject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isProcessing
                    ? const _ProcessingIndicator(size: 20)
                    : const Text('Từ chối'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isProcessing ? null : onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isProcessing
                    ? const _ProcessingIndicator(
                  size: 20,
                  color: Colors.white,
                )
                    : const Text('Chấp thuận'),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: onClose,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Đóng'),
        ),
      ),
    );
  }
}

// MARK: - Detail Item Component
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

// MARK: - Manual Appointment Sheet
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

  List<AppointmentSlotModel> get _availableSlots {
    final selected = _selectedSlot;
    return widget.slots
        .where(
          (slot) =>
      slot.isAvailable ||
          (selected != null && slot.slotNumber == selected),
    )
        .toList();
  }

  bool get _hasAvailableSlots => _availableSlots.isNotEmpty;

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
      _showSnackBar('Vui lòng chọn một khung giờ.', Colors.orange.shade400);
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
      _showSnackBar(
        scheduleVM.errorMessage ?? 'Không thể tạo lịch khám mới',
        Colors.red.shade400,
      );
      return;
    }

    if (_autoApprove && createdSlot.id != 0) {
      await scheduleVM.approveAppointment(appointmentId: createdSlot.id);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (mounted) Navigator.pop(context);
    _showSnackBar(
      _autoApprove
          ? 'Đã tạo và xác nhận lịch mới'
          : 'Đã tạo yêu cầu lịch khám',
      Colors.green.shade600,
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _BottomSheetHandle(),
                _ManualAppointmentHeader(
                  date: widget.date,
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
                _ManualAppointmentForm(
                  availableSlots: _availableSlots,
                  hasAvailableSlots: _hasAvailableSlots,
                  selectedSlot: _selectedSlot,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  noteController: _noteController,
                  lockPatientInfo: widget.lockPatientInfo,
                  enableAutoApproveToggle: widget.enableAutoApproveToggle,
                  autoApprove: _autoApprove,
                  isSubmitting: _isSubmitting,
                  onSlotChanged: (value) => setState(() => _selectedSlot = value),
                  onAutoApproveChanged: (value) => setState(() => _autoApprove = value),
                  onSubmit: _submit,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: - Manual Appointment Header
class _ManualAppointmentHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback onClose;

  const _ManualAppointmentHeader({
    required this.date,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            onPressed: onClose,
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}

// MARK: - Manual Appointment Form
class _ManualAppointmentForm extends StatelessWidget {
  final List<AppointmentSlotModel> availableSlots;
  final bool hasAvailableSlots;
  final int? selectedSlot;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController noteController;
  final bool lockPatientInfo;
  final bool enableAutoApproveToggle;
  final bool autoApprove;
  final bool isSubmitting;
  final Function(int?) onSlotChanged;
  final Function(bool) onAutoApproveChanged;
  final VoidCallback onSubmit;

  const _ManualAppointmentForm({
    required this.availableSlots,
    required this.hasAvailableSlots,
    required this.selectedSlot,
    required this.nameController,
    required this.phoneController,
    required this.noteController,
    required this.lockPatientInfo,
    required this.enableAutoApproveToggle,
    required this.autoApprove,
    required this.isSubmitting,
    required this.onSlotChanged,
    required this.onAutoApproveChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (hasAvailableSlots)
            _SlotDropdown(
              slots: availableSlots,
              selectedSlot: selectedSlot,
              isReadOnly: false,
              onChanged: onSlotChanged,
            )
          else
            _NoSlotWarning(),
          const SizedBox(height: 20),
          _TextField(
            controller: nameController,
            label: 'Tên bệnh nhân',
            readOnly: lockPatientInfo,
            validator: (value) =>
            (value == null || value.trim().isEmpty)
                ? 'Nhập tên bệnh nhân'
                : null,
          ),
          const SizedBox(height: 16),
          _TextField(
            controller: phoneController,
            label: 'Số điện thoại',
            readOnly: lockPatientInfo,
            keyboardType: TextInputType.phone,
            validator: (value) =>
            (value == null || value.trim().isEmpty)
                ? 'Nhập số điện thoại'
                : null,
          ),
          const SizedBox(height: 16),
          _TextField(
            controller: noteController,
            label: 'Ghi chú (tuỳ chọn)',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          if (enableAutoApproveToggle)
            _AutoApproveToggle(
              value: autoApprove,
              onChanged: onAutoApproveChanged,
            )
          else
            _InfoMessage(
              message: 'Yêu cầu sẽ được gửi ở trạng thái chờ duyệt',
            ),
          const SizedBox(height: 24),
          _SubmitButton(
            isSubmitting: isSubmitting,
            isEnabled: hasAvailableSlots,
            onSubmit: onSubmit,
          ),
        ],
      ),
    );
  }
}

// MARK: - Slot Dropdown Component
class _SlotDropdown extends StatelessWidget {
  final List<AppointmentSlotModel> slots;
  final int? selectedSlot;
  final bool isReadOnly;
  final Function(int?) onChanged;

  const _SlotDropdown({
    required this.slots,
    required this.selectedSlot,
    required this.isReadOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: selectedSlot,
      decoration: _buildInputDecoration('Khung giờ'),
      items: slots.map((slot) {
        return DropdownMenuItem<int>(
          value: slot.slotNumber,
          child: Text(
            'Slot ${slot.slotNumber} • ${slot.slotStartTime}-${slot.slotEndTime}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: isReadOnly ? null : onChanged,
      validator: (value) => value == null ? 'Vui lòng chọn khung giờ' : null,
      isExpanded: true,
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// MARK: - No Slot Warning
class _NoSlotWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange.shade400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Không còn slot trống trong ngày này',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - Text Field Component
class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextField({
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}

// MARK: - Auto Approve Toggle
class _AutoApproveToggle extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const _AutoApproveToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Tự động duyệt lịch sau khi tạo',
        style: TextStyle(fontSize: 14),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }
}

// MARK: - Info Message
class _InfoMessage extends StatelessWidget {
  final String message;

  const _InfoMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - Submit Button
class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final bool isEnabled;
  final VoidCallback onSubmit;

  const _SubmitButton({
    required this.isSubmitting,
    required this.isEnabled,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting || !isEnabled ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isSubmitting
            ? const _ProcessingIndicator(
          size: 20,
          color: Colors.white,
        )
            : const Text(
          'Lưu lịch mới',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// MARK: - Bottom Sheet Handle
class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// MARK: - Processing Indicator
class _ProcessingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const _ProcessingIndicator({
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: color != null
            ? AlwaysStoppedAnimation<Color>(color!)
            : null,
      ),
    );
  }
}