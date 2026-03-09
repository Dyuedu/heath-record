import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF246BFF), // Màu xanh đậm chủ đạo
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.home_outlined, () {
            Navigator.pushReplacementNamed(context, '/home');
          }),
          // _navItem(context, Icons.chat_bubble_outline, () {
          //   // Điều hướng sang trang Chat
          // }),
          // NÚT HÌNH NGƯỜI SANG PROFILE
          _navItem(context, Icons.person_outline, () {
            Navigator.pushReplacementNamed(context, '/profile');
          }),
          _navItem(context, Icons.calendar_month, () {
            // Điều hướng sang trang Lịch hẹn
            Navigator.pushReplacementNamed(context, '/appointments');
          }),
        ],
      ),
    );
  }

  // Hàm phụ trợ tạo các item trong Nav để code gọn hơn
  Widget _navItem(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Đảm bảo nhận sự kiện nhấn tốt hơn
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}