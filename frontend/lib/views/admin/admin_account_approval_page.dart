import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/viewmodels/admin_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminAccountApprovalPage extends StatefulWidget {
  final UserProfileModel user;

  const AdminAccountApprovalPage({super.key, required this.user});

  @override
  State<AdminAccountApprovalPage> createState() => _AdminAccountApprovalPageState();
}

class _AdminAccountApprovalPageState extends State<AdminAccountApprovalPage> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _rejectionController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _rejectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF1F2A44),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.user.fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2A44),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.user.status == 'PENDING'
                    ? const Color(0xFFFFF3E0)
                    : widget.user.status == 'ACTIVE'
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.user.status == 'PENDING'
                    ? 'Chờ duyệt'
                    : widget.user.status == 'ACTIVE'
                        ? 'Đã duyệt'
                        : 'Bị khóa',
                style: TextStyle(
                  color: widget.user.status == 'PENDING'
                      ? const Color(0xFFF59E0B)
                      : widget.user.status == 'ACTIVE'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            _buildProfileSection(),
            const SizedBox(height: 24),

            // Attached documents
            _buildSection(
              icon: Icons.attach_file_rounded,
              title: 'HỒ SƠ ĐÍNH KÈM',
              child: _buildDocuments(),
            ),
            const SizedBox(height: 24),

            // Internal notes
            _buildSection(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'GHI CHÚ NỘI BỘ',
              child: _buildNotesSection(),
            ),
            const SizedBox(height: 24),

            // Activity timeline
            _buildSection(
              icon: Icons.history_rounded,
              title: 'LỊCH SỬ HOẠT ĐỘNG',
              child: _buildTimeline(),
            ),
            const SizedBox(height: 24),

            // Rejection reason
            _buildRejectionSection(),
            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF246BFF).withOpacity(0.1),
            backgroundImage: widget.user.avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(widget.user.avatarUrl)
                : null,
            child: widget.user.avatarUrl.isEmpty
                ? Text(
                    widget.user.fullName.isNotEmpty ? widget.user.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF246BFF),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 14),

          // Name
          Text(
            widget.user.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2A44),
            ),
          ),
          const SizedBox(height: 10),

          // Info rows
          _infoRow(Icons.email_outlined, widget.user.email),
          const SizedBox(height: 6),
          _infoRow(Icons.medical_services_outlined, widget.user.role),
          const SizedBox(height: 6),
          _infoRow(Icons.calendar_today_outlined, 'Đăng ký ngày: ${widget.user.createdAt ?? "Không rõ"}'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF246BFF)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDocuments() {
    return Row(
      children: [
        Expanded(child: _documentCard('CCCD Mặt trước', 'ID CARD', widget.user.cccdFrontUrl)),
        const SizedBox(width: 10),
        Expanded(child: _documentCard('CCCD Mặt sau', 'ID CARD', widget.user.cccdBackUrl)),
        const SizedBox(width: 10),
        Expanded(child: _documentCard('Bằng Đại Học', 'DIPLOMA', widget.user.diplomaUrl)),
      ],
    );
  }

  Widget _documentCard(String label, String type, String? url) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url.isNotEmpty
          ? Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Container(
                  color: Colors.black.withOpacity(0.3),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'DIPLOMA' ? Icons.school_outlined : Icons.badge_outlined,
                  color: Colors.grey.shade400,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Text(
              'Chỉ quản trị viên mới có thể xem các ghi chú này.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
              decoration: InputDecoration(
                hintText: 'Nhập nhận xét về hồ sơ này...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.only(top: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _timelineItem(
            time: widget.user.createdAt ?? '',
            title: 'Tạo tài khoản đăng ký mới',
            actor: 'Thực hiện bởi: ${widget.user.fullName}',
            isFirst: true,
          ),
          _timelineItem(
            time: widget.user.createdAt ?? '',
            title: 'Hồ sơ đã tự động được gửi đi phê duyệt',
            actor: 'Thực hiện bởi: Hệ thống',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required String time,
    required String title,
    required String actor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line + dot
        SizedBox(
          width: 24,
          child: Column(
            children: [
              if (!isFirst)
                Container(width: 2, height: 8, color: Colors.grey.shade300),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isLast ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 40, color: Colors.grey.shade300),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2A44),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  actor,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red.shade400),
              const SizedBox(width: 8),
              Text(
                'LÝ DO TỪ CHỐI (NẾU CÓ)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _rejectionController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
            decoration: InputDecoration(
              hintText: 'Vui lòng nhập lý do nếu bạn quyết định từ chối hồ sơ này...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.user.status != 'PENDING') {
      return const SizedBox(); // Hide if already processed
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _handleReject(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Từ chối',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => _handleApprove(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Phê duyệt',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleApprove(BuildContext context) async {
    _showLoadingOverlay(context);
    final success = await context.read<AdminViewModel>().approveUser(widget.user.id);
    if (mounted) Navigator.pop(context); // close loader
    if (success && mounted) {
      context.read<AdminViewModel>().loadDashboardStats();
      Navigator.pop(context); // return to list
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    _showLoadingOverlay(context);
    final success = await context.read<AdminViewModel>().rejectUser(widget.user.id);
    if (mounted) Navigator.pop(context); // close loader
    if (success && mounted) {
      context.read<AdminViewModel>().loadDashboardStats();
      Navigator.pop(context); // return to list
    }
  }

  void _showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF246BFF)),
      ),
    );
  }
}
