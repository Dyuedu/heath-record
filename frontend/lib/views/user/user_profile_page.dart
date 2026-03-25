import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/views/authentication/login_page.dart';
import 'package:frontend/views/user/change_password_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../widgets/bottom_nav.dart';
import 'edit_profile_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().loadMyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final userVM = context.watch<UserViewModel>();
    final profile = userVM.profile;
    final avatar = (profile?.avatarUrl ?? '').trim();

    final isAdmin = profile?.role.toUpperCase() == 'ADMIN';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Nền xám nhạt như ảnh
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Hồ sơ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: userVM.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- Header: Avatar & Name ---
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        _buildAvatar(avatar, userVM.isAvatarUploading),
                        const SizedBox(height: 16),
                        Text(
                          profile?.fullName ?? 'Người dùng',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFE8F1FF), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            (profile?.role ?? 'Người dùng').toUpperCase(),
                            style: const TextStyle(color: Color(0xFF007BFF), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Section: THÔNG TIN LIÊN HỆ ---
                  _buildSectionTitle('THÔNG TIN LIÊN HỆ'),
                  _buildInfoCard([
                    _buildInfoTile(Icons.email_outlined, 'Email', profile?.email ?? '-', Colors.blue),
                    _buildInfoTile(Icons.phone_outlined, 'Số điện thoại', profile?.phoneNumber ?? '-', Colors.blue),
                    _buildInfoTile(Icons.location_on_outlined, 'Địa chỉ', profile?.address ?? '-', Colors.blue, isLast: true),
                  ]),

                  // --- Section: TÀI KHOẢN & BẢO MẬT ---
                  _buildSectionTitle('TÀI KHOẢN & BẢO MẬT'),
                  _buildInfoCard([
                    _buildActionTile(Icons.person_outline, 'Chỉnh sửa hồ sơ', _openEditProfile),
                    _buildActionTile(Icons.lock_outline, 'Đổi mật khẩu', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
                    }),
                  ]),

                  // --- Logout Button ---
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(context, authVM),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF05454), // Màu đỏ nhạt như ảnh
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text('Đăng xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  // --- Widget Components ---

  Widget _buildSectionTitle(String title) => Container(
    width: double.infinity,
    padding: const EdgeInsets.only(left: 20, top: 12, bottom: 8),
    child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6C757D))),
  );

  Widget _buildInfoCard(List<Widget> children) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Column(children: children),
  );

  Widget _buildInfoTile(IconData icon, String label, String value, Color iconColor, {bool isLast = false}) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
      if (!isLast) Divider(height: 1, indent: 70, color: Colors.grey.shade100),
    ],
  );

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap, {bool isLast = false}) => Column(
    children: [
      ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ),
      if (!isLast) Divider(height: 1, indent: 70, color: Colors.grey.shade100),
    ],
  );

  Widget _buildAvatar(String avatarUrl, bool isUploading) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: CircleAvatar(
            radius: 54,
            backgroundColor: Colors.grey.shade100,
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: isUploading ? null : _onPickAvatar,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF007BFF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: isUploading 
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.edit, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  // --- Giữ nguyên toàn bộ logic functions cũ ---
  Future<void> _onPickAvatar() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile == null || !mounted) return;
      final vm = context.read<UserViewModel>();
      final success = await vm.updateAvatar(File(pickedFile.path));
      if (!mounted) return;
      if (success) {
        AppNotifier.success(context, 'Ảnh đại diện đã được cập nhật.');
      } else {
        AppNotifier.error(context, vm.avatarErrorMessage ?? 'Không thể cập nhật.');
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      AppNotifier.error(context, error.message ?? 'Lỗi truy cập thư viện.');
    }
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              await vm.logout();
              if (!context.mounted) return;
              context.read<UserViewModel>().clearSessionData();
              context.read<ProfileViewModel>().clearSessionData();
              context.read<NotificationViewModel>().clearSessionData();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditProfile() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
    if (!mounted) return;
    context.read<UserViewModel>().loadMyProfile();
  }
}