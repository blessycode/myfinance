import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/premium_button.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Track Every\nExpense',
      subtitle: 'Stay on top of your spending with beautiful, real-time expense tracking and smart categorization.',
      emoji: '💳',
      gradient: AppColors.primaryGradient,
      bgColors: [const Color(0xFF064E3B), const Color(0xFF0F172A)],
      accentColor: AppColors.primary,
    ),
    _OnboardingData(
      title: 'Smart Budgets\nThat Work',
      subtitle: 'Set intelligent budgets, receive alerts before you overspend, and watch your money grow.',
      emoji: '🎯',
      gradient: AppColors.accentGradient,
      bgColors: [const Color(0xFF0C4A6E), const Color(0xFF0F172A)],
      accentColor: AppColors.accent,
    ),
    _OnboardingData(
      title: 'AI Financial\nInsights',
      subtitle: 'Get personalized AI-powered insights and recommendations to optimize your financial health.',
      emoji: '🤖',
      gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      bgColors: [const Color(0xFF3B0764), const Color(0xFF0F172A)],
      accentColor: const Color(0xFF8B5CF6),
    ),
    _OnboardingData(
      title: 'Achieve Your\nFinancial Goals',
      subtitle: 'Set, track, and celebrate your financial milestones — from vacation funds to house deposits.',
      emoji: '🏆',
      gradient: AppColors.goldGradient,
      bgColors: [const Color(0xFF78350F), const Color(0xFF0F172A)],
      accentColor: AppColors.warning,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
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
    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) => _OnboardingPage(data: _pages[index]),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotWidth: 8,
                      dotHeight: 8,
                      activeDotColor: _pages[_currentPage].accentColor,
                      dotColor: Colors.white.withOpacity(0.3),
                      expansionFactor: 4,
                      spacing: 6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      if (_currentPage < _pages.length - 1) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: _goToLogin,
                            child: Center(
                              child: Text('Skip', style: GoogleFonts.inter(color: Colors.white60, fontSize: 15, fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        flex: 2,
                        child: PremiumButton(
                          label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                          onPressed: _nextPage,
                          gradient: LinearGradient(
                            colors: [_pages[_currentPage].accentColor, _pages[_currentPage].accentColor.withOpacity(0.7)],
                          ),
                          icon: _currentPage == _pages.length - 1 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.bgColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Background orbs
          Positioned(top: -60, right: -60, child: _orb(180, data.accentColor.withOpacity(0.15))),
          Positioned(top: 100, left: -80, child: _orb(160, data.accentColor.withOpacity(0.08))),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Emoji illustration
                  Center(
                    child: Container(
                      width: size.width * 0.65,
                      height: size.width * 0.65,
                      decoration: BoxDecoration(
                        gradient: data.gradient,
                        borderRadius: BorderRadius.circular(48),
                        boxShadow: [
                          BoxShadow(color: data.accentColor.withOpacity(0.4), blurRadius: 60, spreadRadius: 10),
                        ],
                      ),
                      child: Center(
                        child: Text(data.emoji, style: const TextStyle(fontSize: 100)),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOut),

                  const SizedBox(height: 52),

                  Text(
                    data.title,
                    style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1, letterSpacing: -1.5),
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideX(begin: -0.1),

                  const SizedBox(height: 16),

                  Text(
                    data.subtitle,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white60, height: 1.7, letterSpacing: 0.1),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideX(begin: -0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(double size, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _OnboardingData {
  final String title;
  final String subtitle;
  final String emoji;
  final LinearGradient gradient;
  final List<Color> bgColors;
  final Color accentColor;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.bgColors,
    required this.accentColor,
  });
}
