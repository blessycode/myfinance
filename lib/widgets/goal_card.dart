import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/models/models.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onContribute;
  final VoidCallback? onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onContribute,
    this.onTap,
  });

  IconData _getGoalIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('vacation') || lower.contains('trip')) return Icons.flight_takeoff_rounded;
    if (lower.contains('fund') || lower.contains('emergency')) return Icons.shield_outlined;
    if (lower.contains('macbook') || lower.contains('laptop') || lower.contains('tech')) return Icons.laptop_mac_rounded;
    if (lower.contains('deposit') || lower.contains('house') || lower.contains('home')) return Icons.home_work_outlined;
    if (lower.contains('car') || lower.contains('vehicle')) return Icons.directions_car_rounded;
    return Icons.savings_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = goal.percentage;
    final isDone = goal.isCompleted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon, Title, Days remaining, and Done badge
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      _getGoalIcon(goal.name),
                      color: goal.color,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDone ? 'Goal Achieved' : '${goal.daysRemaining} days remaining',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: isDone
                                ? AppColors.success
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.success.withOpacity(0.12)
                          : (isDark ? AppColors.primaryLight.withOpacity(0.2) : AppColors.primary.withOpacity(0.08)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      isDone ? 'Completed' : '${(progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDone ? AppColors.success : (isDark ? AppColors.accentLight : AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Saved vs Target figures
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$${Formatters.amount(goal.saved)}',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'of \$${Formatters.amount(goal.target)}',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7.5,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFE5E9E2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDone ? AppColors.success : (isDark ? AppColors.accent : AppColors.primary),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Quick Contribute action
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onContribute,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Contribute'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: isDark ? AppColors.accentLight : AppColors.primary,
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
