import 'package:flutter/material.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/utils/app_routers.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:frontend/views/user/add_profile_page.dart';
import 'package:frontend/views/user/relative_detail_page.dart';
import 'package:frontend/views/user/user_profile_page.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _lastOverviewError;
  String? _lastFamilyError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadOverview();
    });
  }

  Future<void> _handleRefresh() {
    return context.read<ProfileViewModel>().loadOverview();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    final overviewError = vm.errorMessage;
    if (overviewError != null && overviewError != _lastOverviewError) {
      _lastOverviewError = overviewError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppNotifier.error(context, overviewError);
      });
    } else if (overviewError == null) {
      _lastOverviewError = null;
    }

    final familyError = vm.familyErrorMessage;
    if (familyError != null && familyError != _lastFamilyError) {
      _lastFamilyError = familyError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppNotifier.error(context, familyError);
      });
    } else if (familyError == null) {
      _lastFamilyError = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: const CustomBottomNav(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF246BFF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (vm.isLoading) const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 8),
              _buildSectionTitle('Thông tin chung'),
              _buildMenuItem(
                Icons.person_outline,
                'Thông tin cá nhân',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfilePage()),
                ),
              ),
              _buildMenuItem(
                Icons.mark_email_unread_outlined,
                'Yêu cầu liên kết hồ sơ',
                onTap: () =>
                    Navigator.pushNamed(context, AppRouter.linkRequestsInbox),
              ),
              // _buildMenuItem(
              //   Icons.favorite_border,
              //   'Thông tin sức khỏe',
              //   onTap: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (_) => const MedicalRecordPage()),
              //   ),
              // ),
              const SizedBox(height: 8),
              _buildSectionTitle('Hồ sơ người thân'),
              _buildFamilySection(vm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF246BFF), size: 22),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFamilySection(ProfileViewModel vm) {
    final profileCards = vm.familyProfiles;

    if (vm.isFamilyLoading && vm.familyProfiles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (profileCards.isEmpty) {
      return _buildEmptyFamilyState();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      color: Colors.white,
      child: Column(
        children: [
          for (final card in profileCards)
            _buildFamilyCard(
              card.name,
              card.relationship,
              card.avatarUrl ?? '',
              card.dateOfBirth,
              profileId: card.profileId,
              canOpenDetail: true,
            ),
          const SizedBox(height: 12),
          _buildAddProfileButton(),
        ],
      ),
    );
  }

  Widget _buildFamilyCard(
    String name,
    String relationship,
    String avatarUrl,
    String? dateOfBirth, {
    required String? profileId,
    required bool canOpenDetail,
  }) {
    final dobText = _formatValue(dateOfBirth);

    return GestureDetector(
      onTap: () {
        if (!canOpenDetail) {
          return;
        }

        if (profileId == null || profileId.isEmpty) {
          AppNotifier.info(context, 'Hồ sơ này chưa có thông tin chi tiết.');
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RelativeDetailPage(relativeName: name, profileId: profileId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E6FF)),
        ),
        child: Row(
          children: [
            _buildAvatarThumb(avatarUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1F2D3D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatValue(relationship),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.cake_outlined,
                        size: 15,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dobText,
                        style: const TextStyle(
                          color: Color(0xFF5F6368),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              canOpenDetail ? Icons.chevron_right : Icons.person_outline,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFamilyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      color: Colors.white,
      child: Column(
        children: [
          const Icon(Icons.folder, size: 80, color: Color(0xFFFFD54F)),
          const SizedBox(height: 12),
          const Text(
            'Chưa có hồ sơ người thân nào.',
            style: TextStyle(color: Color(0xFF5F6368), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildAddProfileButton(),
        ],
      ),
    );
  }

  Widget _buildAddProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _openAddProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF246BFF),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'THÊM HỒ SƠ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAvatarThumb(String avatarUrl) {
    return avatarUrl.isEmpty
        ? const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFDDE3FF),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFE0E0FF),
              child: Icon(Icons.person, color: Color(0xFF246BFF), size: 22),
            ),
          )
        : CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFDDE3FF),
            child: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          );
  }

  Future<void> _openAddProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProfilePage()),
    );

    if (!mounted) return;
    await context.read<ProfileViewModel>().reloadFamilyProfiles();
  }

  String _formatValue(String? value) {
    final trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? 'Chưa cập nhật' : trimmed;
  }
}
