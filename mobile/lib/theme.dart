import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A PW/Unacademy-style ed-tech palette: confident indigo primary, a warm
/// amber accent for price/CTA emphasis, and a soft off-white background
/// instead of stark white so cards have somewhere to sit.
class AppColors {
  static const primary = Color(0xFF4F3DF5);
  static const primaryDark = Color(0xFF3B2BC7);
  static const accent = Color(0xFFFFA726);
  static const success = Color(0xFF1FAE63);
  static const background = Color(0xFFF6F6FB);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE8E8F0);

  /// Rotating gradient pairs used as course-card banners in place of real
  /// thumbnails (no image hosting wired up yet).
  static const bannerGradients = [
    [Color(0xFF4F3DF5), Color(0xFF8D7CFF)],
    [Color(0xFFFF7A59), Color(0xFFFFB199)],
    [Color(0xFF1FAE63), Color(0xFF6FE3A3)],
    [Color(0xFF0EA5E9), Color(0xFF7DD3FC)],
  ];
}

ThemeData buildAppTheme() {
  final textTheme = GoogleFonts.poppinsTextTheme().copyWith(
    headlineSmall: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
    bodySmall: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
    labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: textTheme.labelLarge,
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
