import 'package:flutter/material.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:frontend/views/doctor/create_medical_record_page.dart';
import 'package:frontend/views/home/doctor_user_search_page.dart';
import 'package:frontend/viewmodels/notification_viewmodel.dart';
import 'package:frontend/views/home/notification_page.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userRole;
  bool _isRoleLoading = true;
  final TextEditingController _recordSearchController = TextEditingController();
  String _recordSearchQuery = '';

  static const List<_MockMedicalHistoryItem> _mockHistoryItems = [
    _MockMedicalHistoryItem(
      title: 'Khám tổng quát định kỳ',
      facility: 'Bệnh viện Gia Đình',
      date: '12/03/2026',
      status: 'Hoàn tất',
    ),
    _MockMedicalHistoryItem(
      title: 'Xét nghiệm đường huyết',
      facility: 'Phòng khám Minh Tâm',
      date: '03/03/2026',
      status: 'Đã trả kết quả',
    ),
    _MockMedicalHistoryItem(
      title: 'Tái khám tim mạch',
      facility: 'Bệnh viện Đa khoa Thành phố',
      date: '24/02/2026',
      status: 'Hoàn tất',
    ),
    _MockMedicalHistoryItem(
      title: 'Khám chuyên khoa hô hấp',
      facility: 'Phòng khám An Khang',
      date: '15/02/2026',
      status: 'Theo dõi thêm',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _resolveUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVM = context.read<ProfileViewModel>();
      if (!profileVM.isLoading) {
        profileVM.loadOverview();
      }
    });
  }

  @override
  void dispose() {
    _recordSearchController.dispose();
    super.dispose();
  }

  Future<void> _resolveUserRole() async {
    try {
      final storage = context.read<SecureStorageRepository>();
      final token = await storage.getToken();
      if (token != null && token.isNotEmpty) {
        final decoded = JwtDecoder.decode(token);
        if (mounted) {
          setState(() {
            _userRole = decoded['role']?.toString();
          });
          
          // Connect to real-time notification socket for all roles
          final userId = decoded['id']?.toString() ?? decoded['sub']?.toString();
          if (userId != null) {
            context.read<NotificationViewModel>().connect(userId);
          }
        }
      }
    } catch (error) {
      debugPrint('Không thể giải mã vai trò: $error');
    } finally {
      if (mounted) {
        setState(() => _isRoleLoading = false);
      }
    }
  }

  bool get _isDoctor => (_userRole?.toLowerCase() == 'role_doctor');

  List<_MockMedicalHistoryItem> get _filteredHistoryItems {
    final query = _recordSearchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _mockHistoryItems;
    }

    return _mockHistoryItems
        .where(
          (item) =>
              item.title.toLowerCase().contains(query) ||
              item.facility.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();
    final profile = profileVM.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Màu nền nhẹ nhàng hơn
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              _UserHeaderSection(
                profile: profile,
                isLoading: profileVM.isLoading,
                isDoctor: _isDoctor,
              ),
              const SizedBox(height: 30),

              // 2. Banner/Search Section (chỉ hiển thị với bác sĩ)
              if (!_isRoleLoading && _isDoctor) ...[
                const Text(
                  "Truy cập nhanh",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2A44),
                  ),
                ),
                const SizedBox(height: 15),
                _DoctorSearchInput(
                  isDoctor: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorUserSearchPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ] else
                const SizedBox(height: 20),

              if (!_isDoctor) ...[
                const Text(
                  "Tìm kiếm bệnh án",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2A44),
                  ),
                ),
                const SizedBox(height: 15),
                _MedicalRecordSearchInput(
                  controller: _recordSearchController,
                  onChanged: (value) {
                    setState(() {
                      _recordSearchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
              ],

              // 3. Featured Categories/Services
              const _SectionHeader(title: "Dịch vụ y tế", showViewAll: false),
              const SizedBox(height: 15),
              _QuickServicesGrid(isDoctor: _isDoctor),
              const SizedBox(height: 30),

              // 4. User medical history / doctor specific content
              if (!_isDoctor) ...[
                const _SectionHeader(title: "Lịch sử khám", showViewAll: false),
                const SizedBox(height: 15),
                _MockMedicalHistorySection(items: _filteredHistoryItems),
              ],

              const SizedBox(height: 100), // Padding cho BottomNav
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}

// --- Các thành phần Widget con ---

class _UserHeaderSection extends StatelessWidget {
  final UserProfileModel? profile;
  final bool isLoading;
  final bool isDoctor;

  const _UserHeaderSection({required this.profile, required this.isLoading, this.isDoctor = false});

  @override
  Widget build(BuildContext context) {
    final fullName = _formatValue(profile?.fullName, fallback: 'Người dùng');
    final avatarUrl = (profile?.avatarUrl ?? '').trim();

    return Row(
      children: [
        _buildAvatar(avatarUrl),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLoading ? 'Đang tải...' : 'Chào ngày mới,',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            Text(
              fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2A44),
              ),
            ),
          ],
        ),
        const Spacer(),
        _notificationBadge(context, Icons.notifications_none_rounded),
      ],
    );
  }

  Widget _buildAvatar(String avatarUrl) {
    if (avatarUrl.isEmpty) {
      return const CircleAvatar(
        radius: 28,
        backgroundColor: Color(0xFF246BFF),
        child: Icon(Icons.person, color: Colors.white, size: 30),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.network(
          avatarUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, color: Color(0xFF246BFF), size: 30),
        ),
      ),
    );
  }

  Widget _notificationBadge(BuildContext context, IconData icon) {
    final unreadCount = context.watch<NotificationViewModel>().unreadCount;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationPage()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
            child: Icon(icon, color: const Color(0xFF1F2A44), size: 24),
          ),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatValue(String? value, {required String fallback}) {
    final trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
}

class _DoctorSearchInput extends StatelessWidget {
  final bool isDoctor;
  final VoidCallback onTap;

  const _DoctorSearchInput({required this.isDoctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDoctor ? onTap : null,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Color(0xFF246BFF),
              size: 28,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                isDoctor
                  ? "Tìm người dùng theo CCCD hoặc SĐT"
                    : "Tìm bác sĩ, bệnh viện...",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isDoctor)
              const SizedBox(width: 10),
            if (isDoctor)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF246BFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Bác sĩ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}

class _MedicalRecordSearchInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _MedicalRecordSearchInput({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF246BFF), size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: Color(0xFF1F2A44),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                fillColor: Colors.white,
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF246BFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Bệnh án',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showViewAll;

  const _SectionHeader({required this.title, this.showViewAll = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2A44),
          ),
        ),
        if (showViewAll)
          const Text(
            "Xem tất cả",
            style: TextStyle(
              color: Color(0xFF246BFF),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
      ],
    );
  }
}

class _QuickServicesGrid extends StatelessWidget {
  final bool isDoctor;

  const _QuickServicesGrid({this.isDoctor = false});

  @override
  Widget build(BuildContext context) {
    final services = <Map<String, dynamic>>[
      {
        'icon': Icons.folder_shared_rounded,
        'label': 'Hồ sơ',
        'color': const Color(0xFFFFF1E8),
        'onTap': () {},
      },
      {
        'icon': Icons.local_hospital_rounded,
        'label': 'Bệnh viện',
        'color': const Color(0xFFE8FFF1),
        'onTap': () {},
      },
      if (isDoctor)
        {
          'icon': Icons.add_circle_outline_rounded,
          'label': 'Hồ sơ mới',
          'color': const Color(0xFFFFE8E8),
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateMedicalRecordPage(),
              ),
            );
          },
        },
      if (isDoctor)
        {
          'icon': Icons.assignment_ind_rounded,
          'label': 'Bệnh nhân',
          'color': const Color(0xFFFFF8E1),
          'onTap': () {},
        },
    ];

    return Row(
      children: services
          .map(
            (service) => Expanded(
              child: _serviceItem(
                service['icon'] as IconData,
                service['label'] as String,
                service['color'] as Color,
                onTap: service['onTap'] as VoidCallback,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _serviceItem(
    IconData icon,
    String label,
    Color bgColor, {
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: const Color(0xFF1F2A44), size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Color(0xFF1F2A44),
          ),
        ),
      ],
    ),
  );
}

class _MockMedicalHistorySection extends StatelessWidget {
  final List<_MockMedicalHistoryItem> items;

  const _MockMedicalHistorySection({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE3E8FF)),
        ),
        child: const Text(
          'Không có bệnh án phù hợp với từ khóa tìm kiếm.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: items
          .map(
            (item) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE3E8FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1F2A44),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.facility,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        item.date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.status,
                          style: const TextStyle(
                            color: Color(0xFF246BFF),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MockMedicalHistoryItem {
  final String title;
  final String facility;
  final String date;
  final String status;

  const _MockMedicalHistoryItem({
    required this.title,
    required this.facility,
    required this.date,
    required this.status,
  });
}
