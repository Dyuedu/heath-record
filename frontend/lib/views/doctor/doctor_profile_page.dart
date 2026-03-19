import 'package:flutter/material.dart';
import 'package:frontend/data/models/doctor/doctor_model.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/utils/doctor_ui_helpers.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/widgets/horizontal_calendar.dart';

class DoctorProfilePage extends StatefulWidget {
  final DoctorModel doctor;
  const DoctorProfilePage({super.key, required this.doctor});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  String _selectedTime = '';

  List<String> get _timeSlots => widget.doctor.availableSlots.isEmpty
      ? const ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM']
      : widget.doctor.availableSlots;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            const SizedBox(height: 24),
            const HorizontalCalendar(),
            const SizedBox(height: 24),
            _buildTimeSection(),
            const SizedBox(height: 24),
            _buildContactCard(),
            const SizedBox(height: 32),
            _buildBookButton(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildHeroCard() {
    final doctor = widget.doctor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: DoctorUIHelpers.headerGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: DoctorUIHelpers.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DoctorUIHelpers.gradientAvatar(doctor.imageUrl, size: 90),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        DoctorUIHelpers.infoChip(
                          Icons.workspace_premium,
                          '${doctor.experienceYears} yrs exp.',
                        ),
                        DoctorUIHelpers.infoChip(
                          Icons.star_rate_rounded,
                          '${doctor.rating.toStringAsFixed(1)} rating',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.profile,
                  style: const TextStyle(
                    color: AppTheme.bodyTextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        doctor.availability,
                        style: const TextStyle(
                          color: AppTheme.captionTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Slots',
          style: TextStyle(
            color: AppTheme.bodyTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _timeSlots.map(_buildTimeChip).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String time) {
    final bool isSelected = _selectedTime == time;
    return GestureDetector(
      onTap: () => setState(() => _selectedTime = time),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: DoctorUIHelpers.softShadow(blur: 14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.primaryLight,
            width: 1.2,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.bodyTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    final doctor = widget.doctor;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: DoctorUIHelpers.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Info',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviews',
                      style: TextStyle(
                        color: AppTheme.captionTextColor.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '${doctor.reviewCount}+',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact',
                      style: TextStyle(
                        color: AppTheme.captionTextColor.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      doctor.contactPhone,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      doctor.contactEmail,
                      style: const TextStyle(
                        color: AppTheme.captionTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              DoctorUIHelpers.actionCircle(
                Icons.email_outlined,
                onTap: () => _showContactSheet('Email', doctor.contactEmail),
              ),
              DoctorUIHelpers.actionCircle(
                Icons.call_outlined,
                onTap: () => _showContactSheet('Phone', doctor.contactPhone),
              ),
              DoctorUIHelpers.actionCircle(
                Icons.info_outline,
                onTap: () => _showDetailsSheet(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedTime.isEmpty ? null : _showConfirmationSheet,
        child: const Text('Book Appointment'),
      ),
    );
  }

  void _showConfirmationSheet() {
    final doctor = widget.doctor;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DoctorUIHelpers.gradientAvatar(doctor.imageUrl, size: 70),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          doctor.specialty,
                          style: const TextStyle(
                            color: AppTheme.captionTextColor,
                          ),
                        ),
                        Text(
                          '$_selectedTime • ${doctor.availability}',
                          style: const TextStyle(color: AppTheme.bodyTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'We will send a confirmation notification once the clinic confirms this slot.',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  AppNotifier.success(
                    this.context,
                    'Appointment request sent!',
                  );
                },
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        );
      },
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
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: AppTheme.bodyTextColor)),
          ],
        ),
      ),
    );
  }

  void _showDetailsSheet() {
    final doctor = widget.doctor;
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
            const Text(
              'Highlights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              doctor.highlights,
              style: const TextStyle(
                color: AppTheme.bodyTextColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
