import 'package:flutter/material.dart';

enum AppNoticeType { success, error, warning, info }

class AppNotifier {
  static void success(BuildContext context, String message) {
    show(context, message, type: AppNoticeType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: AppNoticeType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message, type: AppNoticeType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: AppNoticeType.info);
  }

  static void show(
    BuildContext context,
    String message, {
    AppNoticeType type = AppNoticeType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          padding: EdgeInsets.zero,
          duration: duration,
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: _NoticeCard(
            message: message,
            type: type,
            actionLabel: actionLabel,
            onAction: onAction,
          ),
        ),
      );
  }
}

class _NoticeCard extends StatelessWidget {
  final String message;
  final AppNoticeType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _NoticeCard({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(type);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.baseColor, style.accentColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: style.baseColor.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(style.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: Text(actionLabel!),
              ),
          ],
        ),
      ),
    );
  }

  _NoticeStyle _resolveStyle(AppNoticeType type) {
    switch (type) {
      case AppNoticeType.success:
        return const _NoticeStyle(
          baseColor: Color(0xFF1F9D71),
          accentColor: Color(0xFF45C28E),
          icon: Icons.check_circle_outline,
        );
      case AppNoticeType.error:
        return const _NoticeStyle(
          baseColor: Color(0xFFD64545),
          accentColor: Color(0xFFEE6E6E),
          icon: Icons.error_outline,
        );
      case AppNoticeType.warning:
        return const _NoticeStyle(
          baseColor: Color(0xFFD28C1E),
          accentColor: Color(0xFFE8B14E),
          icon: Icons.warning_amber_rounded,
        );
      case AppNoticeType.info:
        return const _NoticeStyle(
          baseColor: Color(0xFF2457C5),
          accentColor: Color(0xFF3B7BEB),
          icon: Icons.info_outline,
        );
    }
  }
}

class _NoticeStyle {
  final Color baseColor;
  final Color accentColor;
  final IconData icon;

  const _NoticeStyle({
    required this.baseColor,
    required this.accentColor,
    required this.icon,
  });
}
