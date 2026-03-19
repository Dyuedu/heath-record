import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/models/record/relative.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/utils/app_routers.dart';
import 'package:frontend/viewmodels/profile_viewmodel.dart';
import 'package:frontend/views/user/add_profile_page.dart';
import 'package:frontend/views/user/relative_detail_page.dart';
import 'package:frontend/views/user/user_profile_page.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();

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
    final profile = vm.profile;

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
              _buildHeader(profile, vm),
              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: _buildErrorBanner(vm.errorMessage!),
                ),
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

  Widget _buildHeader(UserProfileModel? profile, ProfileViewModel vm) {
    final avatarUrl = (profile?.avatarUrl ?? '').trim();
    final displayName = _formatValue(profile?.fullName);
    // final phone = _formatValue(profile?.phoneNumber);
    // final email = _formatValue(profile?.email);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF26BC9B), Color(0xFF246BFF)],
            ),
          ),
        ),
        Positioned(
          top: 55,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  _buildAvatar(avatarUrl, vm.isAvatarUploading),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: vm.isAvatarUploading
                          ? null
                          : () => _onPickAvatar(vm),
                      child: Opacity(
                        opacity: vm.isAvatarUploading ? 0.4 : 1,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 2),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              // Text(
              //   phone,
              //   style: const TextStyle(color: Colors.white70, fontSize: 13),
              // ),
              // Text(
              //   email,
              //   style: const TextStyle(color: Colors.white70, fontSize: 13),
              // ),
            ],
          ),
        ),
      ],
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
    if (vm.isFamilyLoading && vm.familyProfiles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.familyProfiles.isEmpty) {
      return _buildEmptyFamilyState(vm.familyErrorMessage);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      color: Colors.white,
      child: Column(
        children: [
          for (final relative in vm.familyProfiles) _buildFamilyCard(relative),
          const SizedBox(height: 12),
          _buildAddProfileButton(),
          if (vm.familyErrorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                vm.familyErrorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFamilyCard(Relative relative) {
    final relationship = _formatValue(relative.relationship);

    return GestureDetector(
      onTap: () {
        final profileId = relative.profileId;
        if (profileId == null || profileId.isEmpty) {
          AppNotifier.info(context, 'Hồ sơ này chưa có thông tin chi tiết.');
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RelativeDetailPage(
              relativeName: relative.name,
              profileId: profileId,
            ),
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
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF246BFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    relative.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1F2D3D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    relationship,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFamilyState(String? errorMessage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      color: Colors.white,
      child: Column(
        children: [
          const Icon(Icons.folder, size: 80, color: Color(0xFFFFD54F)),
          const SizedBox(height: 12),
          Text(
            errorMessage ?? 'Chưa có hồ sơ người thân nào.',
            style: const TextStyle(color: Color(0xFF5F6368), fontSize: 13),
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

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl, bool isUploading) {
    final Widget avatar = avatarUrl.isEmpty
        ? const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Color(0xFFE0E0FF),
              child: Icon(Icons.person, color: Color(0xFF246BFF), size: 36),
            ),
          )
        : CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 38,
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (_, __) {},
            ),
          );

    if (!isUploading) return avatar;

    return Stack(
      alignment: Alignment.center,
      children: [
        avatar,
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _onPickAvatar(ProfileViewModel vm) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      final avatarFile = File(pickedFile.path);
      final success = await vm.updateAvatar(avatarFile);
      if (!mounted) return;

      final message = success
          ? 'Ảnh đại diện đã được cập nhật.'
          : vm.avatarErrorMessage ?? 'Không thể cập nhật ảnh đại diện.';

      if (success) {
        AppNotifier.success(context, message);
      } else {
        AppNotifier.error(context, message);
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      AppNotifier.error(
        context,
        error.message ?? 'Không thể truy cập thư viện ảnh.',
      );
    }
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
