import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Semantic, calibrated typography scale built on Inter.
abstract final class AppTextStyles {
  static TextStyle displayLarge(BuildContext context) => Theme.of(context).textTheme.displayLarge!;
  static TextStyle displayMedium(BuildContext context) => Theme.of(context).textTheme.displayMedium!;
  static TextStyle displaySmall(BuildContext context) => Theme.of(context).textTheme.displaySmall!;
  static TextStyle headlineLarge(BuildContext context) => Theme.of(context).textTheme.headlineLarge!;
  static TextStyle headlineMedium(BuildContext context) => Theme.of(context).textTheme.headlineMedium!;
  static TextStyle headlineSmall(BuildContext context) => Theme.of(context).textTheme.headlineSmall!;
  static TextStyle titleLarge(BuildContext context) => Theme.of(context).textTheme.titleLarge!;
  static TextStyle titleMedium(BuildContext context) => Theme.of(context).textTheme.titleMedium!;
  static TextStyle titleSmall(BuildContext context) => Theme.of(context).textTheme.titleSmall!;
  static TextStyle bodyLarge(BuildContext context) => Theme.of(context).textTheme.bodyLarge!;
  static TextStyle bodyMedium(BuildContext context) => Theme.of(context).textTheme.bodyMedium!;
  static TextStyle bodySmall(BuildContext context) => Theme.of(context).textTheme.bodySmall!;
  static TextStyle labelLarge(BuildContext context) => Theme.of(context).textTheme.labelLarge!;
  static TextStyle labelMedium(BuildContext context) => Theme.of(context).textTheme.labelMedium!;
  static TextStyle labelSmall(BuildContext context) => Theme.of(context).textTheme.labelSmall!;

  // Tabular financial figure styles
  static TextStyle moneyHero({Color color = Colors.white}) => GoogleFonts.inter(
    fontSize: 34,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle moneyLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle moneyMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle moneySmall({Color? color}) => GoogleFonts.inter(
    fontSize: 13.5,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // Micro badges & tags
  static TextStyle badge({required Color color}) => GoogleFonts.inter(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: color,
  );
}
