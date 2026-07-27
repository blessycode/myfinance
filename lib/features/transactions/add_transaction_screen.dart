import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/premium_button.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> with TickerProviderStateMixin {
  TransactionType _type = TransactionType.expense;
  String _amount = '0';
  String _selectedCategory = 'food';
  String _merchant = '';
  String _notes = '';
  PaymentMethod _paymentMethod = PaymentMethod.creditCard;
  bool _isLoading = false;
  bool _showSuccess = false;

  late AnimationController _successCtrl;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    super.dispose();
  }

  void _appendDigit(String digit) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_amount == '0') {
        _amount = digit;
      } else if (_amount.length < 8) {
        _amount = _amount + digit;
      }
    });
  }

  void _appendDecimal() {
    if (!_amount.contains('.')) {
      setState(() => _amount = '$_amount.');
    }
  }

  void _deleteDigit() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  void _save() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() { _isLoading = false; _showSuccess = true; });
    _successCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = _type == TransactionType.expense;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Gradient header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: isExpense ? AppColors.expenseGradient : AppColors.incomeGradient,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text('Add Transaction', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                // Type toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        _typeTab('Expense', TransactionType.expense, isExpense),
                        _typeTab('Income', TransactionType.income, !isExpense),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Amount display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\$', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white70)),
                      const SizedBox(width: 4),
                      Text(
                        _amount,
                        style: GoogleFonts.inter(fontSize: 64, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -3, height: 1),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Form card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -4))],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Category selector
                          _sectionLabel('Category', context),
                          const SizedBox(height: 10),
                          _buildCategorySelector(isDark),
                          const SizedBox(height: 16),

                          // Merchant
                          _sectionLabel('Merchant / Title', context),
                          const SizedBox(height: 8),
                          _buildInputField('e.g. Starbucks', Icons.store_rounded, isDark, onChanged: (v) => _merchant = v),
                          const SizedBox(height: 16),

                          // Payment method
                          _sectionLabel('Payment Method', context),
                          const SizedBox(height: 10),
                          _buildPaymentMethods(isDark),
                          const SizedBox(height: 16),

                          // Notes
                          _sectionLabel('Notes (Optional)', context),
                          const SizedBox(height: 8),
                          _buildInputField('Add a note...', Icons.notes_rounded, isDark, maxLines: 2, onChanged: (v) => _notes = v),
                          const SizedBox(height: 20),

                          // Numpad
                          _buildNumpad(),
                          const SizedBox(height: 20),

                          // Save button
                          PremiumButton(
                            label: 'Save Transaction',
                            onPressed: _save,
                            isLoading: _isLoading,
                            gradient: isExpense ? AppColors.expenseGradient : AppColors.incomeGradient,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Success overlay
          if (_showSuccess)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
                      const SizedBox(height: 12),
                      Text('Saved!', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.success)),
                    ],
                  ),
                ).animate().scale(curve: Curves.elasticOut),
              ),
            ),
        ],
      ),
    );
  }

  Widget _typeTab(String label, TransactionType type, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? (_type == TransactionType.expense ? AppColors.expense : AppColors.income) : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    final cats = MockData.categories.where((c) => c.id != 'income' && c.id != 'freelance').toList();
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = cats[index];
          final isSelected = _selectedCategory == cat.id;
          return GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedCategory = cat.id); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 68,
              decoration: BoxDecoration(
                color: isSelected ? cat.color : (isDark ? AppColors.cardDark : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? cat.color : Colors.transparent, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.icon, color: isSelected ? Colors.white : cat.color, size: 24),
                  const SizedBox(height: 4),
                  Text(cat.name.split(' ').first, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(String hint, IconData icon, bool isDark, {int maxLines = 1, ValueChanged<String>? onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        maxLines: maxLines,
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
          prefixIcon: Icon(icon, size: 18, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(bool isDark) {
    final methods = [
      (PaymentMethod.creditCard, Icons.credit_card_rounded, 'Credit'),
      (PaymentMethod.debitCard, Icons.credit_card_off_rounded, 'Debit'),
      (PaymentMethod.cash, Icons.payments_rounded, 'Cash'),
      (PaymentMethod.wallet, Icons.account_balance_wallet_rounded, 'Wallet'),
    ];
    return Row(
      children: methods.map((m) {
        final isSelected = _paymentMethod == m.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _paymentMethod = m.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF27272A) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(m.$2, size: 18, color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  const SizedBox(height: 3),
                  Text(m.$3, style: GoogleFonts.inter(fontSize: 10, color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumpad() {
    final keys = ['1','2','3','4','5','6','7','8','9','.','0','⌫'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        return GestureDetector(
          onTap: () {
            if (key == '⌫') {
              _deleteDigit();
            } else if (key == '.') {
              _appendDecimal();
            } else {
              _appendDigit(key);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: key == '⌫'
                  ? AppColors.expense.withOpacity(0.1)
                  : Theme.of(context).brightness == Brightness.dark ? const Color(0xFF27272A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                key,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: key == '⌫' ? AppColors.expense : (Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
