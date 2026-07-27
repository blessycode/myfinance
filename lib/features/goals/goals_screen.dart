import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Goals', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, letterSpacing: -1)).animate().fadeIn(),
                  Text('Chase your dreams, one goal at a time', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...MockData.goals.asMap().entries.map((e) => _buildGoalCard(e.value, isDark, e.key)),
                  const SizedBox(height: 16),
                  PremiumButton(
                    label: 'Create New Goal',
                    icon: Icons.add_circle_outline_rounded,
                    onPressed: () {},
                    isOutlined: true,
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

  Widget _buildGoalCard(Goal goal, bool isDark, int index) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Text(goal.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                    Text('${goal.daysRemaining} days remaining', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: goal.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  goal.isCompleted ? '✅ Done!' : '${(goal.percentage * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: goal.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('\$${goal.saved.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, letterSpacing: -0.5)),
                        Text(' / \$${goal.target.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('\$${goal.remaining.toStringAsFixed(0)} remaining', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              CircularPercentIndicator(
                radius: 36,
                lineWidth: 6,
                percent: goal.percentage,
                center: Text('${(goal.percentage * 100).toStringAsFixed(0)}%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: goal.color)),
                progressColor: goal.color,
                backgroundColor: goal.color.withOpacity(0.12),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1000 + index * 200,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.percentage,
              backgroundColor: goal.color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
              minHeight: 10,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 80), duration: 400.ms).slideY(begin: 0.1);
  }
}
