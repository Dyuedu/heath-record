import 'package:flutter/material.dart';
import 'package:frontend/data/models/profile_view_model.dart';
import 'profile_detail_screen.dart';
import 'profile_form_screen.dart'; // Giả sử bạn đặt tên file form là profile_form_screen.dart


class ProfileManagementScreen extends StatelessWidget {
  final ProfileViewModel   viewModel = ProfileViewModel();

  ProfileManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF76D7C4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hồ sơ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quản lý hồ sơ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.cyan, size: 30),
                  onPressed: () {
                    // Mở form trống để thêm mới
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileFormScreen(isEdit: false)));
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: viewModel.profiles.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final profile = viewModel.profiles[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, size: 30, color: Colors.grey),
                    ),
                    title: Text(profile.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    subtitle: Text('Mã y tế: ${profile.medicalCode}', style: TextStyle(color: Colors.grey[600])),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileDetailScreen(profile: profile)));
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D4D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}