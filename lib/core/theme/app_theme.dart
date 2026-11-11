import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: primary,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: primary,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: primary,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: primary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 12.5,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13.5,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: tertiary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 11.5,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 10.5,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: tertiary,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceLight,
        error: AppColors.expense,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _buildTextTheme(
        primary: AppColors.textPrimaryLight,
        secondary: AppColors.textSecondaryLight,
        tertiary: AppColors.textTertiaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textTertiaryLight,
          fontSize: 13.5,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.accent,
        secondary: AppColors.accentLight,
        surface: AppColors.surfaceDark,
        error: AppColors.expense,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _buildTextTheme(
        primary: AppColors.textPrimaryDark,
        secondary: AppColors.textSecondaryDark,
        tertiary: AppColors.textTertiaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textTertiaryDark,
          fontSize: 13.5,
        ),
      ),
    );
  }
}
