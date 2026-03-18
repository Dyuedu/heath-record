import 'package:flutter/material.dart';
import 'package:frontend/data/models/doctor/doctor_model.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/utils/doctor_ui_helpers.dart';
import 'package:frontend/views/doctor/doctor_profile_page.dart';
import '../../widgets/bottom_nav.dart';

class DoctorInfoPage extends StatefulWidget {
  final DoctorModel doctor;
  const DoctorInfoPage({super.key, required this.doctor});

  @override
  State<DoctorInfoPage> createState() => _DoctorInfoPageState();
}

class _DoctorInfoPageState extends State<DoctorInfoPage> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Doctor Info',
          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppTheme.primaryColor)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune, color: AppTheme.primaryColor)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 24),
            _buildDetailSection('Profile', widget.doctor.profile),
            _buildDetailSection('Career Path', widget.doctor.careerPath),
            _buildDetailSection('Highlights', widget.doctor.highlights),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final doctor = widget.doctor;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: DoctorUIHelpers.headerGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: DoctorUIHelpers.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DoctorUIHelpers.gradientAvatar(doctor.imageUrl, size: 110),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(doctor.specialty, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        DoctorUIHelpers.infoChip(Icons.workspace_premium, '${doctor.experienceYears} yrs experience'),
                        DoctorUIHelpers.infoChip(Icons.person, 'Reviews ${doctor.reviewCount}+'),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Text(
                  doctor.specialty,
                  style: const TextStyle(color: AppTheme.captionTextColor, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _whiteStatItem(Icons.star, '${doctor.rating.toStringAsFixed(1)}', 'Rating')),
              const SizedBox(width: 10),
              Expanded(child: _whiteStatItem(Icons.chat_bubble_outline, '${doctor.reviewCount}', 'Reviews')),
              const SizedBox(width: 10),
              Expanded(child: _whiteStatItem(Icons.access_time, doctor.availability, 'Schedule')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DoctorProfilePage(doctor: doctor),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_month, color: Colors.white, size: 18),
                  label: const Text('Schedule'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DoctorUIHelpers.actionCircle(Icons.info_outline, onTap: () => _showContactSheet('Clinic Hours', doctor.availability)),
              DoctorUIHelpers.actionCircle(Icons.help_outline, onTap: () => _showContactSheet('Contact', doctor.contactPhone)),
              DoctorUIHelpers.actionCircle(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                iconColor: _isFavorite ? Colors.redAccent : AppTheme.primaryColor,
                onTap: () => setState(() => _isFavorite = !_isFavorite),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _whiteStatItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: DoctorUIHelpers.softShadow(blur: 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.bodyTextColor)),
          Text(label, style: const TextStyle(color: AppTheme.captionTextColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: DoctorUIHelpers.softShadow(blur: 18),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.bodyTextColor),
        ),
        children: [
          Text(
            content,
            style: const TextStyle(color: AppTheme.captionTextColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showContactSheet(String label, String value) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: AppTheme.bodyTextColor)),
          ],
        ),
      ),
    );
  }
}
