import 'package:flutter/material.dart';

/// Central Design System Color Tokens.
/// Forest-green finance palette inspired by the Provida product reference.
abstract final class AppColors {
  // Primary Palette - Forest Green
  static const Color primary = Color(0xFF0B6B55);
  static const Color primaryLight = Color(0xFF18B878);
  static const Color primaryDark = Color(0xFF073D32);

  // Secondary - Deep Midnight Slate
  static const Color secondary = Color(0xFF062F28);
  static const Color secondaryLight = Color(0xFF124C40);

  // Accent - Fresh Mint
  static const Color accent = Color(0xFF20B77A);
  static const Color accentLight = Color(0xFF9AE6C0);
  static const Color accentDark = Color(0xFF087A58);

  // Semantic Financial Indicators
  static const Color income = Color(0xFF18A86B);
  static const Color expense = Color(0xFFF43F5E);
  static const Color success = Color(0xFF18A86B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);

  // Canvas & Backgrounds - Light Mode
  static const Color backgroundLight = Color(0xFFF7F5F1);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardLightSecondary = Color(0xFFF0F5F2);
  static const Color borderLight = Color(0xFFDDE8E2);
  static const Color dividerLight = Color(0xFFE9EFEB);

  // Canvas & Backgrounds - Dark Mode
  static const Color backgroundDark = Color(0xFF061A16);
  static const Color surfaceDark = Color(0xFF0B2721);
  static const Color cardDark = Color(0xFF10362D);
  static const Color cardDarkSecondary = Color(0xFF17473B);
  static const Color borderDark = Color(0xFF265C4E);
  static const Color dividerDark = Color(0xFF1D4B40);

  // Text Hierarchy - Light
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Text Hierarchy - Dark
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // Gradients
  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF073D32), Color(0xFF0B6B55), Color(0xFF108266)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient electricGradient = LinearGradient(
    colors: [Color(0xFF0B6B55), Color(0xFF20B77A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF0B2721), Color(0xFF17473B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = electricGradient;

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF0B6B55), Color(0xFF20B77A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFFF59E0B), // Food
    Color(0xFF06B6D4), // Transport
    Color(0xFFF59E0B), // Shopping
    Color(0xFFF43F5E), // Health
    Color(0xFF8B5CF6), // Entertainment
    Color(0xFF0B6B55), // Utilities
    Color(0xFFFFC247), // Education
    Color(0xFFF97316), // Travel
  ];
}
