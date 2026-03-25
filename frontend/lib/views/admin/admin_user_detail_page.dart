import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/viewmodels/admin_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminUserDetailPage extends StatefulWidget {
  final UserProfileModel user;

  const AdminUserDetailPage({super.key, required this.user});

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  late UserProfileModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  bool get _isDoctor => _currentUser.role.toLowerCase() == 'doctor';

  String _displayRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'doctor':
        return 'Bác sĩ';
      case 'user':
        return 'Bệnh nhân';
      default:
        return role;
    }
  }

  String _displayStatus(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Hoạt động';
      case 'LOCKED':
        return 'Khóa';
      case 'PENDING':
        return 'Chờ duyệt';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFF10B981);
      case 'LOCKED':
        return const Color(0xFFEF4444);
      case 'PENDING':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFFECFDF5);
      case 'LOCKED':
        return const Color(0xFFFEF2F2);
      case 'PENDING':
        return const Color(0xFFFFF3E0);
      default:
        return Colors.grey.shade100;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Không rõ';
    try {
      final DateTime dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (e) {
      return dateStr.split('T').first;
    }
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
          _currentUser.fullName.isNotEmpty ? _currentUser.fullName : 'Chi tiết',
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
                color: _statusBgColor(_currentUser.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _displayStatus(_currentUser.status),
                style: TextStyle(
                  color: _statusColor(_currentUser.status),
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
            // ─── Profile card ───
            _buildProfileCard(),
            const SizedBox(height: 24),

            // ─── Status control ───
            if (_currentUser.status != 'PENDING') ...[
              _buildStatusControl(),
              const SizedBox(height: 24),
            ],

            // ─── Documents section (only for doctor) ───
            if (_isDoctor) ...[
              _buildDocumentsSection(),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════
  // Profile Card
  // ═════════════════════════════════════
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _currentUser.avatarUrl.isNotEmpty
                ? NetworkImage(_currentUser.avatarUrl)
                : null,
            child: _currentUser.avatarUrl.isEmpty
                ? Icon(Icons.person, size: 42, color: Colors.grey.shade400)
                : null,
          ),
          const SizedBox(height: 14),

          // Full name
          Text(
            _currentUser.fullName.isNotEmpty
                ? _currentUser.fullName
                : 'Chưa có tên',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2A44),
            ),
          ),
          const SizedBox(height: 12),

          // Info rows
          _profileInfoRow(Icons.email_outlined, _currentUser.email),
          if (_currentUser.phoneNumber.isNotEmpty)
            _profileInfoRow(Icons.phone_outlined, _currentUser.phoneNumber),
          _profileInfoRow(
            Icons.medical_services_outlined,
            _displayRole(_currentUser.role),
          ),
          if (_currentUser.gender.isNotEmpty)
            _profileInfoRow(Icons.wc_outlined, _currentUser.gender),
          if (_currentUser.dateOfBirth.isNotEmpty)
            _profileInfoRow(Icons.cake_outlined, _currentUser.dateOfBirth),
          if (_currentUser.address.isNotEmpty)
            _profileInfoRow(Icons.location_on_outlined, _currentUser.address),
          if (_currentUser.createdAt != null)
            _profileInfoRow(
              Icons.calendar_today_outlined,
              'Đăng ký ngày: ${_formatDate(_currentUser.createdAt)}',
            ),
        ],
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════
  // Status Control
  // ═════════════════════════════════════
  Widget _buildStatusControl() {
    final isActive = _currentUser.status == 'ACTIVE';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _statusColor(_currentUser.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? Icons.check_circle_outline : Icons.lock_outline,
              color: _statusColor(_currentUser.status),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trạng thái tài khoản',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _displayStatus(_currentUser.status),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(_currentUser.status),
                  ),
                ),
              ],
            ),
          ),
          // Toggle buttons
          Row(
            children: [
              GestureDetector(
                onTap: () => _changeStatus('ACTIVE'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFF10B981).withOpacity(0.08),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(10),
                    ),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Hoạt động',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF10B981),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _changeStatus('LOCKED'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: !isActive
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFEF4444).withOpacity(0.08),
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(10),
                    ),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Khóa',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: !isActive ? Colors.white : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════
  // Documents Section (for doctors)
  // ═════════════════════════════════════
  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(Icons.attach_file_rounded, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'HỒ SƠ ĐÍNH KÈM',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Document thumbnails grid
        _buildDocumentGrid(),
      ],
    );
  }

  Widget _buildDocumentGrid() {
    final docs = <Map<String, String>>[];

    if (_currentUser.cccdFrontUrl != null && _currentUser.cccdFrontUrl!.isNotEmpty) {
      docs.add({'url': _currentUser.cccdFrontUrl!, 'title': 'CCCD Mặt trước', 'sub': 'ID CARD'});
    }
    if (_currentUser.cccdBackUrl != null && _currentUser.cccdBackUrl!.isNotEmpty) {
      docs.add({'url': _currentUser.cccdBackUrl!, 'title': 'CCCD Mặt sau', 'sub': 'ID CARD'});
    }
    if (_currentUser.diplomaUrl != null && _currentUser.diplomaUrl!.isNotEmpty) {
      docs.add({'url': _currentUser.diplomaUrl!, 'title': 'Bằng cấp', 'sub': 'DIPLOMA'});
    }

    if (docs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(Icons.folder_off_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'Chưa có giấy tờ đính kèm',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Row(
      children: docs.map((doc) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: doc != docs.last ? 10 : 0,
            ),
            child: _buildDocumentThumbnail(
              doc['url']!,
              doc['title']!,
              doc['sub']!,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDocumentThumbnail(String url, String title, String subtitle) {
    return GestureDetector(
      onTap: () => _showFullImage(context, url, title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail image
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: CachedNetworkImage(
                imageUrl: url,
                width: double.infinity,
                height: 110,
                fit: BoxFit.cover,
                placeholder: (_, __) => Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 28, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Label
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2A44),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════
  // Actions
  // ═════════════════════════════════════
  Future<void> _changeStatus(String newStatus) async {
    if (_currentUser.status == newStatus) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF246BFF)),
      ),
    );

    final success = await context.read<AdminViewModel>().updateUserStatus(
      _currentUser.id,
      newStatus,
    );

    if (mounted) Navigator.pop(context);

    if (success && mounted) {
      setState(() {
        _currentUser = UserProfileModel(
          id: _currentUser.id,
          email: _currentUser.email,
          phoneNumber: _currentUser.phoneNumber,
          fullName: _currentUser.fullName,
          role: _currentUser.role,
          gender: _currentUser.gender,
          dateOfBirth: _currentUser.dateOfBirth,
          address: _currentUser.address,
          avatarUrl: _currentUser.avatarUrl,
          status: newStatus,
          cccdFrontUrl: _currentUser.cccdFrontUrl,
          cccdBackUrl: _currentUser.cccdBackUrl,
          diplomaUrl: _currentUser.diplomaUrl,
          createdAt: _currentUser.createdAt, 
          identityNumber: '',
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chuyển trạng thái sang ${_displayStatus(newStatus)}'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showFullImage(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 22),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: url,
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (_, __) => Container(
                  height: 300,
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF246BFF)),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 300,
                  color: Colors.white,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48),
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
