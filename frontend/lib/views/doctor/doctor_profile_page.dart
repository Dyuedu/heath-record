import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/widgets/horizontal_calendar.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(/* ... giữ nguyên app bar cũ ... */),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExperienceHeader(), // Header thông tin bác sĩ đã viết ở bước trước
          const SizedBox(height: 20),
          
          // --- PHẦN LỊCH CHỌN NGÀY ---
          const HorizontalCalendar(),
          
          const SizedBox(height: 25),
          
          // --- PHẦN CHỌN GIỜ (TIME SLOTS) ---
          const Text(
            'Time',
            style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildTimeChip('09:00 AM', false),
              _buildTimeChip('09:30 AM', true), // Đang chọn
              _buildTimeChip('10:00 AM', false),
              _buildTimeChip('10:30 AM', false),
              _buildTimeChip('11:00 AM', false),
              _buildTimeChip('11:30 AM', false),
            ],
          ),
          
          const SizedBox(height: 25),
          
          // Nút đặt lịch
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF246BFF),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: StadiumBorder(),
              ),
              child: const Text('Book Appointment', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 100), // Padding cho BottomNav
        ],
      ),
    ),
    bottomNavigationBar: const CustomBottomNav(),
  );
}
  Widget _buildTimeChip(String time, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF246BFF) : const Color(0xFFDDE3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF246BFF),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildExperienceHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE3FF),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  children: [
                    _blueBadge(Icons.workspace_premium, '15 years experience'),
                    const SizedBox(height: 10),
                    _focusBox(
                      'Focus: The impact of hormonal imbalances on skin conditions...',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              children: [
                Text(
                  'Dr. Alexander Bennett, Ph.D.',
                  style: TextStyle(
                    color: Color(0xFF246BFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Dermato-Genetics',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoIconBadge(Icons.star, '5'),
              _infoIconBadge(Icons.chat_bubble_outline, '40'),
              _infoIconBadge(Icons.access_time, 'Mon-Sat / 9:00AM - 5:00PM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        color: Color(0xFF246BFF),
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
  );

  Widget _blueBadge(IconData icon, String text) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: const Color(0xFF246BFF),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    ),
  );

  Widget _focusBox(String text) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFF246BFF),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 10),
    ),
  );

  Widget _infoIconBadge(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, size: 14, color: Colors.blue),
        Text(
          ' $text',
          style: const TextStyle(color: Colors.blue, fontSize: 10),
        ),
      ],
    ),
  );
}
