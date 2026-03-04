import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class HomeFeatureItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? imagePath;
  final VoidCallback? onTap;

  const HomeFeatureItem({
    super.key,
    this.icon,
    required this.title,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: const BoxDecoration(
              color: AppColors.primaryTeal,
              shape: BoxShape.circle,
            ),
            child: imagePath != null
                ? Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                imagePath!,
                fit: BoxFit.contain,
              ),
            )
                : const Icon(
              Icons.image_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}