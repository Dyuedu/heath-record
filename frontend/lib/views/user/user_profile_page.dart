import 'package:flutter/material.dart';
import 'package:frontend/views/authentication/login_page.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/bottom_nav.dart';
import 'edit_profile_page.dart'; // Giả sử bạn đã có file này từ lượt trước

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin từ AuthViewModel nếu cần (ví dụ: tên, ảnh từ Backend)
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF246BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 1. Avatar Section với nút Edit
            _buildAvatarSection(context),
            const SizedBox(height: 15),

            // 2. User Name
            const Text(
              "John Doe",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),

            // 3. Menu List
            _buildMenuItem(
              icon: Icons.person_outline,
              title: "Profile",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.favorite_border,
              title: "Favorite",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: "Payment Method",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: "Privacy Policy",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: "Settings",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: "Help",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.logout,
              title: "Logout",
              isLogout: true,
              onTap: () => _showLogoutDialog(context, authVM),
            ),
            const SizedBox(height: 100), // Khoảng trống cho BottomNav
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  // --- Widget Components ---

  Widget _buildAvatarSection(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDDE3FF), width: 4),
          ),
          child: const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 5,
          child: GestureDetector(
            onTap: () {
              // Logic đổi ảnh hoặc sang trang edit
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF246BFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE3FF).withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF246BFF), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: isLogout
          ? null
          : const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFDDE3FF),
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  // Hàm hiển thị hộp thoại xác nhận Logout
  // Hàm hiển thị hộp thoại xác nhận Logout giống thiết kế ảnh Logout.png
  void _showLogoutDialog(BuildContext context, AuthViewModel vm) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Bo góc lớn giống ảnh
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Để dialog gọn theo nội dung
            children: [
              const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF246BFF), // Màu xanh chủ đạo
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "are you sure you want to log out?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  // Nút Cancel màu nhạt
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDDE3FF),
                        foregroundColor: const Color(0xFF246BFF),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Nút Yes, Logout màu xanh đậm
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await vm.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF246BFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Yes, Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
