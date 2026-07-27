import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Analytics', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, letterSpacing: -1)).animate().fadeIn(duration: 400.ms),
                  Text('July 2026', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 16),

                  // Tab bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400),
                      labelColor: Colors.white,
                      unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      tabs: const [Tab(text: 'Weekly'), Tab(text: 'Monthly'), Tab(text: 'Yearly')],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Chart content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildScrollableContent(isDark),
                  _buildScrollableContent(isDark),
                  _buildScrollableContent(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildSummaryRow(isDark),
        const SizedBox(height: 16),
        _buildIncomeVsExpenseChart(isDark),
        const SizedBox(height: 16),
        _buildSpendingPieChart(isDark),
        const SizedBox(height: 16),
        _buildCategoryBreakdown(isDark),
        const SizedBox(height: 16),
        _buildAIInsightsCard(isDark),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSummaryRow(bool isDark) {
    return Row(
      children: [
        Expanded(child: _miniStat('Total Spent', '\$1,450', AppColors.expense, Icons.arrow_upward_rounded, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _miniStat('Total Earned', '\$6,000', AppColors.income, Icons.arrow_downward_rounded, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _miniStat('Net Savings', '\$4,550', AppColors.accent, Icons.savings_rounded, isDark)),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _miniStat(String label, String value, Color color, IconData icon, bool isDark) {
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, letterSpacing: -0.5)),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        ],
      ),
    );
  }

  Widget _buildIncomeVsExpenseChart(bool isDark) {
    final incomeData = MockData.monthlyIncome;
    final expenseData = MockData.monthlyExpenses;
    final labels = MockData.monthLabels;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Income vs Expenses', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            const Spacer(),
            _legendDot('Income', AppColors.income),
            const SizedBox(width: 12),
            _legendDot('Expense', AppColors.expense),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 7000,
                minY: 0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '\$${rod.toY.toStringAsFixed(0)}',
                        GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) => Text(labels[v.toInt()], style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (v) => FlLine(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(labels.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(toY: incomeData[i], gradient: AppColors.incomeGradient, width: 10, borderRadius: BorderRadius.circular(4)),
                      BarChartRodData(toY: expenseData[i], gradient: AppColors.expenseGradient, width: 10, borderRadius: BorderRadius.circular(4)),
                    ],
                    barsSpace: 4,
                  );
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 500.ms);
  }

  Widget _buildSpendingPieChart(bool isDark) {
    final data = MockData.categorySpending.entries.toList();
    final total = data.fold<double>(0, (s, e) => s + e.value);

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending by Category', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                              _touchedPieIndex = -1;
                              return;
                            }
                            _touchedPieIndex = response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      centerSpaceRadius: 52,
                      sectionsSpace: 3,
                      sections: List.generate(data.length, (i) {
                        final isTouched = i == _touchedPieIndex;
                        return PieChartSectionData(
                          value: data[i].value,
                          color: AppColors.categoryColors[i % AppColors.categoryColors.length],
                          radius: isTouched ? 52 : 44,
                          title: '',
                          showTitle: false,
                        );
                      }),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 400),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(data.take(5).length, (i) {
                  final cat = MockData.categoryById(data[i].key);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.categoryColors[i % AppColors.categoryColors.length], borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 8),
                        Text(cat.name.split(' ').first, style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        const SizedBox(width: 8),
                        Text('${(data[i].value / total * 100).toStringAsFixed(0)}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms, duration: 500.ms);
  }

  Widget _buildCategoryBreakdown(bool isDark) {
    final data = MockData.categorySpending.entries.toList();
    final max = data.fold<double>(0, (m, e) => e.value > m ? e.value : m);

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Breakdown', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          const SizedBox(height: 16),
          ...data.map((entry) {
            final cat = MockData.categoryById(entry.key);
            final pct = entry.value / max;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(cat.icon, color: cat.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(cat.name.split(' ').first, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                            const Spacer(),
                            Text('\$${entry.value.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: cat.color.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 500.ms);
  }

  Widget _buildAIInsightsCard(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Insights', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
        const SizedBox(height: 12),
        ...MockData.aiInsights.take(3).map((insight) {
          final colors = {
            'warning': AppColors.warning,
            'success': AppColors.success,
            'danger': AppColors.expense,
            'info': AppColors.accent,
          };
          final color = colors[insight['type']] ?? AppColors.accent;
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(insight['icon']!, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(insight['title']!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                      const SizedBox(height: 4),
                      Text(insight['body']!, style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, height: 1.4)),
                    ],
                  ),
                ),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ],
            ),
          );
        }),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }

  Widget _legendDot(String label, Color color) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight)),
    ]);
  }
}
