import 'package:flutter/material.dart';
import '../utils/app_routers.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 0,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                imagePath: 'assets/images/home/dat_lich.png',
                label: "Đặt lịch",
                onTap: () => Navigator.pushNamed(context, AppRouter.booking),
              ),
              _NavItem(
                imagePath: 'assets/images/home/thanh_toan.png',
                label: "Thanh toán",
                onTap: () => Navigator.pushNamed(context, AppRouter.payment),
              ),
              const SizedBox(width: 48),
              _NavItem(
                imagePath: 'assets/images/home/benh_su.png',
                label: "Bệnh sử",
                onTap: () => Navigator.pushNamed(context, AppRouter.medicalHistory),
              ),
              _NavItem(
                imagePath: 'assets/images/home/ho_so.png',
                label: "Hồ sơ",
                onTap: () => Navigator.pushNamed(context, AppRouter.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String? imagePath;
  final String label;
  final VoidCallback? onTap;

  const _NavItem({
    this.imagePath,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imagePath != null
              ? SizedBox(
                  width: 32,
                  height: 32,
                  child: Image.asset(imagePath!, fit: BoxFit.contain),
                )
              : Icon(Icons.circle_outlined, size: 24, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}