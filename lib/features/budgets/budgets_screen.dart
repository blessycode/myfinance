import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/app_section_header.dart';
import '../../widgets/budget_progress_card.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({
    super.key,
  });

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {

  void _openAddBudgetSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController();
    final limitCtrl = TextEditingController(text: '300.00');
    String selectedCategory = 'food';

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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Budget',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Set an envelope limit to receive proactive alerts as you spend.',
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
                  labelText: 'Budget Name',
                  hintText: 'e.g. Groceries, Entertainment',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: limitCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  labelText: 'Monthly Limit (USD)',
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
                    final limit = double.tryParse(limitCtrl.text) ?? 200.0;
                    final name = nameCtrl.text.trim().isNotEmpty
                        ? nameCtrl.text.trim()
                        : 'New Budget';
                    setState(() {
                      MockData.budgets.add(
                        Budget(
                          id: 'b_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          categoryId: selectedCategory,
                          limit: limit,
                          spent: 0.0,
                          month: DateTime.now(),
                          color: AppColors.primary,
                        ),
                      );
                    });
                    Navigator.pop(sheetCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Created budget for $name'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Save Budget', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalLimit = MockData.budgets.fold<double>(0, (s, b) => s + b.limit);
    final totalSpent = MockData.budgets.fold<double>(0, (s, b) => s + b.spent);
    final totalRemaining = totalLimit - totalSpent;
    final totalUsage = (totalSpent / totalLimit).clamp(0.0, 1.0);

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
                  title: 'Monthly Budgets',
                  subtitle: DateFormat('MMMM yyyy').format(DateTime.now()),
                  actionLabel: '+ New Budget',
                  onAction: _openAddBudgetSheet,
                ),
              ),
            ),

            // Overall Monthly Budget Health Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.emeraldCardGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircularPercentIndicator(
                        radius: 44,
                        lineWidth: 7.5,
                        percent: totalUsage,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(totalUsage * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'USED',
                              style: GoogleFonts.inter(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        progressColor: AppColors.accentLight,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        animationDuration: 800,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL BUDGET SPENT',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '\$${Formatters.amount(totalSpent)}',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'of \$${Formatters.amount(totalLimit)} limit · \$${Formatters.amount(totalRemaining)} remaining',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Envelopes List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final budget = MockData.budgets[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BudgetProgressCard(
                        budget: budget,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${budget.name}: \$${Formatters.amount(budget.spent)} spent of \$${Formatters.amount(budget.limit)} limit'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: MockData.budgets.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
