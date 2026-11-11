import 'package:flutter/material.dart';

/// Central Design System Color Tokens.
/// Upgraded to a modern luxury obsidian-slate & electric mint/emerald aesthetic.
abstract final class AppColors {
  // Primary Palette - Vivid Mint & Emerald
  static const Color primary = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF047857);

  // Secondary - Deep Midnight Slate
  static const Color secondary = Color(0xFF0F172A);
  static const Color secondaryLight = Color(0xFF1E293B);

  // Accent - Electric Mint
  static const Color accent = Color(0xFF00D09C);
  static const Color accentLight = Color(0xFF5EEAD4);
  static const Color accentDark = Color(0xFF0D9488);

  // Semantic Financial Indicators
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFF43F5E);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);

  // Canvas & Backgrounds - Light Mode
  static const Color backgroundLight = Color(0xFFF6F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardLightSecondary = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFEDF2F7);

  // Canvas & Backgrounds - Dark Mode (Obsidian Slate)
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color surfaceDark = Color(0xFF101726);
  static const Color cardDark = Color(0xFF151F32);
  static const Color cardDarkSecondary = Color(0xFF1C283F);
  static const Color borderDark = Color(0xFF24344E);
  static const Color dividerDark = Color(0xFF1E2C42);

  // Text Hierarchy - Light
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Text Hierarchy - Dark
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // Gradients
  static const LinearGradient emeraldCardGradient = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF0F766E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient electricGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF00D09C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF101726), Color(0xFF182238)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = electricGradient;

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
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
    Color(0xFF10B981), // Food
    Color(0xFF06B6D4), // Transport
    Color(0xFFF59E0B), // Shopping
    Color(0xFFF43F5E), // Health
    Color(0xFF8B5CF6), // Entertainment
    Color(0xFF14B8A6), // Utilities
    Color(0xFF84CC16), // Education
    Color(0xFFF97316), // Travel
  ];
}
