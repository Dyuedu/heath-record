import 'package:flutter/material.dart';
import 'package:frontend/utils/app_theme.dart';

class DoctorUIHelpers {
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF246BFF), Color(0xFF1A56DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> softShadow({double blur = 20}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: blur,
          offset: const Offset(0, 8),
        ),
      ];

  static Widget gradientAvatar(String imageUrl, {double size = 70}) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: headerGradient,
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }

  static Widget infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  static Widget focusBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppTheme.bodyTextColor, fontSize: 12),
      ),
    );
  }

  static Widget statBadge({required IconData icon, required String value, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow(blur: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.bodyTextColor,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppTheme.captionTextColor),
            ),
        ],
      ),
    );
  }

  static Widget actionCircle(
    IconData icon, {
    VoidCallback? onTap,
    Color background = Colors.white,
    Color iconColor = AppTheme.primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: background == Colors.white ? softShadow(blur: 10) : null,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
