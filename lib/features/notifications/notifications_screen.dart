import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groups = _buildNotifications();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                children: [
                  Text('Notifications', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, letterSpacing: -1)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text('Mark all read', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: groups.entries.map((e) => _buildGroup(e.key, e.value, isDark)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<_Notification>> _buildNotifications() {
    return {
      'Today': [
        _Notification(icon: '⚠️', title: 'Budget Alert', body: 'Your Shopping budget is 97% full. Only \$11.01 remaining.', time: '2h ago', color: AppColors.warning, isUnread: true),
        _Notification(icon: '💰', title: 'Salary Received', body: 'TechCorp Inc. deposited \$5,200.00 to your account.', time: '3h ago', color: AppColors.success, isUnread: true),
        _Notification(icon: '📅', title: 'Bill Due Soon', body: 'Netflix subscription (\$15.99) is due in 2 days.', time: '5h ago', color: AppColors.accent, isUnread: false),
      ],
      'Yesterday': [
        _Notification(icon: '🏆', title: 'Savings Milestone!', body: 'You\'ve saved \$3,200 towards your Europe Vacation goal. 64% complete!', time: '1d ago', color: AppColors.primary, isUnread: false),
        _Notification(icon: '🤖', title: 'AI Weekly Report', body: 'Your weekly financial report is ready. You spent 12% less than last week!', time: '1d ago', color: const Color(0xFF8B5CF6), isUnread: false),
      ],
      'This Week': [
        _Notification(icon: '🔴', title: 'Unusual Spending', body: 'We detected an unusual transaction of \$420.00 at Delta Airlines.', time: '3d ago', color: AppColors.expense, isUnread: false),
        _Notification(icon: '💡', title: 'Tip of the Week', body: 'Switching to meal prep could save you up to \$120 per month on dining out.', time: '5d ago', color: AppColors.warning, isUnread: false),
      ],
    };
  }

  Widget _buildGroup(String label, List<_Notification> notifs, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, letterSpacing: 0.5)),
        ),
        ...notifs.asMap().entries.map((e) => _buildNotifCard(e.value, isDark, e.key)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNotifCard(_Notification n, bool isDark, int index) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      borderColor: n.isUnread ? n.color.withOpacity(0.4) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: n.color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(n.icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(n.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight))),
                    if (n.isUnread) Container(width: 8, height: 8, decoration: BoxDecoration(color: n.color, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(n.time, style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(n.body, style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 50), duration: 400.ms).slideY(begin: 0.05);
  }
}

class _Notification {
  final String icon;
  final String title;
  final String body;
  final String time;
  final Color color;
  final bool isUnread;
  _Notification({required this.icon, required this.title, required this.body, required this.time, required this.color, required this.isUnread});
}
