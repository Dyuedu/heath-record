import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy route hiện tại từ Navigator
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    print("Current Route: $currentRoute"); // Debug để xem route hiện tại                                                                       
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: "Trang chủ",
            route: '/home',
            // Highlight nếu là trang chủ hoặc root
            isActive: currentRoute == '/home' || currentRoute == '/',
          ),
          _navItem(
            context,
            icon: Icons.assignment_ind_outlined,
            activeIcon: Icons.assignment_ind_rounded,
            label: "Hồ sơ",
            route: '/personal-profile', 
            isActive: currentRoute == '/personal-profile',
          ),
          _navItem(
            context,
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: "Tài khoản",
            route: '/profile',
            isActive: currentRoute == '/profile',
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    final Color activeColor = const Color.fromARGB(255, 60, 110, 228);
    final Color inactiveColor = Colors.grey.shade500;

    return GestureDetector(
      onTap: isActive 
          ? null 
          : () => Navigator.pushReplacementNamed(context, route),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}