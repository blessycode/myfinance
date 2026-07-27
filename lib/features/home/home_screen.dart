import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';
import '../../core/providers/theme_provider.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transactions_screen.dart';
import '../analytics/analytics_screen.dart';
import '../budgets/budgets_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    final themeProvider = context.watch<ThemeProvider>();
    switch (_navIndex) {
      case 0: return const _HomeTab();
      case 1: return const TransactionsScreen();
      case 2: return const AnalyticsScreen();
      case 3: return const BudgetsScreen();
      case 4: return ProfileScreen(onThemeToggle: themeProvider.toggle, isDarkMode: themeProvider.isDark);
      default: return const _HomeTab();
    }
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3000.ms, color: Colors.white.withOpacity(0.2));
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.cardDark : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.4 : 0.08), blurRadius: 24, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _navItem(1, Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Transactions'),
              const SizedBox(width: 64),
              _navItem(2, Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Analytics'),
              _navItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData active, IconData inactive, String label) {
    final isSelected = _navIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? active : inactive, color: isSelected ? AppColors.primary : AppColors.textTertiaryLight, size: 24),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.primary : AppColors.textTertiaryLight)),
          ],
        ),
      ),
    );
  }
}

// ── Home Tab ────────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, isDark)),
        SliverToBoxAdapter(child: _buildBalanceCard(context)),
        SliverToBoxAdapter(child: _buildQuickActions(context)),
        SliverToBoxAdapter(child: _buildAIScore(context)),
        SliverToBoxAdapter(child: _buildCategoryGrid(context)),
        SliverToBoxAdapter(child: _buildRecentTransactions(context)),
        SliverToBoxAdapter(child: _buildUpcomingBills(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.backgroundDark, AppColors.backgroundDark]
              : [AppColors.backgroundLight, AppColors.backgroundLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 24, right: 24, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good Morning,', style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                Text('Alex Johnson 👋', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, letterSpacing: -0.5)),
              ],
            ),
          ),
          // Notification bell
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.notifications_rounded, size: 22, color: AppColors.textSecondaryLight)),
                Positioned(top: 10, right: 10, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.expense, shape: BoxShape.circle))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Text('AJ', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1A3A4A), Color(0xFF064E3B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: Stack(
          children: [
            // Background orb
            Positioned(top: -30, right: -30, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.12)))),
            Positioned(bottom: -20, left: 20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withOpacity(0.08)))),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Total Balance', style: GoogleFonts.inter(fontSize: 13, color: Colors.white54, letterSpacing: 0.5)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Row(children: [
                          const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text('+8.2%', style: GoogleFonts.inter(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${Formatters.amount(MockData.totalBalance)}',
                    style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -2),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _statItem('Income', MockData.monthlyIncomeCurrent, AppColors.success, Icons.arrow_downward_rounded)),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.15)),
                      Expanded(child: _statItem('Expenses', MockData.monthlyExpenseCurrent, AppColors.expense, Icons.arrow_upward_rounded)),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.15)),
                      Expanded(child: _statItem('Savings', MockData.savingsThisMonth, AppColors.accent, Icons.savings_rounded)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1),
    );
  }

  Widget _statItem(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text('\$${Formatters.amount(amount)}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.add_circle_rounded, 'label': 'Expense', 'color': AppColors.expense, 'bg': const Color(0xFFEF444415)},
      {'icon': Icons.trending_up_rounded, 'label': 'Income', 'color': AppColors.income, 'bg': const Color(0xFF22C55E15)},
      {'icon': Icons.document_scanner_rounded, 'label': 'Scan', 'color': AppColors.accent, 'bg': const Color(0xFF06B6D415)},
      {'icon': Icons.swap_horiz_rounded, 'label': 'Transfer', 'color': const Color(0xFF8B5CF6), 'bg': const Color(0xFF8B5CF615)},
      {'icon': Icons.pie_chart_rounded, 'label': 'Budget', 'color': AppColors.warning, 'bg': const Color(0xFFF59E0B15)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((a) {
              return IconPillButton(
                icon: a['icon'] as IconData,
                label: a['label'] as String,
                color: a['color'] as Color,
                backgroundColor: a['bg'] as Color,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
    );
  }

  Widget _buildAIScore(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: PremiumCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 44,
              lineWidth: 8,
              percent: MockData.aiHealthScore / 100,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${MockData.aiHealthScore.toInt()}', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  Text('/100', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiaryLight)),
                ],
              ),
              progressColor: AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1200,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('AI Financial Health', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ]),
                  const SizedBox(height: 4),
                  Text('Excellent', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('Your finances are in great shape! Keep maintaining your savings rate.', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topCategories = MockData.categories.where((c) => c.id != 'income' && c.id != 'freelance').take(6).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          const SizedBox(height: 14),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.3, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: topCategories.length,
            itemBuilder: (context, index) {
              final cat = topCategories[index];
              final spending = MockData.categorySpending[cat.id] ?? 0;
              return PremiumCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(cat.icon, color: cat.color, size: 18),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.name.split(' ').first, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        Text('\$${spending.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ).animate().fadeIn(delay: 350.ms, duration: 500.ms),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recent = MockData.transactions.take(5).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text('Recent Transactions', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Text('See All', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PremiumCard(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recent.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
              itemBuilder: (context, index) {
                final t = recent[index];
                final cat = MockData.categoryById(t.categoryId);
                final isIncome = t.type == TransactionType.income;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(cat.icon, color: cat.color, size: 22),
                  ),
                  title: Text(t.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  subtitle: Text(Formatters.relativeDate(t.date), style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  trailing: Text(
                    '${isIncome ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: isIncome ? AppColors.income : AppColors.expense),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
    );
  }

  Widget _buildUpcomingBills(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Bills', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          const SizedBox(height: 14),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.bills.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final bill = MockData.bills[index];
                final isDueSoon = bill.isDueSoon;
                return PremiumCard(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: bill.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                          child: Icon(bill.icon, color: bill.color, size: 18),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bill.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                            Text('\$${bill.amount.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                            Text('Due in ${bill.daysUntilDue}d', style: GoogleFonts.inter(fontSize: 11, color: isDueSoon ? AppColors.warning : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ).animate().fadeIn(delay: 450.ms, duration: 500.ms),
    );
  }
}


