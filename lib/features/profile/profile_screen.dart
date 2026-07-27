import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final bool isDarkMode;

  const ProfileScreen({super.key, this.onThemeToggle, this.isDarkMode = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  bool _biometrics = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, isDark ? const Color(0xFF1A3A4A) : const Color(0xFF0F3460)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 32, left: 24, right: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Profile', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.settings_rounded, color: Colors.white70), onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Container(
                        width: 88, height: 88,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 24)],
                        ),
                        child: Center(child: Text('AJ', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white))),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Alex Johnson', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('alex.johnson@email.com', style: GoogleFonts.inter(fontSize: 14, color: Colors.white54)),
                  const SizedBox(height: 16),
                  // Premium badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text('Premium Member', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stat('18', 'Transactions', Colors.white),
                      Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2)),
                      _stat('6', 'Budgets', Colors.white),
                      Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2)),
                      _stat('5', 'Goals', Colors.white),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Settings card
                  _buildSection('Preferences', [
                    _buildSwitchTile('Dark Mode', Icons.dark_mode_rounded, widget.isDarkMode, const Color(0xFF8B5CF6), onChanged: (v) { if (widget.onThemeToggle != null) widget.onThemeToggle!(); }, isDark: isDark),
                    _buildSwitchTile('Notifications', Icons.notifications_rounded, _notifications, AppColors.warning, onChanged: (v) => setState(() => _notifications = v), isDark: isDark),
                    _buildSwitchTile('Biometric Auth', Icons.fingerprint_rounded, _biometrics, AppColors.primary, onChanged: (v) => setState(() => _biometrics = v), isDark: isDark),
                  ], isDark),

                  const SizedBox(height: 16),

                  _buildSection('Account', [
                    _buildNavTile('Currency', Icons.currency_exchange_rounded, 'USD', AppColors.success, isDark),
                    _buildNavTile('Language', Icons.language_rounded, 'English', AppColors.accent, isDark),
                    _buildNavTile('Export Data', Icons.download_rounded, null, AppColors.primary, isDark),
                    _buildNavTile('Linked Accounts', Icons.account_balance_rounded, '2 banks', const Color(0xFF8B5CF6), isDark),
                  ], isDark),

                  const SizedBox(height: 16),

                  _buildSection('Security', [
                    _buildNavTile('Change Password', Icons.lock_rounded, null, AppColors.warning, isDark),
                    _buildNavTile('Privacy Policy', Icons.privacy_tip_rounded, null, AppColors.accent, isDark),
                    _buildNavTile('Terms of Service', Icons.description_rounded, null, AppColors.textSecondaryLight, isDark),
                  ], isDark),

                  const SizedBox(height: 20),

                  // Logout
                  PremiumButton(
                    label: 'Log Out',
                    onPressed: () {},
                    isOutlined: true,
                    icon: Icons.logout_rounded,
                    gradient: AppColors.expenseGradient,
                  ),

                  const SizedBox(height: 8),

                  Text('MyFinance v1.0.0 · Built with ❤️', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)),

                  const SizedBox(height: 80),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
    ]);
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        PremiumCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: children.asMap().entries.map((e) {
              final isLast = e.key == children.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast) Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String label, IconData icon, bool value, Color color, {required ValueChanged<bool> onChanged, required bool isDark}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNavTile(String label, IconData icon, String? trailing, Color color, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) Text(trailing, style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 18, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
        ],
      ),
      onTap: () {},
    );
  }
}
