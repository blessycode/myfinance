import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display
  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.w800, letterSpacing: -1.5, color: _textPrimary(context));

  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.w700, letterSpacing: -1.0, color: _textPrimary(context));

  static TextStyle displaySmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: _textPrimary(context));

  // Headlines
  static TextStyle headlineLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: _textPrimary(context));

  static TextStyle headlineMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: _textPrimary(context));

  static TextStyle headlineSmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: _textPrimary(context));

  // Titles
  static TextStyle titleLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.1, color: _textPrimary(context));

  static TextStyle titleMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: _textPrimary(context));

  static TextStyle titleSmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: _textPrimary(context));

  // Body
  static TextStyle bodyLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.1, color: _textPrimary(context));

  static TextStyle bodyMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.2, color: _textSecondary(context));

  static TextStyle bodySmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.3, color: _textSecondary(context));

  // Labels
  static TextStyle labelLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: _textPrimary(context));

  static TextStyle labelMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: _textSecondary(context));

  static TextStyle labelSmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: _textTertiary(context));

  // Money display (special)
  static TextStyle moneyDisplay(BuildContext context) =>
      GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -2, color: _textPrimary(context));

  static TextStyle moneyLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1.5, color: _textPrimary(context));

  static TextStyle moneyMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -1, color: _textPrimary(context));

  static TextStyle moneySmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: _textPrimary(context));

  // Helpers
  static Color _textPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  }

  static Color _textSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  }

  static Color _textTertiary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
  }

  // Static (no context required)
  static TextStyle get moneyDisplayWhite => GoogleFonts.inter(
        fontSize: 48, fontWeight: FontWeight.w800,
        letterSpacing: -2, color: Colors.white);

  static TextStyle get headlineWhite => GoogleFonts.inter(
        fontSize: 28, fontWeight: FontWeight.w700,
        letterSpacing: -0.3, color: Colors.white);

  static TextStyle get titleWhite => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600,
        letterSpacing: 0.1, color: Colors.white);

  static TextStyle get bodyWhite => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        letterSpacing: 0.2, color: Colors.white70);

  static TextStyle get labelWhite => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500,
        letterSpacing: 0.5, color: Colors.white60);
}
