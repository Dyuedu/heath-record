import 'package:flutter/material.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/data/repositories/secure_storage_repository.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:frontend/views/search/search_patient_page.dart';
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

  @override
  void initState() {
    super.initState();
    _resolveUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVM = context.read<ProfileViewModel>();
      if (profileVM.profile == null && !profileVM.isLoading) {
        profileVM.loadOverview();
      }
    });
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
        }
      }
    } catch (error) {
      debugPrint('Unable to decode role: $error');
    } finally {
      if (mounted) {
        setState(() => _isRoleLoading = false);
      }
    }
  }

  bool get _isDoctor => (_userRole?.toLowerCase() == 'role_doctor');

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
              ),
              const SizedBox(height: 30),

              // 2. Banner/Search Section (chỉ hiển thị với bác sĩ)
              if (!_isRoleLoading && _isDoctor) ...[
                const Text(
                  "Tìm kiếm thông tin",
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
                        builder: (_) => const SearchPatientPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ] else
                const SizedBox(height: 20),

              // 3. Featured Categories/Services
              const _SectionHeader(title: "Dịch vụ y tế"),
              const SizedBox(height: 15),
              _QuickServicesGrid(),
              const SizedBox(height: 30),

              // 4. Featured Doctors (Dành cho bệnh nhân) hoặc Patient OverView (Dành cho bác sĩ)
              const _SectionHeader(title: "Bác sĩ nổi bật"),
              const SizedBox(height: 15),
              const _FeaturedDoctorsSection(),

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

  const _UserHeaderSection({required this.profile, required this.isLoading});

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
        _notificationBadge(Icons.notifications_none_rounded),
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

  Widget _notificationBadge(IconData icon) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black12),
    ),
    child: Icon(icon, color: const Color(0xFF1F2A44), size: 24),
  );

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
            Text(
              isDoctor ? "Tìm kiếm bệnh nhân..." : "Tìm bác sĩ, bệnh viện...",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

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
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _serviceItem(
          Icons.calendar_month_rounded,
          "Lịch khám",
          const Color(0xFFE8F1FF),
        ),
        _serviceItem(
          Icons.folder_shared_rounded,
          "Hồ sơ",
          const Color(0xFFFFF1E8),
        ),
        _serviceItem(
          Icons.local_hospital_rounded,
          "Bệnh viện",
          const Color(0xFFE8FFF1),
        ),
        _serviceItem(Icons.more_horiz_rounded, "Thêm", const Color(0xFFF1E8FF)),
      ],
    );
  }

  Widget _serviceItem(IconData icon, String label, Color bgColor) => Column(
    children: [
      Container(
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
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Color(0xFF1F2A44),
        ),
      ),
    ],
  );
}

class _FeaturedDoctorsSection extends StatelessWidget {
  const _FeaturedDoctorsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3E8FF)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFFDDE3FF),
            child: Icon(
              Icons.medical_services_rounded,
              color: Color(0xFF246BFF),
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Dr. Olivia Turner",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1F2A44),
                  ),
                ),
                Text(
                  "Chuyên khoa Nội tiết",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    Text(
                      " 4.9 ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "(120 đánh giá)",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
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
}
