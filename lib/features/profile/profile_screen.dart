import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brand/app_brand.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/services/currency_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/settings_tile.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final bool isDarkMode;
  final VoidCallback? onDataChanged;

  const ProfileScreen({
    super.key,
    this.onThemeToggle,
    this.isDarkMode = false,
    this.onDataChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedCurrency = MockData.primaryCurrency;
  bool _biometricsEnabled = true;
  bool _budgetAlerts = true;
  bool _billReminders = true;
  bool _weeklySummary = true;

  void _openCurrencyPicker() async {
    const currencies = [
      ('USD', 'United States Dollar (\$) - Base', '🇺🇸'),
      ('EUR', 'Euro (€) - 1.09 USD', '🇪🇺'),
      ('GBP', 'British Pound (£) - 1.28 USD', '🇬🇧'),
      ('ZAR', 'South African Rand (R) - 0.055 USD', '🇿🇦'),
      ('ZWG', 'Zimbabwe Gold (ZiG) - 0.038 USD', '🇿🇼'),
      ('BWP', 'Botswana Pula (P) - 0.074 USD', '🇧🇼'),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Primary Display Currency',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All multi-currency accounts and transactions are converted in real-time to your primary view.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...currencies.map((c) {
                    final isSelected = _selectedCurrency == c.$1;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: Text(c.$3, style: const TextStyle(fontSize: 22)),
                      title: Text(
                        c.$1,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      subtitle: Text(
                        c.$2,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 20)
                          : null,
                      onTap: () => Navigator.pop(ctx, c.$1),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedCurrency = selected;
        MockData.primaryCurrency = selected;
      });
      widget.onDataChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Primary currency updated to $selected. Portfolio converted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openAccountsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (ctx) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connected Accounts',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                '${MockData.accounts.length} multi-currency accounts active',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _openAddAccountDialog();
                          },
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add Account'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...MockData.accounts.map((acc) {
                      final sym = CurrencyService.getSymbol(acc.currency);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: (acc.color ?? AppColors.primary).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(acc.icon, color: acc.color ?? AppColors.primary, size: 18),
                        ),
                        title: Text(
                          acc.name,
                          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${acc.type} · ${acc.currency}',
                          style: GoogleFonts.inter(fontSize: 11.5, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        trailing: Text(
                          '$sym${Formatters.amount(acc.balance)}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openAddAccountDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController(text: '1000.00');
    String selectedType = 'Bank Account';
    String selectedCurrency = 'USD';

    final types = ['Bank Account', 'Savings', 'Cash Wallet', 'Mobile Money', 'Investment', 'Credit Card'];
    final currencies = ['USD', 'EUR', 'GBP', 'ZAR', 'ZWG', 'BWP'];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              4,
              24,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Account',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track accounts in USD, EUR, GBP, ZAR, ZiG, or Pula.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Account Name',
                      hintText: 'e.g. Barclays Checking, EcoCash, Euro Card',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Account Type',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: types.map((t) {
                      final isSelected = selectedType == t;
                      return ChoiceChip(
                        label: Text(t),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedType = t);
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Account Currency',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currencies.map((c) {
                      final isSelected = selectedCurrency == c;
                      return ChoiceChip(
                        label: Text(c),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedCurrency = c);
                        },
                        selectedColor: AppColors.accent,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: balanceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      labelText: 'Starting Balance ($selectedCurrency)',
                      prefixText: '${CurrencyService.getSymbol(selectedCurrency)} ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        final balance = double.tryParse(balanceCtrl.text) ?? 0.0;
                        final name = nameCtrl.text.trim().isNotEmpty
                            ? nameCtrl.text.trim()
                            : '$selectedCurrency $selectedType';

                        IconData icon = Icons.account_balance_outlined;
                        Color color = AppColors.primary;
                        if (selectedType.contains('Savings')) {
                          icon = Icons.savings_outlined;
                          color = const Color(0xFF3B82F6);
                        } else if (selectedType.contains('Mobile')) {
                          icon = Icons.phone_android_rounded;
                          color = const Color(0xFFF59E0B);
                        } else if (selectedType.contains('Investment')) {
                          icon = Icons.show_chart_rounded;
                          color = const Color(0xFF8B5CF6);
                        } else if (selectedType.contains('Credit')) {
                          icon = Icons.credit_card_rounded;
                          color = const Color(0xFFEC4899);
                        } else if (selectedType.contains('Cash')) {
                          icon = Icons.wallet_outlined;
                          color = const Color(0xFF14B8A6);
                        }

                        setState(() {
                          MockData.accounts.add(
                            AccountSummary(
                              id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              type: selectedType,
                              currency: selectedCurrency,
                              balance: balance,
                              icon: icon,
                              color: color,
                            ),
                          );
                        });
                        widget.onDataChanged?.call();
                        Navigator.pop(sheetCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added $name (${CurrencyService.format(balance, selectedCurrency)})'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Create Account', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign Out of ${AppBrand.name}?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You will return to the welcome screen. Your locally stored demonstration data will be preserved.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetCtx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.expense,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(content, style: GoogleFonts.inter(fontSize: 13.5, height: 1.5)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalPortfolio = CurrencyService.calculateTotalIn(MockData.accounts, _selectedCurrency);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar / Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
                child: Text(
                  'Account & Settings',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),

            // Profile Header Identity Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.025),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isDark ? AppColors.primary : AppColors.primary,
                        child: Text(
                          'AJ',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Alex Johnson',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: AppColors.income,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'alex.johnson@email.com',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.primary.withOpacity(0.2) : AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'PRO PLAN',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.accentLight : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Account Stats Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDarkSecondary : const Color(0xFFEFF4ED),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE2E9DF),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Total Portfolio', '${CurrencyService.getSymbol(_selectedCurrency)}${Formatters.amount(totalPortfolio)}', isDark),
                      Container(width: 1, height: 28, color: isDark ? AppColors.borderDark : const Color(0xFFD6DED3)),
                      _buildStatColumn('Accounts', '${MockData.accounts.length} Linked', isDark),
                      Container(width: 1, height: 28, color: isDark ? AppColors.borderDark : const Color(0xFFD6DED3)),
                      _buildStatColumn('Health Score', '85 / 100', isDark),
                    ],
                  ),
                ),
              ),
            ),

            // Section 1: Financial & Personal Preferences
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SettingsGroup(
                  title: 'Financial & Personal Preferences',
                  children: [
                    SettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Details',
                      subtitle: 'Alex Johnson · +1 (555) 019-2834',
                      onTap: () => _showInfoDialog(
                        'Personal Information',
                        'Name: Alex Johnson\nEmail: alex.johnson@email.com\nPhone: +1 (555) 019-2834\nRegion: United States (USD)\nKYC Status: Verified (Level 2)',
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.currency_exchange_rounded,
                      title: 'Primary Display Currency',
                      subtitle: 'Active base: $_selectedCurrency · Live conversion enabled',
                      trailingText: _selectedCurrency,
                      onTap: _openCurrencyPicker,
                    ),
                    SettingsTile(
                      icon: Icons.account_balance_outlined,
                      title: 'Connected Accounts',
                      subtitle: '${MockData.accounts.length} accounts configured',
                      trailingText: '+ Add / Manage',
                      onTap: _openAccountsSheet,
                    ),
                  ],
                ),
              ),
            ),

            // Section 2: Security & Privacy
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SettingsGroup(
                  title: 'Security & Privacy',
                  children: [
                    SettingsTile(
                      icon: Icons.fingerprint_rounded,
                      title: 'Biometric Unlock',
                      subtitle: 'Require Face ID / Fingerprint on launch',
                      trailing: Switch.adaptive(
                        value: _biometricsEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _biometricsEnabled = v),
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Application PIN & Password',
                      subtitle: 'Update your 6-digit passcode',
                      onTap: () => _showInfoDialog(
                        'Security Credentials',
                        'Password and PIN are securely encrypted using device hardware keystore.',
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.devices_rounded,
                      title: 'Active Sessions',
                      subtitle: '1 active mobile device (This Device)',
                      onTap: () => _showInfoDialog('Active Sessions', 'This Device: Active Now\nLocation: Local Sandbox Environment'),
                    ),
                  ],
                ),
              ),
            ),

            // Section 3: Notifications
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SettingsGroup(
                  title: 'Notifications & Alerts',
                  children: [
                    SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Budget Threshold Alerts',
                      subtitle: 'Notify when 80% or 100% of envelope is spent',
                      trailing: Switch.adaptive(
                        value: _budgetAlerts,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _budgetAlerts = v),
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.event_outlined,
                      title: 'Upcoming Bill Reminders',
                      subtitle: 'Alert 3 days before renewal dates',
                      trailing: Switch.adaptive(
                        value: _billReminders,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _billReminders = v),
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.insights_outlined,
                      title: 'Weekly Financial Digest',
                      subtitle: 'Weekly overview of spending and savings',
                      trailing: Switch.adaptive(
                        value: _weeklySummary,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _weeklySummary = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section 4: Appearance & System
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SettingsGroup(
                  title: 'Appearance',
                  children: [
                    SettingsTile(
                      icon: widget.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      title: 'Dark Mode',
                      subtitle: widget.isDarkMode ? 'Obsidian Slate Palette' : 'Clean Modern Canvas',
                      trailing: Switch.adaptive(
                        value: widget.isDarkMode,
                        activeColor: AppColors.accent,
                        onChanged: (_) => widget.onThemeToggle?.call(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section 5: Support & Legal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SettingsGroup(
                  title: 'Support & Legal',
                  children: [
                    SettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center & FAQ',
                      subtitle: 'Multi-currency rates and account linking guide',
                      onTap: () => _showInfoDialog(
                        'Help & Support',
                        'Multi-Currency Support:\nAccounts can be maintained in USD, EUR, GBP, ZAR, ZiG, and BWP. Currency conversions use real-time market peg rates.\n\nSupport Email: support@myfinance.app',
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy & Terms',
                      subtitle: 'How your financial records are protected',
                      onTap: () => _showInfoDialog(
                        'Privacy & Terms',
                        'Financial data is strictly confidential. No card numbers, CVVs, or bank credentials are ever stored insecurely.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section 6: Sign Out
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: SettingsGroup(
                  children: [
                    SettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      subtitle: 'Exit your current session',
                      isDestructive: true,
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ),
            ),

            // Footer Brand Tag
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: Text(
                    '${AppBrand.name.toUpperCase()} · V1.0.0 (BUILD 102)',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
