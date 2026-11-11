import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class PeriodSelector extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const PeriodSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xFFEFF3EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? (isDark ? AppColors.surfaceDark : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.5),
                    boxShadow: selectedIndex == i
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      options[i],
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: selectedIndex == i ? FontWeight.w600 : FontWeight.w500,
                        color: selectedIndex == i
                            ? (isDark ? AppColors.textPrimaryDark : AppColors.primary)
                            : (isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
