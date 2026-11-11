import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/data/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/app_section_header.dart';
import '../../widgets/period_selector.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriodIndex = 1; // 0: Weekly, 1: Monthly, 2: Yearly
  int _touchedPieIndex = -1;

  final List<String> _periods = ['Weekly', 'Monthly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSectionHeader(
                      title: 'Financial Analytics',
                      subtitle: DateFormat('MMMM yyyy').format(DateTime.now()),
                    ),
                    const SizedBox(height: 14),
                    PeriodSelector(
                      options: _periods,
                      selectedIndex: _selectedPeriodIndex,
                      onSelected: (i) =>
                          setState(() => _selectedPeriodIndex = i),
                    ),
                  ],
                ),
              ),
            ),

            // Cash Flow Summary Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Period Cash Flow',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.income.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+75.8% Savings Rate',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.income,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFlowItem(
                              label: 'Total Inflow',
                              amount: MockData.monthlyIncomeCurrent,
                              color: AppColors.income,
                              icon: Icons.arrow_downward_rounded,
                              isDark: isDark,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 38,
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          Expanded(
                            child: _buildFlowItem(
                              label: 'Total Outflow',
                              amount: MockData.monthlyExpenseCurrent,
                              color: isDark
                                  ? const Color(0xFFF87171)
                                  : AppColors.expense,
                              icon: Icons.arrow_upward_rounded,
                              isDark: isDark,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 38,
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          Expanded(
                            child: _buildFlowItem(
                              label: 'Net Preserved',
                              amount: MockData.savingsThisMonth,
                              color: isDark
                                  ? AppColors.accentLight
                                  : AppColors.primary,
                              icon: Icons.savings_outlined,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Spending by Category Donut Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
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
                      Text(
                        'Spending by Category',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Donut Chart
                      SizedBox(
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          response == null ||
                                          response.touchedSection == null) {
                                        _touchedPieIndex = -1;
                                        return;
                                      }
                                      _touchedPieIndex = response
                                          .touchedSection!
                                          .touchedSectionIndex;
                                    });
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 3,
                                centerSpaceRadius: 52,
                                sections: _buildPieSections(),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total Spent',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.textTertiaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                Text(
                                  '\$${Formatters.amount(MockData.monthlyExpenseCurrent)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.4,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Category Breakdown Legend Rows
                      ..._buildCategoryLegendList(isDark),
                    ],
                  ),
                ),
              ),
            ),

            // Monthly Trends Bar Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
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
                          Expanded(
                            child: Text(
                              'Income vs Expenses Trend',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDotLegend(
                                'Income',
                                AppColors.income,
                                isDark,
                              ),
                              const SizedBox(width: 8),
                              _buildDotLegend(
                                'Expense',
                                isDark
                                    ? const Color(0xFFF87171)
                                    : AppColors.expense,
                                isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 6500,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => isDark
                                    ? AppColors.cardDarkSecondary
                                    : Colors.black87,
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                                      final label = rodIndex == 0
                                          ? 'Income'
                                          : 'Expense';
                                      return BarTooltipItem(
                                        '$label\n\$${rod.toY.toInt()}',
                                        GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      );
                                    },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    final index = val.toInt();
                                    if (index >= 0 &&
                                        index < MockData.monthLabels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          MockData.monthLabels[index],
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? AppColors.textTertiaryDark
                                                : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 2000,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: isDark
                                    ? AppColors.borderDark
                                    : const Color(0xFFEAEFE7),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(
                              MockData.monthLabels.length,
                              (i) {
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: MockData.monthlyIncome[i],
                                      color: AppColors.income,
                                      width: 8,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    BarChartRodData(
                                      toY: MockData.monthlyExpenses[i],
                                      color: isDark
                                          ? const Color(0xFFF87171)
                                          : AppColors.expense,
                                      width: 8,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowItem({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '\$${Formatters.amount(amount)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildDotLegend(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final entries = MockData.categorySpending.entries.take(5).toList();
    final total = entries.fold<double>(0, (s, e) => s + e.value);

    return List.generate(entries.length, (i) {
      final isTouched = i == _touchedPieIndex;
      final e = entries[i];
      final cat = MockData.categoryById(e.key);
      final radius = isTouched ? 32.0 : 26.0;

      return PieChartSectionData(
        color: cat.color,
        value: e.value,
        title: '${((e.value / total) * 100).toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    });
  }

  List<Widget> _buildCategoryLegendList(bool isDark) {
    final entries = MockData.categorySpending.entries.take(5).toList();
    final total = entries.fold<double>(0, (s, e) => s + e.value);

    return entries.map((e) {
      final cat = MockData.categoryById(e.key);
      final pct = (e.value / total) * 100;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: cat.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                cat.name,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            Text(
              '${pct.toStringAsFixed(0)}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '\$${Formatters.amount(e.value)}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
