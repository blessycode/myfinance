import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            // Decorative orbs
            Positioned(top: -80, right: -80, child: _buildOrb(200, AppColors.primary.withOpacity(0.15))),
            Positioned(bottom: -100, left: -60, child: _buildOrb(250, AppColors.accent.withOpacity(0.10))),
            Positioned(top: 200, left: -40, child: _buildOrb(120, AppColors.primary.withOpacity(0.08))),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 40, spreadRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 56),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, curve: Curves.easeOut),

                  const SizedBox(height: 28),

                  Text('MyFinance', style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1))
                      .animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2),

                  const SizedBox(height: 8),

                  Text('Smart Money Management', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white54, letterSpacing: 0.5))
                      .animate().fadeIn(delay: 500.ms, duration: 600.ms),

                  const SizedBox(height: 80),

                  // Loading indicator
                  SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 3,
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                ],
              ),
            ),

            // Bottom tagline
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Text(
                'Your financial future starts here',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white30, letterSpacing: 0.3),
              ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
