import 'package:flutter/material.dart';
import 'package:frontend/views/authentication/login_page.dart';
import 'package:frontend/views/user/change_password_page.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../widgets/bottom_nav.dart';
import 'edit_profile_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: userVM.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(child: _buildAvatar(avatar)),
                  const SizedBox(height: 20),
                  _buildInfoRow('ID:', profile?.id ?? ''),
                  _buildInfoRow('Họ và tên:', profile?.fullName ?? ''),
                  _buildInfoRow('Email:', profile?.email ?? ''),
                  _buildInfoRow('Số điện thoại:', profile?.phoneNumber ?? ''),
                  _buildInfoRow('Vai trò:', profile?.role ?? ''),
                  _buildInfoRow('Giới tính:', profile?.gender ?? ''),
                  _buildInfoRow('Ngày sinh:', profile?.dateOfBirth ?? ''),
                  _buildInfoRow('Địa chỉ:', profile?.address ?? ''),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _openEditProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF246BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Chỉnh sửa thông tin'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordPage(),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF246BFF),
                      side: const BorderSide(color: Color(0xFF246BFF)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.password_outlined),
                    label: const Text('Đổi mật khẩu'),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => _showLogoutDialog(context, authVM),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildAvatar(String avatarUrl) {
    if (avatarUrl.isEmpty) {
      return const CircleAvatar(
        radius: 52,
        backgroundColor: Color(0xFFDDE3FF),
        child: Icon(Icons.person, size: 52, color: Color(0xFF246BFF)),
      );
    }

    return ClipOval(
      child: Image.network(
        avatarUrl,
        width: 104,
        height: 104,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) => const CircleAvatar(
          radius: 52,
          backgroundColor: Color(0xFFDDE3FF),
          child: Icon(Icons.person, size: 52, color: Color(0xFF246BFF)),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE3FF).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value.isEmpty ? '-' : value),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await vm.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );

    if (!mounted) return;
    context.read<UserViewModel>().loadMyProfile();
  }
}
