import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';

class DoctorInfoPage extends StatelessWidget {
  final dynamic doctor; // Dữ liệu truyền từ DoctorsListPage

  const DoctorInfoPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Doctor Info',
          style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Color(0xFF246BFF))),
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune, color: Color(0xFF246BFF))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Card (Dựa trên thiết kế Doctors-1.png)
            _buildDoctorHeaderCard(),
            const SizedBox(height: 24),

            // 2. Sections (Profile, Career Path, Highlights)
            _buildDetailSection("Profile", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
            _buildDetailSection("Career Path", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
            _buildDetailSection("Highlights", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
            
            const SizedBox(height: 80), // Khoảng trống cho BottomNav
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildDoctorHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE3FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(doctor.imageUrl),
              ),
              const SizedBox(width: 12),
              // Experience & Focus Tags
              Expanded(
                child: Column(
                  children: [
                    _blueInfoTag(Icons.workspace_premium, "15 years experience"),
                    const SizedBox(height: 8),
                    _blueFocusBox("Focus: The impact of hormonal imbalances on skin conditions, specializing in acne, hirsutism, and other skin disorders."),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(doctor.name, style: const TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold, fontSize: 16)),
                Text(doctor.specialty, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _whiteStatItem(Icons.star, "5"),
              _whiteStatItem(Icons.chat_bubble_outline, "40"),
              _whiteStatItem(Icons.access_time, "Mon-Sat / 9:00AM - 5:00PM"),
            ],
          ),
          const SizedBox(height: 16),
          // Schedule Button & Icons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_month, color: Colors.white, size: 18),
                  label: const Text("Schedule", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF246BFF),
                    shape: StadiumBorder(),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _smallIconAction(Icons.info_outline),
              _smallIconAction(Icons.help_outline),
              _smallIconAction(Icons.star_border),
              _smallIconAction(Icons.favorite_border),
            ],
          )
        ],
      ),
    );
  }

  Widget _blueInfoTag(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFF246BFF), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Icon(icon, color: Colors.white, size: 14), const SizedBox(width: 4), Text(text, style: const TextStyle(color: Colors.white, fontSize: 10))]),
      );

  Widget _blueFocusBox(String text) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFF246BFF), borderRadius: BorderRadius.circular(15)),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
      );

  Widget _whiteStatItem(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [Icon(icon, color: Colors.blue, size: 14), const SizedBox(width: 4), Text(text, style: const TextStyle(color: Colors.blue, fontSize: 10))]),
      );

  Widget _smallIconAction(IconData icon) => Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF246BFF), size: 18),
      );

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}