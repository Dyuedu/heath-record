import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'appointment_details_page.dart';
import 'cancel_appointment_page.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String selectedFilter = 'Upcoming'; // Mặc định chọn Upcoming để test giao diện mới

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Appointment', style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Complete', 'Upcoming', 'Cancelled'].map((type) {
                bool isActive = selectedFilter == type;
                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF246BFF) : const Color(0xFFDDE3FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(type, style: TextStyle(color: isActive ? Colors.white : const Color(0xFF246BFF), fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
          ),
          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDoctorCard(context, "Dr. Olivia Turner, M.D.", "Dermato-Endocrinology"),
                _buildDoctorCard(context, "Dr. Alexander Bennett, Ph.D.", "Dermato-Genetics"),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildDoctorCard(BuildContext context, String name, String spec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFDDE3FF), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 35, backgroundImage: NetworkImage('https://via.placeholder.com/150')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(spec, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Thay đổi nội dung dựa trên Tab đang chọn
          if (selectedFilter == 'Upcoming') ...[
            _buildInfoRow(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentDetailsPage())),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF246BFF), shape: StadiumBorder()),
                  child: const Text('Details', style: TextStyle(color: Colors.white)),
                )),
                const SizedBox(width: 8),
                _iconAction(Icons.check, Colors.white, const Color(0xFF246BFF)),
                const SizedBox(width: 8),
                _iconAction(Icons.close, Colors.white, const Color(0xFF246BFF), 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CancelPage()))),
              ],
            )
          ] else if (selectedFilter == 'Complete') ...[
            Row(
              children: [
                Expanded(child: _outlineBtn('Re-Book')),
                const SizedBox(width: 10),
                Expanded(child: _filledBtn('Add Review')),
              ],
            )
          ] else ...[
            _filledBtn('Add Review', width: double.infinity),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        _infoChip(Icons.calendar_today, 'Sunday, 12 June'),
        const SizedBox(width: 8),
        _infoChip(Icons.access_time, '9:30 AM - 10:00 AM'),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, size: 14, color: const Color(0xFF246BFF)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: Color(0xFF246BFF))),
      ]),
    );
  }

  Widget _iconAction(IconData icon, Color iconCol, Color bg, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        child: Icon(icon, color: iconCol, size: 20),
      ),
    );
  }

  Widget _outlineBtn(String label) => ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF246BFF), shape: StadiumBorder()), child: Text(label));
  Widget _filledBtn(String label, {double? width}) => SizedBox(width: width, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF246BFF), foregroundColor: Colors.white, shape: StadiumBorder()), child: Text(label)));
}