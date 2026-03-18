import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF246BFF);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color cardColor = Colors.white;
  static const Color bodyTextColor = Color(0xFF374151);
  static const Color captionTextColor = Color(0xFF6B7280);

  static ThemeData get theme {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: cardColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
    );
    return base.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: base.colorScheme.copyWith(
        primary: primaryColor,
        secondary: primaryColor,
        surface: cardColor,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: bodyTextColor,
        displayColor: bodyTextColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: primaryColor,
        titleTextStyle: GoogleFonts.inter(
          color: primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: captionTextColor.withValues(alpha: 0.6)),
        labelStyle: const TextStyle(color: captionTextColor),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: primaryLight,
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.inter(color: bodyTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
