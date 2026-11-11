import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurAmount;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 24,
    this.blurAmount = 20,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.boxShadow,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final defaultBorder = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE7E8E1);
    final defaultShadow = isDark
        ? [BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 12, offset: const Offset(0, 4))]
        : [BoxShadow(color: Colors.black.withOpacity(0.025), blurRadius: 10, offset: const Offset(0, 3))];

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? (backgroundColor ?? defaultBg) : null,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? defaultBorder,
              width: borderWidth,
            ),
            boxShadow: boxShadow ?? defaultShadow,
          ),
          child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(margin: margin, child: card),
      );
    }
    return Container(margin: margin, child: card);
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 24,
    this.color,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
    final shadows = isDark
        ? [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))]
        : [BoxShadow(color: Colors.black.withOpacity(0.025), blurRadius: 10, offset: const Offset(0, 3))];

    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? bg : null,
        border: gradient == null ? Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight) : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(margin: margin, child: card),
      );
    }
    return Container(margin: margin, child: card);
  }
}
