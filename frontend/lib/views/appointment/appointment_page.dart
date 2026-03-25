import 'package:flutter/material.dart';
import 'package:frontend/data/models/appointment/appointment_detail_model.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/viewmodels/appointment_list_viewmodel.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  static const List<_AppointmentFilter> _filters = [
    _AppointmentFilter(key: 'ALL', label: 'Tất cả', status: null),
    _AppointmentFilter(key: 'PENDING', label: 'Chờ duyệt', status: 'PENDING'),
    _AppointmentFilter(key: 'BOOKED', label: 'Đã xác nhận', status: 'BOOKED'),
    _AppointmentFilter(
      key: 'REJECTED',
      label: 'Bị từ chối',
      status: 'REJECTED',
    ),
    _AppointmentFilter(key: 'CANCELLED', label: 'Đã hủy', status: 'CANCELLED'),
  ];

  String _activeFilterKey = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentListViewModel>().loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppointmentListViewModel>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterRow(vm),
            Expanded(child: _buildContent(vm)),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'Lịch khám của tôi',
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppTheme.primaryColor,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFilterRow(AppointmentListViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters
              .map(
                (filter) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(filter.label),
                    selected: _activeFilterKey == filter.key,
                    onSelected: (_) => _handleFilterTap(filter),
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: _activeFilterKey == filter.key
                          ? Colors.white
                          : AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppTheme.primaryLight,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildContent(AppointmentListViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null) {
      return _buildErrorState(vm);
    }
    if (vm.appointments.isEmpty) {
      return _buildEmptyState();
    }
    return _buildAppointmentList(vm.appointments);
  }

  Widget _buildErrorState(AppointmentListViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sentiment_dissatisfied,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          Text(
            vm.errorMessage ?? 'Không thể tải lịch khám.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _handleFilterTap(
              _filters.firstWhere((filter) => filter.key == _activeFilterKey),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: AppTheme.captionTextColor,
          ),
          SizedBox(height: 16),
          Text(
            'Bạn chưa có lịch khám nào với bộ lọc hiện tại. Hãy bắt đầu đặt lịch để theo dõi dễ dàng hơn.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.captionTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<AppointmentDetailModel> data) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final appointment = data[index];
        return _AppointmentCard(
          appointment: appointment,
          onViewDetail: () => _showAppointmentDetail(appointment),
        );
      },
    );
  }

  void _handleFilterTap(_AppointmentFilter filter) {
    setState(() => _activeFilterKey = filter.key);
    context.read<AppointmentListViewModel>().loadAppointments(
      status: filter.status,
    );
  }

  void _showAppointmentDetail(AppointmentDetailModel appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final dateLabel = DateFormat(
          'dd/MM/yyyy',
        ).format(appointment.appointmentDate);
        final timeLabel =
            '${appointment.slotStartTime} - ${appointment.slotEndTime}';
        final doctorName = (appointment.doctor?.fullName ?? '').trim().isEmpty
            ? 'Bác sĩ sẽ cập nhật'
            : appointment.doctor!.fullName;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    'Chi tiết lịch khám',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _infoRow('Bác sĩ', doctorName),
              _infoRow('Thời gian', '$dateLabel • $timeLabel'),
              _infoRow('Trạng thái', _statusLabel(appointment.status)),
              if ((appointment.patientName ?? '').trim().isNotEmpty)
                _infoRow('Bệnh nhân', appointment.patientName!.trim()),
              if ((appointment.patientPhone ?? '').trim().isNotEmpty)
                _infoRow('SĐT liên hệ', appointment.patientPhone!.trim()),
              if ((appointment.notes ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Ghi chú',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  appointment.notes!.trim(),
                  style: const TextStyle(color: AppTheme.bodyTextColor),
                ),
              ],
              const SizedBox(height: 12),
              if ((appointment.decisionReason ?? '').trim().isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusColor(appointment.status).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.decisionReason!.trim(),
                    style: TextStyle(
                      color: _statusColor(appointment.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.captionTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.bodyTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch ((status).toUpperCase()) {
      case 'PENDING':
        return 'Chờ bác sĩ duyệt';
      case 'BOOKED':
        return 'Đã xác nhận';
      case 'REJECTED':
        return 'Bị từ chối';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return 'Đang cập nhật';
    }
  }

  Color _statusColor(String status) {
    switch ((status).toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFFB8C00);
      case 'BOOKED':
        return const Color(0xFF2E7D32);
      case 'REJECTED':
        return const Color(0xFFD32F2F);
      case 'CANCELLED':
        return const Color(0xFF6C757D);
      default:
        return AppTheme.primaryColor;
    }
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentDetailModel appointment;
  final VoidCallback onViewDetail;

  const _AppointmentCard({
    required this.appointment,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat(
      'dd/MM/yyyy',
    ).format(appointment.appointmentDate);
    final timeLabel =
        '${appointment.slotStartTime} - ${appointment.slotEndTime}';
    final doctorName = (appointment.doctor?.fullName ?? '').trim().isEmpty
        ? 'Bác sĩ sẽ cập nhật'
        : appointment.doctor!.fullName;
    final statusColor = _statusColor(appointment.status);
    final statusLabel = _statusLabel(appointment.status);
    final avatarUrl = (appointment.doctor?.avatarUrl ?? '').trim();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryLight,
                backgroundImage: avatarUrl.isEmpty
                    ? null
                    : NetworkImage(avatarUrl),
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.person, color: AppTheme.primaryColor)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.bodyTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _infoChip(Icons.calendar_today, dateLabel),
              _infoChip(Icons.access_time, timeLabel),
              if ((appointment.patientName ?? '').trim().isNotEmpty)
                _infoChip(
                  Icons.person_outline,
                  appointment.patientName!.trim(),
                ),
            ],
          ),
          if ((appointment.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              appointment.notes!.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.captionTextColor),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewDetail,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Xem chi tiết'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch ((status).toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFFB8C00);
      case 'BOOKED':
        return const Color(0xFF2E7D32);
      case 'REJECTED':
        return const Color(0xFFD32F2F);
      case 'CANCELLED':
        return const Color(0xFF6C757D);
      default:
        return AppTheme.primaryColor;
    }
  }

  String _statusLabel(String status) {
    switch ((status).toUpperCase()) {
      case 'PENDING':
        return 'Chờ bác sĩ duyệt';
      case 'BOOKED':
        return 'Đã xác nhận';
      case 'REJECTED':
        return 'Bị từ chối';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return 'Đang cập nhật';
    }
  }
}

class _AppointmentFilter {
  final String key;
  final String label;
  final String? status;

  const _AppointmentFilter({
    required this.key,
    required this.label,
    this.status,
  });
}
