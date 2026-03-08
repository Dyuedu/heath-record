import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Header (Avatar, Name, Notifications, Settings)
              const _UserHeaderSection(),
              const SizedBox(height: 25),

              // 2. Quick Actions & Search Bar
              const _SearchAndActionsSection(),
              const SizedBox(height: 25),

              // 3. Weekly Calendar Strip
              const _WeeklyCalendarSection(),
              const SizedBox(height: 25),

              // 4. Today's Appointment Timeline
              const _TodayAppointmentSection(),
              const SizedBox(height: 25),

              // 5. Featured Doctors List
              const _FeaturedDoctorsSection(),
              const SizedBox(height: 100), // Khoảng trống cho BottomNav
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}

// --- Tách các Widget thành phần ---

// 1. User Header
class _UserHeaderSection extends StatelessWidget {
  const _UserHeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Thay bằng ảnh thật
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Hi, Welcome Back", style: TextStyle(color: Color(0xFF246BFF), fontSize: 12)),
            Text("John Doe", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        const Spacer(),
        _iconButton(Icons.notifications_none),
        const SizedBox(width: 10),
        _iconButton(Icons.settings_outlined),
      ],
    );
  }

  Widget _iconButton(IconData icon) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFDDE3FF), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF246BFF), size: 24),
      );
}

// 2. Quick Actions & Search
class _SearchAndActionsSection extends StatelessWidget {
  const _SearchAndActionsSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _actionItem(Icons.medical_services_outlined, "Doctors"),
        const SizedBox(width: 15),
        _actionItem(Icons.favorite_border, "Favorite"),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFDDE3FF), borderRadius: BorderRadius.circular(25)),
            child: Row(
              children: const [
                Icon(Icons.tune, color: Color(0xFF246BFF), size: 20),
                Spacer(),
                Icon(Icons.search, color: Color(0xFF246BFF), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label) => Column(
        children: [
          Icon(icon, color: const Color(0xFF246BFF), size: 30),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Color(0xFF246BFF), fontSize: 12)),
        ],
      );
}

// 3. Weekly Calendar
class _WeeklyCalendarSection extends StatelessWidget {
  const _WeeklyCalendarSection();

  @override
  Widget build(BuildContext context) {
    // Dữ liệu demo cho lịch tuần
    final days = [
      {"day": "9", "weekday": "MON", "selected": false},
      {"day": "10", "weekday": "TUE", "selected": false},
      {"day": "11", "weekday": "WED", "selected": true}, // Đang chọn
      {"day": "12", "weekday": "THU", "selected": false},
      {"day": "13", "weekday": "FRI", "selected": true}, // Đang chọn
      {"day": "14", "weekday": "SAT", "selected": true}, // Đang chọn
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) => _calendarDay(d)).toList(),
    );
  }

  Widget _calendarDay(Map<String, dynamic> data) {
    bool isSelected = data["selected"];
    return Container(
      width: 55, height: 70,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF246BFF) : const Color(0xFFDDE3FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(data["day"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
          Text(data["weekday"], style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.black54)),
        ],
      ),
    );
  }
}

// 4. Today Appointment
class _TodayAppointmentSection extends StatelessWidget {
  const _TodayAppointmentSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Text("11 Wednesday - Today", style: TextStyle(color: Color(0xFF246BFF), fontSize: 14, fontWeight: FontWeight.w500)),
            Spacer(),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            // Đường kẻ Timeline (Demo)
            Positioned.fill(
              child: Align(alignment: Alignment.centerRight, child: Container(width: double.infinity, height: 1, color: const Color(0xFFDDE3FF))),
            ),
            Row(
              children: [
                _timeLabel("9 AM"), _timeLabel("10 AM"), _timeLabel("11 AM"), _timeLabel("12 AM"),
              ],
            ),
            // Thẻ lịch hẹn đè lên (Demo)
            Positioned(
              left: 70, top: 15,
              child: _appointmentCard(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _timeLabel(String time) => Padding(padding: const EdgeInsets.only(right: 25), child: Text(time, style: const TextStyle(color: Color(0xFF246BFF), fontSize: 12)));

  Widget _appointmentCard() => Container(
    padding: const EdgeInsets.all(10),
    width: 200,
    decoration: BoxDecoration(color: const Color(0xFFDDE3FF), borderRadius: BorderRadius.circular(15)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text("Dr. Olivia Turner, M.D.", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF246BFF), fontSize: 13)),
            Spacer(), Icon(Icons.check_circle_outline, size: 16, color: Colors.green), SizedBox(width: 5), Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
          ],
        ),
        const Text("Treatment and prevention of skin and photodermatitis.", style: TextStyle(color: Colors.black54, fontSize: 11), maxLines: 2),
      ],
    ),
  );
}

// 5. Featured Doctors
class _FeaturedDoctorsSection extends StatelessWidget {
  const _FeaturedDoctorsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Demo 1 bác sĩ
        _doctorCard(
          name: "Dr. Olivia Turner, M.D.",
          specialty: "Dermato-Endocrinology",
          rating: "5",
          reviews: "60",
          imageUrl: 'https://via.placeholder.com/150',
        ),
        const SizedBox(height: 15),
        // Thêm các bác sĩ khác tương tự...
      ],
    );
  }

  Widget _doctorCard({required String name, required String specialty, required String rating, required String reviews, required String imageUrl}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFDDE3FF), borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF246BFF), fontSize: 14)),
                Text(specialty, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _infoBadge(Icons.star, rating, const Color(0xFF246BFF)),
                    const SizedBox(width: 10),
                    _infoBadge(Icons.chat_bubble_outline, reviews, const Color(0xFF246BFF)),
                    const Spacer(),
                    const Icon(Icons.help_outline, color: Color(0xFF246BFF), size: 20),
                    const SizedBox(width: 10),
                    const Icon(Icons.favorite, color: Color(0xFF246BFF), size: 20),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(text, style: TextStyle(color: color, fontSize: 11))]),
  );
}