import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/finance_state.dart';
import '../../core/services/finance_api.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_section_header.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<_NoticeItem> _notices = FinanceState.notifications.map(_noticeFromApi).toList();

  _NoticeItem _noticeFromApi(Map<String, dynamic> row) {
    final type = (row['notification_type'] ?? 'system').toString();
    final created = DateTime.tryParse((row['created_at'] ?? '').toString())?.toLocal();
    final time = _relativeTime(created);
    return _NoticeItem(
      id: row['id'].toString(),
      icon: type.contains('budget') ? Icons.warning_amber_rounded : type.contains('bill')
          ? Icons.event_outlined : type.contains('goal') ? Icons.track_changes_rounded : Icons.notifications_outlined,
      title: (row['title'] ?? '').toString(),
      body: (row['body'] ?? '').toString(),
      time: time,
      color: type.contains('budget') ? AppColors.warning : type.contains('security') ? AppColors.expense : AppColors.primary,
      category: type.replaceAll('_', ' '),
      isUnread: row['is_read'] != true,
    );
  }

  String _relativeTime(DateTime? created) {
    if (created == null) return '';
    final age = DateTime.now().difference(created);
    if (age.inDays > 0) return '${age.inDays}d ago';
    if (age.inHours > 0) return '${age.inHours}h ago';
    return '${age.inMinutes}m ago';
  }

  Future<void> _markAllAsRead() async {
    try {
      await FinanceApi.instance.markAllNotificationsRead();
      setState(() {
        for (final notice in _notices) { notice.isUnread = false; }
      });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
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
              child: _notices.isEmpty
                  ? const EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'No notifications yet',
                      description: 'Alerts will appear here when your account has updates.',
                    )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: _notices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notice = _notices[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (notice.isUnread) {
                          try {
                            await FinanceApi.instance.markNotificationRead(notice.id);
                            if (mounted) setState(() => notice.isUnread = false);
                          } catch (error) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                          }
                        }
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
  final String id;
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final Color color;
  final String category;
  bool isUnread;

  _NoticeItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.color,
    required this.category,
    this.isUnread = false,
  });
}
