import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Budgets', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, letterSpacing: -1)).animate().fadeIn(duration: 400.ms),
                  Text('July 2026 · 7 days remaining', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 16),

                  // Total budget overview
                  _buildTotalCard(isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Budget list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Text('Your Budgets', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  const SizedBox(height: 14),
                  ...MockData.budgets.asMap().entries.map((e) => _buildBudgetCard(e.value, isDark, e.key)),
                  const SizedBox(height: 16),
                  PremiumButton(
                    label: 'Add New Budget',
                    onPressed: () {},
                    isOutlined: true,
                    icon: Icons.add_rounded,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(bool isDark) {
    final totalLimit = MockData.budgets.fold<double>(0, (s, b) => s + b.limit);
    final totalSpent = MockData.budgets.fold<double>(0, (s, b) => s + b.spent);
    final pct = totalSpent / totalLimit;

    return PremiumCard(
      gradient: AppColors.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Monthly Overview', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, letterSpacing: 0.5)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text('${(pct * 100).toStringAsFixed(0)}% used', style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\$${totalSpent.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
                    Text('of \$${totalLimit.toStringAsFixed(0)} budgeted', style: GoogleFonts.inter(fontSize: 13, color: Colors.white60)),
                  ],
                ),
              ),
              CircularPercentIndicator(
                radius: 44,
                lineWidth: 7,
                percent: pct.clamp(0.0, 1.0),
                center: Text('${(pct * 100).toStringAsFixed(0)}%', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                progressColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1000,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms);
  }

  Widget _buildBudgetCard(Budget budget, bool isDark, int index) {
    final cat = MockData.categoryById(budget.categoryId);
    final pct = budget.percentage;
    final statusColor = budget.isExceeded ? AppColors.expense : budget.isWarning ? AppColors.warning : AppColors.success;
    final statusLabel = budget.isExceeded ? 'Exceeded' : budget.isWarning ? 'Almost full' : 'On track';

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(cat.icon, color: cat.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(budget.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                    Row(children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text(statusLabel, style: GoogleFonts.inter(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500)),
                    ]),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${budget.spent.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  Text('of \$${budget.limit.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: budget.color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(budget.isExceeded ? AppColors.expense : budget.isWarning ? AppColors.warning : budget.color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${(pct * 100).toStringAsFixed(0)}% spent', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              const Spacer(),
              Text('\$${budget.remaining.toStringAsFixed(0)} left', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: budget.isExceeded ? AppColors.expense : isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 200 + index * 60), duration: 400.ms).slideY(begin: 0.1);
  }
}
