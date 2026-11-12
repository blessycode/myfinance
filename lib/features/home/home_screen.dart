import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/data/finance_state.dart';
import '../../core/models/models.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/finance_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/account_card.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/financial_balance_card.dart';
import '../../widgets/transaction_tile.dart';
import '../analytics/analytics_screen.dart';
import '../budgets/budgets_screen.dart';
import '../goals/goals_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  void _refresh() => setState(() {});

  Future<void> _openNotifications() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeTab(
            onOpenNotifications: _openNotifications,
            onOpenProfile: () => setState(() => _navIndex = 4),
            onOpenAnalytics: () => setState(() => _navIndex = 1),
            onOpenBudgets: () => setState(() => _navIndex = 2),
            onOpenGoals: () => setState(() => _navIndex = 3),
            onDataChanged: _refresh,
          ),
          const AnalyticsScreen(),
          const BudgetsScreen(),
          const GoalsScreen(),
          ProfileScreen(
            onThemeToggle: themeProvider.toggle,
            isDarkMode: isDark,
            onDataChanged: _refresh,
          ),
        ],
      ),
      // Floating Action Button â€” bottom-right, above the nav bar
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.electricGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: _showQuickActionsSheet,
          tooltip: 'Add Transaction or Account',
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) => setState(() => _navIndex = index),
      ),
    );
  }

  void _showQuickActionsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Actions',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Record multi-currency transactions, move money, or add accounts.',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSheetActionTile(
                    sheetContext: sheetContext,
                    icon: Icons.north_east_rounded,
                    title: 'Add an Expense',
                    subtitle:
                        'Record a purchase, bill, or service in any currency',
                    color: AppColors.expense,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(
                            initialType: TransactionType.expense,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  _buildSheetActionTile(
                    sheetContext: sheetContext,
                    icon: Icons.south_west_rounded,
                    title: 'Add Income',
                    subtitle: 'Record salary, dividends, or freelance earnings',
                    color: AppColors.income,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(
                            initialType: TransactionType.income,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  _buildSheetActionTile(
                    sheetContext: sheetContext,
                    icon: Icons.account_balance_rounded,
                    title: 'Add New Account',
                    subtitle:
                        'Create a bank, wallet or card in USD, EUR, GBP, ZAR, ZiG',
                    color: AppColors.accent,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showAddAccountSheet();
                    },
                  ),
                  _buildSheetActionTile(
                    sheetContext: sheetContext,
                    icon: Icons.swap_horiz_rounded,
                    title: 'Transfer Money',
                    subtitle: 'Move funds between your multi-currency accounts',
                    color: AppColors.info,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showTransferSheet();
                    },
                  ),
                  _buildSheetActionTile(
                    sheetContext: sheetContext,
                    icon: Icons.savings_outlined,
                    title: 'Add to Savings Goal',
                    subtitle:
                        'Contribute toward your vacation, laptop, or house fund',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() => _navIndex = 3);
                    },
                  ),
                  _buildSheetActionTile(
                    sheetContext: sheetContext,
                    icon: Icons.event_repeat_rounded,
                    title: 'Add Recurring Bill',
                    subtitle: 'Track the next renewal date and amount',
                    color: AppColors.info,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showSubscriptionSheet();
                    },
                  ),
                  _buildSheetActionTile(
                    sheetContext: sheetContext,
                    icon: Icons.receipt_long_outlined,
                    title: 'Track a Debt',
                    subtitle: 'Record money owed by you or to you',
                    color: AppColors.categoryColors[2],
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showDebtSheet();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddAccountSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController(text: '0.00');
    String selectedType = 'Bank Account';
    String selectedCurrency = FinanceState.primaryCurrency;

    final types = [
      'Bank Account',
      'Savings',
      'Cash Wallet',
      'Mobile Money',
      'Investment',
      'Credit Card',
    ];
    final currencies = CurrencyService.rates.keys.toList();

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
                    'Add Financial Account',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Support for multiple currencies at once with live conversions.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Account Name',
                      hintText: 'e.g. Barclays Checking, EcoCash, Euro Card',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Account Type',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Currency',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: balanceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Starting Balance ($selectedCurrency)',
                      prefixText:
                          '${CurrencyService.getSymbol(selectedCurrency)} ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () async {
                        final balance =
                            double.tryParse(balanceCtrl.text) ?? 0.0;
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

                        try {
                          await FinanceApi.instance.addAccount(
                            name: name,
                            accountType: selectedType,
                            currency: selectedCurrency,
                            openingBalance: balance,
                            color:
                                '#${color.value.toRadixString(16).substring(2)}',
                            icon: 'account_balance_rounded',
                          );
                          if (!mounted || !sheetCtx.mounted) return;
                          setState(() {});
                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added $name'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (error) {
                          if (sheetCtx.mounted) {
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Add Account',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
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

  Widget _buildSheetActionTile({
    required BuildContext sheetContext,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.2 : 0.09),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 19,
        color: isDark
            ? AppColors.textTertiaryDark
            : AppColors.textTertiaryLight,
      ),
      onTap: onTap,
    );
  }

  void _showTransferSheet() {
    if (FinanceState.accounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Create at least two accounts to transfer between them.',
          ),
        ),
      );
      return;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    var from = FinanceState.accounts.first;
    var to = FinanceState.accounts[1];
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var transferDate = DateTime.now();
    final dateLabel = () => '${transferDate.year}-${transferDate.month.toString().padLeft(2, '0')}-${transferDate.day.toString().padLeft(2, '0')}';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, rebuildSheet) => Padding(
          padding: EdgeInsets.fromLTRB(22, 8, 22, MediaQuery.of(sheetContext).viewInsets.bottom + 22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transfer money', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Choose any two of your accounts. Currency conversion is applied when they differ.', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                const SizedBox(height: 18),
                DropdownButtonFormField<AccountSummary>(
                  value: from,
                  decoration: const InputDecoration(labelText: 'From account', prefixIcon: Icon(Icons.north_east_rounded)),
                  items: FinanceState.accounts.map((account) => DropdownMenuItem(value: account, child: Text('${account.name} · ${account.currency} ${Formatters.amount(account.balance)}', overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (value) { if (value == null) return; rebuildSheet(() { from = value; if (to.id == from.id) to = FinanceState.accounts.firstWhere((account) => account.id != from.id); }); },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AccountSummary>(
                  value: to,
                  decoration: const InputDecoration(labelText: 'To account', prefixIcon: Icon(Icons.south_west_rounded)),
                  items: FinanceState.accounts.where((account) => account.id != from.id).map((account) => DropdownMenuItem(value: account, child: Text('${account.name} · ${account.currency} ${Formatters.amount(account.balance)}', overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (value) { if (value != null) rebuildSheet(() => to = value); },
                ),
                const SizedBox(height: 12),
                TextField(controller: amountCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Amount (${from.currency})', prefixText: '${CurrencyService.getSymbol(from.currency)} ', prefixIcon: const Icon(Icons.payments_outlined))),
                const SizedBox(height: 12),
                TextField(controller: noteCtrl, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Description (optional)', prefixIcon: Icon(Icons.notes_rounded))),
                const SizedBox(height: 12),
                OutlinedButton.icon(onPressed: () async { final picked = await showDatePicker(context: sheetContext, initialDate: transferDate, firstDate: DateTime(2000), lastDate: DateTime.now()); if (picked != null) rebuildSheet(() => transferDate = picked); }, icon: const Icon(Icons.calendar_today_rounded), label: Text('Transfer date · ${dateLabel()}')),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(
                  icon: const Icon(Icons.swap_horiz_rounded), label: const Text('Complete transfer'),
                  onPressed: () async {
                    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                    if (amount <= 0) { ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text('Enter an amount greater than zero.'))); return; }
                    if (amount > from.balance) { ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text('The source account does not have enough funds.'))); return; }
                    try {
                      await FinanceApi.instance.createTransfer({'from_account': from.id, 'to_account': to.id, 'amount': amount.toStringAsFixed(2), 'description': noteCtrl.text.trim().isEmpty ? 'Account transfer' : noteCtrl.text.trim(), 'transaction_date': dateLabel()});
                      await FinanceApi.instance.refresh();
                      if (!mounted || !sheetContext.mounted) return;
                      Navigator.pop(sheetContext); setState(() {});
                    } catch (error) { if (sheetContext.mounted) ScaffoldMessenger.of(sheetContext).showSnackBar(SnackBar(content: Text(error.toString()))); }
                  },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSubscriptionSheet() {
    final name = TextEditingController();
    final merchant = TextEditingController();
    final amount = TextEditingController();
    var dueDate = DateTime.now().add(const Duration(days: 30));
    var frequency = 'monthly';
    var currency = FinanceState.primaryCurrency;
    String dateLabel() => '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, rebuildSheet) => Padding(
          padding: EdgeInsets.fromLTRB(22, 10, 22, MediaQuery.of(sheetContext).viewInsets.bottom + 22),
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add a bill or subscription', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text('Record who you pay, how much, and when it is due.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight)),
              const SizedBox(height: 16),
              TextField(controller: name, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Bill name', hintText: 'e.g. Electricity', prefixIcon: Icon(Icons.receipt_long_rounded))),
              const SizedBox(height: 10),
              TextField(controller: merchant, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Provider', hintText: 'e.g. ZETDC', prefixIcon: Icon(Icons.business_rounded))),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(flex: 2, child: TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.payments_outlined)))),
                const SizedBox(width: 10),
                Expanded(child: DropdownButtonFormField<String>(value: currency, decoration: const InputDecoration(labelText: 'Currency'), items: CurrencyService.rates.keys.map((code) => DropdownMenuItem(value: code, child: Text(code))).toList(), onChanged: (value) { if (value != null) rebuildSheet(() => currency = value); })),
              ]),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(value: frequency, decoration: const InputDecoration(labelText: 'Repeat', prefixIcon: Icon(Icons.repeat_rounded)), items: const [DropdownMenuItem(value: 'weekly', child: Text('Weekly')), DropdownMenuItem(value: 'monthly', child: Text('Monthly')), DropdownMenuItem(value: 'quarterly', child: Text('Every 3 months')), DropdownMenuItem(value: 'yearly', child: Text('Yearly'))], onChanged: (value) { if (value != null) rebuildSheet(() => frequency = value); }),
              const SizedBox(height: 8),
              OutlinedButton.icon(onPressed: () async { final picked = await showDatePicker(context: sheetContext, initialDate: dueDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650))); if (picked != null) rebuildSheet(() => dueDate = picked); }, icon: const Icon(Icons.calendar_today_rounded), label: Text('Next due date · ${dateLabel()}')),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(
                icon: const Icon(Icons.save_rounded), label: const Text('Save bill'),
                onPressed: () async {
                  final value = double.tryParse(amount.text.trim()) ?? 0;
                  if (name.text.trim().isEmpty || merchant.text.trim().isEmpty || value <= 0) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text('Enter a bill name, provider, and amount greater than zero.'))); return;
                  }
                  try {
                    await FinanceApi.instance.createSubscription({'name': name.text.trim(), 'merchant': merchant.text.trim(), 'amount': value.toStringAsFixed(2), 'currency': currency, 'frequency': frequency, 'next_due_date': dateLabel()});
                    await FinanceApi.instance.refresh();
                    if (!mounted || !sheetContext.mounted) return;
                    setState(() {}); Navigator.pop(sheetContext);
                  } catch (error) { if (sheetContext.mounted) ScaffoldMessenger.of(sheetContext).showSnackBar(SnackBar(content: Text(error.toString()))); }
                },
              )),
            ],
          )),
        ),
      ),
    );
  }

  void _showDebtSheet() {
    final name = TextEditingController();
    final counterparty = TextEditingController();
    final amount = TextEditingController();
    final interest = TextEditingController(text: '0');
    var debtType = 'borrowed';
    var currency = FinanceState.primaryCurrency;
    var dueDate = DateTime.now().add(const Duration(days: 30));
    var hasDueDate = true;
    String dateLabel() => '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, rebuildSheet) => Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Debt and repayments', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (FinanceState.debts.isNotEmpty) ...[
                ...FinanceState.debts.where((debt) => debt['is_settled'] != true).map((debt) {
                  final debtCurrency = (debt['currency'] ?? 'USD').toString();
                  final matchingAccounts = FinanceState.accounts.where((account) => account.currency == debtCurrency).toList();
                  return Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text((debt['name'] ?? 'Debt').toString(), style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      Text('${debt['counterparty'] ?? ''} · ${debt['debt_type'] == 'lent' ? 'Owed to you' : 'You owe'}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight)),
                      const SizedBox(height: 4),
                      Text('$debtCurrency ${Formatters.amount(double.tryParse((debt['current_balance'] ?? '0').toString()) ?? 0)} remaining', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      Align(alignment: Alignment.centerRight, child: TextButton.icon(
                        onPressed: matchingAccounts.isEmpty ? null : () => _showDebtPaymentSheet(debt, matchingAccounts, () => rebuildSheet(() {})),
                        icon: const Icon(Icons.payments_outlined),
                        label: Text(debt['debt_type'] == 'lent' ? 'Record collection' : 'Record payment'),
                      )),
                      if (matchingAccounts.isEmpty) Text('Add a $debtCurrency account to record payments.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.warning)),
                    ]),
                  ));
                }),
                const Divider(height: 22),
              ],
              Text(FinanceState.debts.isEmpty ? 'Add a debt to start tracking it.' : 'Add another debt', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextField(controller: name, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Debt name', hintText: 'e.g. Car loan', prefixIcon: Icon(Icons.account_balance_rounded))),
              const SizedBox(height: 10),
              TextField(controller: counterparty, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Lender or person', prefixIcon: Icon(Icons.person_outline_rounded))),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(value: debtType, decoration: const InputDecoration(labelText: 'Debt type'), items: const [DropdownMenuItem(value: 'borrowed', child: Text('Money I owe')), DropdownMenuItem(value: 'lent', child: Text('Money owed to me')), DropdownMenuItem(value: 'credit_card', child: Text('Credit card balance')), DropdownMenuItem(value: 'loan', child: Text('Formal loan'))], onChanged: (value) { if (value != null) rebuildSheet(() => debtType = value); }),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(flex: 2, child: TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Original amount'))),
                const SizedBox(width: 10),
                Expanded(child: DropdownButtonFormField<String>(value: currency, decoration: const InputDecoration(labelText: 'Currency'), items: CurrencyService.rates.keys.map((code) => DropdownMenuItem(value: code, child: Text(code))).toList(), onChanged: (value) { if (value != null) rebuildSheet(() => currency = value); })),
              ]),
              const SizedBox(height: 10),
              TextField(controller: interest, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Interest rate % (optional)', prefixIcon: Icon(Icons.percent_rounded))),
              CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Set a due date'), value: hasDueDate, onChanged: (value) => rebuildSheet(() => hasDueDate = value ?? false)),
              if (hasDueDate) OutlinedButton.icon(onPressed: () async { final picked = await showDatePicker(context: sheetContext, initialDate: dueDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 36500))); if (picked != null) rebuildSheet(() => dueDate = picked); }, icon: const Icon(Icons.calendar_today_rounded), label: Text('Due date · ${dateLabel()}')),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(
                icon: const Icon(Icons.save_rounded), label: const Text('Save debt'),
                onPressed: () async {
                  final value = double.tryParse(amount.text.trim()) ?? 0;
                  final interestRate = double.tryParse(interest.text.trim()) ?? 0;
                  if (name.text.trim().isEmpty || counterparty.text.trim().isEmpty || value <= 0 || interestRate < 0) { ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text('Enter a name, lender, positive amount, and valid interest rate.'))); return; }
                  try {
                    await FinanceApi.instance.createDebt({'name': name.text.trim(), 'debt_type': debtType, 'counterparty': counterparty.text.trim(), 'original_amount': value.toStringAsFixed(2), 'interest_rate': interestRate.toStringAsFixed(2), 'currency': currency, if (hasDueDate) 'due_date': dateLabel()});
                    await FinanceApi.instance.refresh();
                    if (!mounted || !sheetContext.mounted) return;
                    name.clear();
                    counterparty.clear();
                    amount.clear();
                    interest.text = '0';
                    setState(() {}); rebuildSheet(() {});
                  } catch (error) { if (sheetContext.mounted) ScaffoldMessenger.of(sheetContext).showSnackBar(SnackBar(content: Text(error.toString()))); }
                },
              )),
            ],
          )),
        ),
      ),
    );
  }

  void _showDebtPaymentSheet(Map<String, dynamic> debt, List<AccountSummary> accounts, VoidCallback refreshDebtList) {
    final amount = TextEditingController();
    final notes = TextEditingController();
    var account = accounts.first;
    var paymentDate = DateTime.now();
    String dateLabel() => '${paymentDate.year}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}';
    final debtBalance = double.tryParse((debt['current_balance'] ?? '0').toString()) ?? 0;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(builder: (sheetContext, rebuildSheet) => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(debt['debt_type'] == 'lent' ? 'Record a collection' : 'Record a repayment', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${debt['name']} · remaining ${debt['currency']} ${Formatters.amount(debtBalance)}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 14),
          DropdownButtonFormField<AccountSummary>(value: account, decoration: const InputDecoration(labelText: 'Account'), items: accounts.map((item) => DropdownMenuItem(value: item, child: Text('${item.name} · ${item.currency}'))).toList(), onChanged: (value) { if (value != null) rebuildSheet(() => account = value); }),
          const SizedBox(height: 10),
          TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Amount · maximum ${Formatters.amount(debtBalance)}', prefixText: '${CurrencyService.getSymbol(account.currency)} ')),
          const SizedBox(height: 10),
          TextField(controller: notes, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Notes (optional)', prefixIcon: Icon(Icons.notes_rounded))),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: () async { final picked = await showDatePicker(context: sheetContext, initialDate: paymentDate, firstDate: DateTime(2000), lastDate: DateTime.now()); if (picked != null) rebuildSheet(() => paymentDate = picked); }, icon: const Icon(Icons.calendar_today_rounded), label: Text('Payment date · ${dateLabel()}')),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(icon: const Icon(Icons.check_rounded), label: const Text('Save payment'), onPressed: () async {
            final value = double.tryParse(amount.text.trim()) ?? 0;
            if (value <= 0 || value > debtBalance) { ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text('Enter an amount above zero and no greater than the remaining balance.'))); return; }
            try {
              await FinanceApi.instance.payDebt(debt['id'].toString(), {'account': account.id, 'amount': value.toStringAsFixed(2), 'payment_date': dateLabel(), 'notes': notes.text.trim()});
              await FinanceApi.instance.refresh();
              if (!mounted || !sheetContext.mounted) return;
              Navigator.pop(sheetContext); refreshDebtList(); setState(() {});
            } catch (error) { if (sheetContext.mounted) ScaffoldMessenger.of(sheetContext).showSnackBar(SnackBar(content: Text(error.toString()))); }
          })),
        ])),
      )),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Home Tab Presentation
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _HomeTab extends StatefulWidget {
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenAnalytics;
  final VoidCallback onOpenBudgets;
  final VoidCallback onOpenGoals;
  final VoidCallback onDataChanged;

  const _HomeTab({
    required this.onOpenNotifications,
    required this.onOpenProfile,
    required this.onOpenAnalytics,
    required this.onOpenBudgets,
    required this.onOpenGoals,
    required this.onDataChanged,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _isBalanceVisible = true;

  void _showAccountOptions(AccountSummary account) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text('${account.currency} ${Formatters.amount(account.balance)}'),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.expense,
                ),
                title: const Text('Delete account'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete account?'),
                      content: const Text(
                        'The account will be removed. If it has transaction history, it will be archived so that history is kept.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.expense,
                          ),
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  try {
                    await FinanceApi.instance.deleteAccount(account.id);
                    if (!mounted) return;
                    widget.onDataChanged();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Account removed. Its transaction history is kept if it had any.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (error) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.toString()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  void _showAddAccountSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController(text: '0.00');
    String selectedType = 'Bank Account';
    String selectedCurrency = FinanceState.primaryCurrency;

    final types = [
      'Bank Account',
      'Savings',
      'Cash Wallet',
      'Mobile Money',
      'Investment',
      'Credit Card',
    ];
    final currencies = CurrencyService.rates.keys.toList();

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
                    'Add Financial Account',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Multi-currency accounts update total portfolio value in real-time.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Account Name',
                      hintText: 'e.g. Barclays Checking, EcoCash, Euro Card',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Account Type',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Currency',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: balanceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Starting Balance ($selectedCurrency)',
                      prefixText:
                          '${CurrencyService.getSymbol(selectedCurrency)} ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () async {
                        final balance =
                            double.tryParse(balanceCtrl.text) ?? 0.0;
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

                        try {
                          await FinanceApi.instance.addAccount(
                            name: name,
                            accountType: selectedType,
                            currency: selectedCurrency,
                            openingBalance: balance,
                            color:
                                '#${color.value.toRadixString(16).substring(2)}',
                            icon: 'account_balance_rounded',
                          );
                          if (!mounted || !sheetCtx.mounted) return;
                          widget.onDataChanged();
                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added $name'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (error) {
                          if (sheetCtx.mounted) {
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Add Account',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
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

  void _switchDisplayCurrency() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencies = CurrencyService.rates.keys.toList();

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Switch Portfolio Currency',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Shows the balance held in accounts using the selected currency.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 14),
                ...currencies.map((c) {
                  final rate = CurrencyService.rates[c];
                  final isSelected = FinanceState.primaryCurrency == c;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Text(
                      rate?.flag ?? '\u{1F30D}',
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(
                      '$c - ${rate?.name}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.accent,
                            size: 20,
                          )
                        : null,
                    onTap: () => Navigator.pop(ctx, c),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );

    if (selected != null) {
      try {
        await FinanceApi.instance.updateProfile({
          'preferred_currency': selected,
        });
        await FinanceApi.instance.refresh();
        FinanceState.primaryCurrency = selected;
        if (mounted) setState(() {});
        widget.onDataChanged();
      } catch (error) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryCurr = FinanceState.primaryCurrency;
    // Total only the accounts actually denominated in the selected currency.
    final totalInSelectedCurrency = FinanceState.accounts
        .where((account) => account.currency == primaryCurr)
        .fold<double>(0, (total, account) => total + account.balance);
    final currSymbol = CurrencyService.getSymbol(primaryCurr);
    final profileName =
        [FinanceState.profile['first_name'], FinanceState.profile['last_name']]
            .where(
              (value) => value != null && value.toString().trim().isNotEmpty,
            )
            .join(' ');
    final avatarName = profileName.isNotEmpty
        ? profileName
        : (FinanceState.profile['email']?.toString() ?? 'JIREH');
    final safeAvatarName = avatarName.trim().isEmpty
        ? 'JIREH'
        : avatarName.trim();
    final avatarParts = safeAvatarName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final avatarInitials = avatarParts.length > 1
        ? '${avatarParts.first[0]}${avatarParts.last[0]}'.toUpperCase()
        : avatarParts.first
              .substring(0, avatarParts.first.length > 1 ? 2 : 1)
              .toUpperCase();
    final unreadNotifications = FinanceState.notifications
        .where((row) => row['is_read'] != true)
        .length;
    final holdings = <String, double>{};
    for (final account in FinanceState.accounts) {
      holdings.update(
        account.currency,
        (balance) => balance + account.balance,
        ifAbsent: () => account.balance,
      );
    }
    final savingsRate = FinanceState.monthlyIncomeCurrent <= 0
        ? 0.0
        : FinanceState.savingsThisMonth /
              FinanceState.monthlyIncomeCurrent *
              100;

    return CustomScrollView(
      slivers: [
        // App Header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              22,
              MediaQuery.of(context).padding.top + 12,
              22,
              14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTimeGreeting(),
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profileName.isEmpty
                            ? (FinanceState.profile['email']?.toString() ?? '')
                            : profileName,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Currency Switcher Quick Pill
                GestureDetector(
                  onTap: _switchDisplayCurrency,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDarkSecondary
                          : const Color(0xFFEFF3EE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          CurrencyService.rates[primaryCurr]?.flag ??
                              '\u{1F30D}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          primaryCurr,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.accentLight
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Notification button with unread badge
                GestureDetector(
                  onTap: widget.onOpenNotifications,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        if (unreadNotifications > 0)
                          Positioned(
                            top: 9,
                            right: 9,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.expense,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Avatar
                GestureDetector(
                  onTap: widget.onOpenProfile,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      avatarInitials,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),
        ),

        // Balance card shows funds actually held in the selected currency.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
            child: FinancialBalanceCard(
              totalBalance: totalInSelectedCurrency,
              monthlyIncome: FinanceState.monthlyIncomeCurrent,
              monthlyExpense: FinanceState.monthlyExpenseCurrent,
              monthlySavings: FinanceState.savingsThisMonth,
              currency: primaryCurr,
              percentageChange:
                  '${savingsRate.toStringAsFixed(1)}% savings rate',
              isBalanceVisible: _isBalanceVisible,
              onToggleVisibility: () =>
                  setState(() => _isBalanceVisible = !_isBalanceVisible),
            ).animate().fadeIn(delay: 80.ms, duration: 450.ms),
          ),
        ),

        // Multi-Currency Quick Holdings Strip
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Multi-Currency Holdings',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'From your accounts',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.income,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: holdings.entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCurrencyBadge(
                              entry.key,
                              '${CurrencyService.getSymbol(entry.key)}${Formatters.amount(entry.value)}',
                              isDark,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Quick Actions Row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickActions(context, isDark),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Accounts Carousel (With Add Account button!)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    children: [
                      Text(
                        'Your Accounts',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _showAddAccountSheet,
                        child: Text(
                          '+ Add Account',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.accentLight
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Height increased to 124 to guarantee zero overflow
                SizedBox(
                  height: 124,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: FinanceState.accounts.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      if (index == FinanceState.accounts.length) {
                        return AccountCard(
                          isAddButton: true,
                          onTap: _showAddAccountSheet,
                        );
                      }
                      return AccountCard(
                        account: FinanceState.accounts[index],
                        onTap: () =>
                            _showAccountOptions(FinanceState.accounts[index]),
                      );
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
          ),
        ),

        // Financial Insights Banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.025),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.accent,
                      size: 22,
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
                              'Smart Multi-Currency Insight',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Calculated',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.income,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${FinanceState.accounts.length} active accounts. Total recorded balance is $currSymbol${Formatters.amount(totalInSelectedCurrency)}.',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            height: 1.4,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ),
        ),

        // Recent Transactions Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Recent Transactions',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TransactionsScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        'See all',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.accentLight
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.25 : 0.025),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: FinanceState.transactions.take(5).length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 68,
                      endIndent: 16,
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    itemBuilder: (context, index) {
                      final tx = FinanceState.transactions[index];
                      final cat = FinanceState.categoryById(tx.categoryId);
                      return TransactionTile(
                        transaction: tx,
                        category: cat,
                        onTap: () =>
                            _showTransactionDetails(context, tx, cat, isDark),
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Upcoming Bills Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Obligations',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 132,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: FinanceState.bills.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final bill = FinanceState.bills[index];
                      final isDueSoon = bill.isDueSoon;
                      return Container(
                        width: 168,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: bill.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    bill.icon,
                                    color: bill.color,
                                    size: 15,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDueSoon
                                        ? AppColors.warning.withOpacity(0.12)
                                        : (isDark
                                              ? Colors.white.withOpacity(0.06)
                                              : const Color(0xFFEFF3EE)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${bill.daysUntilDue}d',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isDueSoon
                                          ? AppColors.warning
                                          : (isDark
                                                ? AppColors.textTertiaryDark
                                                : AppColors.textSecondaryLight),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bill.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                Text(
                                  bill.merchant.isEmpty ? 'Provider not set' : bill.merchant,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 10, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                ),
                                Text(
                                  '${CurrencyService.getSymbol(bill.currency)}${Formatters.amount(bill.amount)} · ${Formatters.dateShort(bill.dueDate)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyBadge(String code, String formatted, bool isDark) {
    final flag = CurrencyService.rates[code]?.flag ?? '\u{1F30D}';
    final isSelected = FinanceState.primaryCurrency == code;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                  ? AppColors.primary.withOpacity(0.25)
                  : AppColors.primary.withOpacity(0.1))
            : (isDark ? AppColors.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? AppColors.accent
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            formatted,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final actions = [
      (
        'Expense',
        Icons.north_east_rounded,
        AppColors.expense,
        () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(
                initialType: TransactionType.expense,
              ),
            ),
          );
          setState(() {});
        },
      ),
      (
        'Income',
        Icons.south_west_rounded,
        AppColors.income,
        () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(
                initialType: TransactionType.income,
              ),
            ),
          );
          setState(() {});
        },
      ),
      (
        'Budget',
        Icons.pie_chart_outline_rounded,
        AppColors.accent,
        widget.onOpenBudgets,
      ),
      ('Goals', Icons.flag_rounded, AppColors.warning, widget.onOpenGoals),
      (
        'Analytics',
        Icons.insights_rounded,
        AppColors.info,
        widget.onOpenAnalytics,
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return GestureDetector(
          onTap: a.$4,
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.25 : 0.025),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: a.$3.withOpacity(isDark ? 0.18 : 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(a.$2, color: a.$3, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                a.$1,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    Transaction t,
    Category cat,
    bool isDark,
  ) {
    final sym = CurrencyService.getSymbol(t.currency);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          t.merchant,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${t.type == TransactionType.income ? '+' : '-'}$sym${Formatters.amount(t.amount)}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: t.type == TransactionType.income
                          ? AppColors.income
                          : AppColors.expense,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark
                      : AppColors.cardLightSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Category', cat.name, isDark),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'Original Currency',
                      '${t.currency} ($sym)',
                      isDark,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'Date & Time',
                      Formatters.dateTime(t.date),
                      isDark,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'Payment Method',
                      t.paymentMethod.name.toUpperCase(),
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
