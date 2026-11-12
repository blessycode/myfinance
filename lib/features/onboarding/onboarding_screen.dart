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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(AppBrand.logoAsset, fit: BoxFit.cover),
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
    final icon = switch (type) {
      _GraphicType.balanceCard => Icons.account_balance_wallet_outlined,
      _GraphicType.budgetEnvelopes => Icons.pie_chart_outline_rounded,
      _GraphicType.savingsMilestones => Icons.track_changes_rounded,
      _GraphicType.analyticsChart => Icons.insights_rounded,
    };
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340, maxHeight: 290),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xFFEFF4ED),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E9DF)),
      ),
      child: Center(
        child: Container(
          width: 132,
          height: 132,
          decoration: BoxDecoration(
            gradient: AppColors.emeraldCardGradient,
            borderRadius: BorderRadius.circular(38),
            boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 10))],
          ),
          child: Icon(icon, size: 62, color: Colors.white),
        ),
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
