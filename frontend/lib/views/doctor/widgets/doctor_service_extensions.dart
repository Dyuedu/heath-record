import 'package:flutter/material.dart';
import 'package:frontend/utils/app_theme.dart';
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
          label: 'Hồ sơ mới',
          bgColor: const Color(0xFFFFE8E8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateMedicalRecordPage()),
            );
          },
        ),
        const SizedBox(width: 35),
        _doctorServiceItem(
          icon: Icons.assignment_ind_rounded,
          label: 'Bệnh nhân',
          bgColor: const Color(0xFFFFF8E1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _PatientsComingSoonPage()),
            );
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Column(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: AppTheme.bodyTextColor, size: 24),
          ),
          const SizedBox(height: 15),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppTheme.bodyTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientsComingSoonPage extends StatelessWidget {
  const _PatientsComingSoonPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: const Text('Bệnh nhân', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.people_outline, size: 64, color: AppTheme.captionTextColor),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tính năng quản lý bệnh nhân sẽ sớm ra mắt. Vui lòng chờ nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.captionTextColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
