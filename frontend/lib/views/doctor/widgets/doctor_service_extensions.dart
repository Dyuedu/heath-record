import 'package:flutter/material.dart';
import 'package:frontend/views/doctor/create_medical_record_page.dart';

/// Doctor-only service items that get injected into the HomePage services grid.
/// This file is isolated to avoid conflicts with the shared HomePage.
class DoctorServiceExtensions extends StatelessWidget {
  const DoctorServiceExtensions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _doctorServiceItem(
          icon: Icons.add_circle_outline_rounded,
          label: 'Tạo Bệnh Án',
          bgColor: const Color(0xFFFFE8E8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateMedicalRecordPage()),
            );
          },
        ),
        const SizedBox(width: 20),
        _doctorServiceItem(
          icon: Icons.assignment_ind_rounded,
          label: 'QL Bệnh Nhân',
          bgColor: const Color(0xFFFFF8E1),
          onTap: () {
            // TODO: Navigate to Patient Management page
          },
        ),
      ],
    );
  }

  Widget _doctorServiceItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: const Color(0xFF1F2A44), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF1F2A44),
            ),
          ),
        ],
      ),
    );
  }
}
