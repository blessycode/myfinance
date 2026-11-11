import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/app_section_header.dart';
import '../../widgets/goal_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  void _openContributeSheet(Goal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountCtrl = TextEditingController(text: '100.00');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contribute to ${goal.name}',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Funds will be allocated from your Everyday Account.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Contribution Amount (USD)',
                prefixText: '\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  final added = double.tryParse(amountCtrl.text) ?? 50.0;
                  final index = MockData.goals.indexWhere((g) => g.id == goal.id);
                  if (index != -1) {
                    final current = MockData.goals[index];
                    setState(() {
                      MockData.goals[index] = Goal(
                        id: current.id,
                        name: current.name,
                        emoji: current.emoji,
                        target: current.target,
                        saved: (current.saved + added).clamp(0.0, current.target * 1.5),
                        deadline: current.deadline,
                        color: current.color,
                        backgroundColor: current.backgroundColor,
                      );
                    });
                  }
                  Navigator.pop(sheetCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Contributed \$${added.toStringAsFixed(2)} to ${goal.name}!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Confirm Contribution', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateGoalSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '2500.00');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set a New Financial Goal',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Target what matters to you and track your steady milestone progression.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: nameCtrl,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g. Dream Vacation, New Car',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: targetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Target Amount (USD)',
                prefixText: '\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  final target = double.tryParse(targetCtrl.text) ?? 1000.0;
                  final name = nameCtrl.text.trim().isNotEmpty
                      ? nameCtrl.text.trim()
                      : 'New Goal';
                  setState(() {
                    MockData.goals.add(
                      Goal(
                        id: 'g_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        emoji: '🎯',
                        target: target,
                        saved: 0.0,
                        deadline: DateTime.now().add(const Duration(days: 120)),
                        color: AppColors.primary,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                      ),
                    );
                  });
                  Navigator.pop(sheetCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Created goal: $name'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Create Goal', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalTarget = MockData.goals.fold<double>(0, (s, g) => s + g.target);
    final totalSaved = MockData.goals.fold<double>(0, (s, g) => s + g.saved);
    final overallProgress = (totalSaved / totalTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
                child: AppSectionHeader(
                  title: 'Savings Goals',
                  subtitle: 'Steady progress toward your financial milestones',
                  actionLabel: '+ New Goal',
                  onAction: _openCreateGoalSheet,
                ),
              ),
            ),

            // Goals Progress Hero Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cumulative Milestone Savings',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.primaryLight.withOpacity(0.2) : AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${(overallProgress * 100).toStringAsFixed(0)}% Overall',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.accentLight : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${Formatters.amount(totalSaved)}',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'of \$${Formatters.amount(totalTarget)} target',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: overallProgress,
                          minHeight: 8,
                          backgroundColor: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E9E2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.accent : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Goals list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final goal = MockData.goals[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GoalCard(
                        goal: goal,
                        onContribute: () => _openContributeSheet(goal),
                      ),
                    );
                  },
                  childCount: MockData.goals.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
