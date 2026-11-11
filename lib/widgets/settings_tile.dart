import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class SettingsGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SettingsGroup({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title!.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 52,
                    endIndent: 16,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDestructive
        ? (isDark ? const Color(0xFFF87171) : AppColors.expense)
        : (iconColor ?? (isDark ? AppColors.accent : AppColors.primary));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Icon with subtle rounded background
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.expense.withOpacity(isDark ? 0.2 : 0.08)
                      : (iconColor != null
                          ? iconColor!.withOpacity(isDark ? 0.2 : 0.09)
                          : (isDark ? AppColors.primaryLight.withOpacity(0.2) : AppColors.primary.withOpacity(0.08))),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: primaryColor,
                ),
              ),

              const SizedBox(width: 14),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? (isDark ? const Color(0xFFF87171) : AppColors.expense)
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing widget or text
              if (trailingText != null) ...[
                const SizedBox(width: 8),
                Text(
                  trailingText!,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],

              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ] else if (onTap != null && !isDestructive) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 19,
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
