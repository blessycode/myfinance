import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_section_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<_NoticeItem> _notices = [
    _NoticeItem(
      icon: Icons.warning_amber_rounded,
      title: 'Budget Alert: Shopping at 97%',
      body: 'Your Shopping budget is approaching its limit. Only \$11.01 remains for this period.',
      time: '2h ago',
      color: AppColors.warning,
      isUnread: true,
      category: 'Budget',
    ),
    _NoticeItem(
      icon: Icons.south_west_rounded,
      title: 'Direct Deposit Received',
      body: 'A \$5,200.00 payroll deposit from TechCorp Inc. was credited to Everyday Account.',
      time: '3h ago',
      color: AppColors.income,
      isUnread: true,
      category: 'Deposit',
    ),
    _NoticeItem(
      icon: Icons.event_outlined,
      title: 'Upcoming Bill: Netflix',
      body: 'Netflix subscription for \$15.99 is scheduled to renew in 2 days.',
      time: '5h ago',
      color: AppColors.categoryColors[4],
      isUnread: false,
      category: 'Bill',
    ),
    _NoticeItem(
      icon: Icons.track_changes_rounded,
      title: 'Milestone Progress: Europe Vacation',
      body: 'Congratulations! Your vacation savings goal is now 64% funded (\$3,200 / \$5,000).',
      time: 'Yesterday',
      color: AppColors.primary,
      isUnread: false,
      category: 'Goal',
    ),
    _NoticeItem(
      icon: Icons.insights_rounded,
      title: 'Weekly Financial Digest Ready',
      body: 'You preserved \$1,450.75 in savings this week with lower dining out expenses.',
      time: 'Yesterday',
      color: AppColors.categoryColors[1],
      isUnread: false,
      category: 'Insight',
    ),
    _NoticeItem(
      icon: Icons.receipt_long_outlined,
      title: 'Review Large Transaction',
      body: 'A \$420.00 purchase at Delta Airlines was recorded. Confirm the category assignment.',
      time: '3 days ago',
      color: AppColors.expense,
      isUnread: false,
      category: 'Security',
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (final n in _notices) {
        n.isUnread = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 20, 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppSectionHeader(
                      title: 'Notifications',
                      subtitle: 'Alerts, scheduled bills and financial updates',
                      actionLabel: 'Mark all read',
                      onAction: _markAllAsRead,
                    ),
                  ),
                ],
              ),
            ),

            // Notification List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: _notices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notice = _notices[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (notice.isUnread) setState(() => notice.isUnread = false);
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: notice.isUnread
                                ? (isDark ? AppColors.primaryLight : AppColors.primary.withOpacity(0.4))
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            width: notice.isUnread ? 1.4 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.025),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: notice.color.withOpacity(isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(notice.icon, color: notice.color, size: 19),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notice.title,
                                          style: GoogleFonts.inter(
                                            fontSize: 13.5,
                                            fontWeight: notice.isUnread ? FontWeight.w700 : FontWeight.w600,
                                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                          ),
                                        ),
                                      ),
                                      if (notice.isUnread)
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      const SizedBox(width: 6),
                                      Text(
                                        notice.time,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notice.body,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeItem {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final Color color;
  final String category;
  bool isUnread;

  _NoticeItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.color,
    required this.category,
    this.isUnread = false,
  });
}
