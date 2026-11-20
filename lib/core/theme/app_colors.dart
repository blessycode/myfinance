import 'package:flutter/material.dart';

/// Central Design System Color Tokens.
/// Blue-violet finance palette inspired by the product reference.
abstract final class AppColors {
  // Primary Palette - Blue Violet
  static const Color primary = Color(0xFF5B5FF5);
  static const Color primaryLight = Color(0xFF7B6CF6);
  static const Color primaryDark = Color(0xFF4746D7);

  // Secondary - Deep Midnight Slate
  static const Color secondary = Color(0xFF0F172A);
  static const Color secondaryLight = Color(0xFF1E293B);

  // Accent - Clear App Blue
  static const Color accent = Color(0xFF2F80ED);
  static const Color accentLight = Color(0xFF79A9FF);
  static const Color accentDark = Color(0xFF1D64D8);

  // Semantic Financial Indicators
  static const Color income = Color(0xFF2F80ED);
  static const Color expense = Color(0xFFF43F5E);
  static const Color success = Color(0xFF4F7DF3);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);

  // Canvas & Backgrounds - Light Mode
  static const Color backgroundLight = Color(0xFFF6F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardLightSecondary = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFEDF2F7);

  // Canvas & Backgrounds - Dark Mode
  static const Color backgroundDark = Color(0xFF0B0D1B);
  static const Color surfaceDark = Color(0xFF121529);
  static const Color cardDark = Color(0xFF191D35);
  static const Color cardDarkSecondary = Color(0xFF222744);
  static const Color borderDark = Color(0xFF303654);
  static const Color dividerDark = Color(0xFF272D49);

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
    colors: [Color(0xFF3977E9), Color(0xFF5B5FF5), Color(0xFF7659EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient electricGradient = LinearGradient(
    colors: [Color(0xFF2F80ED), Color(0xFF745EF5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF15182E), Color(0xFF252A4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = electricGradient;

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF2775E8), Color(0xFF62A1FF)],
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
    Color(0xFF7B5CF5), // Food
    Color(0xFF06B6D4), // Transport
    Color(0xFFF59E0B), // Shopping
    Color(0xFFF43F5E), // Health
    Color(0xFF5B5FF5), // Entertainment
    Color(0xFF2F80ED), // Utilities
    Color(0xFFFFC247), // Education
    Color(0xFFF97316), // Travel
  ];
}
