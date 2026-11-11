import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/brand/app_brand.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      tag: 'FINANCIAL MANAGEMENT',
      title: 'A Clearer View of\nYour Money',
      subtitle: 'See what you own, what you spend, and what comes next in one unified, calm financial dashboard.',
      icon: Icons.account_balance_wallet_outlined,
      graphicType: _GraphicType.balanceCard,
    ),
    _SlideData(
      tag: 'SPENDING & BUDGETS',
      title: 'Master Your\nSpending Limits',
      subtitle: 'Set smart category envelopes and stay on track with automated reminders before exceeding limits.',
      icon: Icons.pie_chart_outline_rounded,
      graphicType: _GraphicType.budgetEnvelopes,
    ),
    _SlideData(
      tag: 'SAVINGS & GOALS',
      title: 'Reach Milestones\nFaster Than Ever',
      subtitle: 'Set targets for vacations, emergency funds, or house deposits with visual milestone tracking.',
      icon: Icons.track_changes_rounded,
      graphicType: _GraphicType.savingsMilestones,
    ),
    _SlideData(
      tag: 'INSIGHTS & ANALYTICS',
      title: 'Data-Driven\nFinancial Clarity',
      subtitle: 'Understand long-term trends and uncover opportunities to optimize your cash flow every month.',
      icon: Icons.insights_rounded,
      graphicType: _GraphicType.analyticsChart,
    ),
  ];

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with Logo & Skip Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.emeraldCardGradient,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      AppBrand.mark,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppBrand.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: _goToLogin,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Vector Illustrated Card Composition
                        Expanded(
                          child: Center(
                            child: _buildVectorGraphic(slide.graphicType, isDark),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primaryLight.withOpacity(0.2)
                                : AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            slide.tag,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: isDark ? AppColors.accentLight : AppColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Title
                        Text(
                          slide.title,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          slide.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            height: 1.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation & Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 8, 26, 12),
              child: Row(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _slides.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 6,
                      dotWidth: 6,
                      activeDotColor: isDark ? AppColors.accent : AppColors.primary,
                      dotColor: isDark ? const Color(0xFF26372D) : const Color(0xFFD6DCD4),
                      expansionFactor: 3.5,
                      spacing: 5,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        if (isLast) {
                          _goToLogin();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLast ? 'Get Started' : 'Continue',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Already have account prompt
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextButton(
                onPressed: _goToLogin,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: Text(
                  'Already have an account? Sign in',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVectorGraphic(_GraphicType type, bool isDark) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340, maxHeight: 290),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xFFEFF4ED),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E9DF),
          width: 1,
        ),
      ),
      child: Center(
        child: switch (type) {
          _GraphicType.balanceCard => _buildBalanceGraphic(isDark),
          _GraphicType.budgetEnvelopes => _buildBudgetGraphic(isDark),
          _GraphicType.savingsMilestones => _buildMilestoneGraphic(isDark),
          _GraphicType.analyticsChart => _buildAnalyticsGraphic(isDark),
        },
      ),
    );
  }

  Widget _buildBalanceGraphic(bool isDark) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.emeraldCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wallet_rounded, size: 14, color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, size: 12, color: AppColors.accentLight),
                    const SizedBox(width: 3),
                    Text('+8.2%', style: GoogleFonts.inter(fontSize: 10, color: AppColors.accentLight, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('TOTAL BALANCE', style: GoogleFonts.inter(fontSize: 9.5, letterSpacing: 1.0, color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text('\$24,750.80', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Income +\$6,000', style: GoogleFonts.inter(fontSize: 10, color: AppColors.accentLight, fontWeight: FontWeight.w500)),
                Text('Expenses -\$1,450', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFFCA5A5), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetGraphic(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEnvelopItem('Food & Dining', 0.76, '\$458.50', '\$600.00', AppColors.categoryColors[0], isDark),
        const SizedBox(height: 10),
        _buildEnvelopItem('Transport', 0.61, '\$183.30', '\$300.00', AppColors.categoryColors[1], isDark),
        const SizedBox(height: 10),
        _buildEnvelopItem('Shopping', 0.97, '\$388.99', '\$400.00', AppColors.warning, isDark),
      ],
    );
  }

  Widget _buildEnvelopItem(String name, double pct, String spent, String limit, Color color, bool isDark) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              Text('$spent / $limit', style: GoogleFonts.inter(fontSize: 10.5, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E9E2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneGraphic(bool isDark) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Europe Vacation', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                    Text('180 days remaining', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('64%', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.success)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$3,200', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              Text('Target \$5,000', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.64,
              minHeight: 6,
              backgroundColor: Color(0xFFE5E9E2),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGraphic(bool isDark) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Cash Flow', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              Text('Jul 2026', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(40, isDark),
              _buildBar(65, isDark),
              _buildBar(50, isDark),
              _buildBar(85, isDark, isHighlight: true),
              _buildBar(60, isDark),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDarkSecondary : const Color(0xFFF3F7F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Net savings rate grew +14% this month',
                    style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, bool isDark, {bool isHighlight = false}) {
    return Container(
      width: 24,
      height: height,
      decoration: BoxDecoration(
        color: isHighlight
            ? (isDark ? AppColors.accent : AppColors.primary)
            : (isDark ? AppColors.borderDark : const Color(0xFFD3DDD1)),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

enum _GraphicType {
  balanceCard,
  budgetEnvelopes,
  savingsMilestones,
  analyticsChart,
}

class _SlideData {
  final String tag;
  final String title;
  final String subtitle;
  final IconData icon;
  final _GraphicType graphicType;

  const _SlideData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.graphicType,
  });
}
