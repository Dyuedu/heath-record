import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routers.dart';
import '../../widgets/home_bottom_nav.dart';
import '../../widgets/home_feature_item.dart';
import '../../widgets/upcoming_appointment_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const HomeBottomNav(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 8),
        child: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            backgroundColor: AppColors.primaryTeal,
            elevation: 4,
            shape: const CircleBorder(),
            onPressed: () {},
            child: const Icon(Icons.call, color: Colors.white, size: 32),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primaryTeal,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 4),

                    /// Logo
                    Center(
                      child: Image.asset(
                        'assets/images/logo_small.png',
                        height: 60,
                      ),
                    ),

                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ),

          /// White content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  /// Header: Xin chào + avatar
                  _buildHeader(),

                  const SizedBox(height: 25),

                  /// Appointment Card
                  const UpcomingAppointmentCard(),

                  const SizedBox(height: 30),

                  /// Chức năng title
                  const Text(
                    "Chức năng",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  // const SizedBox(height: 20),

                  /// Grid Feature
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    children: [
                      HomeFeatureItem(
                        imagePath: 'assets/images/home/dat_lich.png',
                        title: "Đặt lịch",
                        onTap: () => Navigator.pushNamed(context, AppRouter.booking),
                      ),
                      HomeFeatureItem(
                        imagePath: 'assets/images/home/lich_hen.png',
                        title: "Lịch hẹn",
                        onTap: () => Navigator.pushNamed(context, AppRouter.appointment),
                      ),
                      HomeFeatureItem(
                        imagePath: 'assets/images/home/lich_tai_kham.png',
                        title: "Lịch tái khám",
                        onTap: () => Navigator.pushNamed(context, AppRouter.followUp),
                      ),
                      HomeFeatureItem(
                        imagePath: 'assets/images/home/benh_su.png',
                        title: "Bệnh sử",
                        onTap: () => Navigator.pushNamed(context, AppRouter.medicalRecord),
                      ),
                      HomeFeatureItem(
                        imagePath: 'assets/images/home/ho_so.png',
                        title: "Hồ sơ",
                        onTap: () => Navigator.pushNamed(context, AppRouter.profile),
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Xin chào,",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryTeal.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, color: Colors.grey, size: 30),
          ),
        ),
      ],
    );
  }
}