import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _obscure = true;
  bool _isLoading = false;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  void _submit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Background orbs
              Positioned(top: -50, right: -50, child: _orb(180, AppColors.primary.withOpacity(0.12))),
              Positioned(bottom: 100, left: -60, child: _orb(220, AppColors.accent.withOpacity(0.08))),

              // Content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Logo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 36),
                    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 24),

                    Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',
                      style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 8),

                    Text(
                      _isLogin ? 'Sign in to manage your finances' : 'Start your financial journey today',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 36),

                    // Form card
                    GlassCard(
                      child: Column(
                        children: [
                          if (!_isLogin) ...[
                            _buildField(label: 'Full Name', hint: 'John Doe', icon: Icons.person_rounded),
                            const SizedBox(height: 16),
                          ],
                          _buildField(label: 'Email', hint: 'you@example.com', icon: Icons.email_rounded, controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildPasswordField(),
                          if (_isLogin) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('Forgot Password?', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
                            ),
                          ],
                          const SizedBox(height: 24),
                          PremiumButton(label: _isLogin ? 'Sign In' : 'Create Account', onPressed: _submit, isLoading: _isLoading),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                    const SizedBox(height: 24),

                    // Divider
                    Row(children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or continue with', style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                    ]).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 20),

                    // Social buttons
                    Row(
                      children: [
                        Expanded(child: _socialButton('Google', '🌐', const Color(0xFF4285F4))),
                        const SizedBox(width: 12),
                        Expanded(child: _socialButton('Apple', '🍎', Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(child: _bioButton(Icons.fingerprint_rounded, 'Biometric')),
                      ],
                    ).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 32),

                    // Toggle
                    GestureDetector(
                      onTap: () => setState(() => _isLogin = !_isLogin),
                      child: RichText(
                        text: TextSpan(
                          text: _isLogin ? "Don't have an account? " : 'Already have an account? ',
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
                          children: [
                            TextSpan(
                              text: _isLogin ? 'Sign Up' : 'Sign In',
                              style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white60, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.white38, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white60, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 14),
              prefixIcon: const Icon(Icons.lock_rounded, color: Colors.white38, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white38, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialButton(String label, String emoji, Color color) {
    return GestureDetector(
      onTap: _submit,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Center(
          child: Text('$emoji  $label', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
        ),
      ),
    );
  }

  Widget _bioButton(IconData icon, String label) {
    return GestureDetector(
      onTap: _submit,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Center(child: Icon(icon, color: Colors.white70, size: 24)),
      ),
    );
  }

  Widget _orb(double size, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
