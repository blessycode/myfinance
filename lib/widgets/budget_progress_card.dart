import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/models/models.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';

class BudgetProgressCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onTap;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = budget.percentage;
    final isExceeded = budget.isExceeded;
    final isWarning = budget.isWarning && !isExceeded;

    final Color statusColor = isExceeded
        ? AppColors.expense
        : (isWarning ? AppColors.warning : AppColors.primary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon, Name and Status Pill
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: budget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.pie_chart_rounded,
                      color: budget.color,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isExceeded
                              ? 'Exceeded by \$${Formatters.amount(budget.spent - budget.limit)}'
                              : '\$${Formatters.amount(budget.remaining)} remaining',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isExceeded
                                ? AppColors.expense
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExceeded ? 'Exceeded' : '${(progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Custom rounded progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFE5E9E2),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),

              const SizedBox(height: 10),

              // Spent vs Total Limit numbers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent: \$${Formatters.amount(budget.spent)}',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    'Limit: \$${Formatters.amount(budget.limit)}',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
