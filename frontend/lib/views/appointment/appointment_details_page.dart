import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_nav.dart';

class AppointmentDetailsPage extends StatelessWidget {
  const AppointmentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)), onPressed: () => Navigator.pop(context)),
        title: const Text('Your Appointment', style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0, backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Card (Simple version)
            _topDoctorCard(),
            const Divider(height: 40, color: Color(0xFF246BFF)),
            // Date Time Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF246BFF), borderRadius: BorderRadius.circular(15)),
                  child: const Text('Month 24, Year', style: TextStyle(color: Colors.white)),
                ),
                const Spacer(),
                const Icon(Icons.check_circle, color: Color(0xFF246BFF), size: 30),
                const SizedBox(width: 10),
                const Icon(Icons.cancel, color: Color(0xFF246BFF), size: 30),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 8),
              child: Text('WED, 10:00 AM', style: TextStyle(color: Color(0xFF246BFF))),
            ),
            const Divider(height: 40, color: Color(0xFF246BFF)),
            // Info table
            _infoLine('Booking For', 'Another Person'),
            _infoLine('Full Name', 'Jane Doe'),
            _infoLine('Age', '30'),
            _infoLine('Gender', 'Female'),
            const Divider(height: 40, color: Color(0xFF246BFF)),
            const Text('Problem', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit...', style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _topDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFDDE3FF), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const CircleAvatar(radius: 35, backgroundImage: NetworkImage('https://via.placeholder.com/150')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: const Text('Dr. Olivia Turner, M.D.', style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniChip(Icons.star, '5'),
                    const SizedBox(width: 5),
                    _miniChip(Icons.chat, '60'),
                    const SizedBox(width: 5),
                    const Icon(Icons.help_outline, color: Colors.blue, size: 20),
                    const Spacer(),
                    const Icon(Icons.favorite, color: Colors.blue),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _miniChip(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [Icon(icon, size: 12, color: Colors.blue), Text(' $text', style: const TextStyle(color: Colors.blue, fontSize: 10))]),
  );
}