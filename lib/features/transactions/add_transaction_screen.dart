import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/finance_state.dart';
import '../../core/models/models.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/finance_api.dart';
import '../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType initialType;

  const AddTransactionScreen({
    super.key,
    this.initialType = TransactionType.expense,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TransactionType _type;
  String _amount = '0';
  String _selectedCategoryId = '';
  String _selectedCurrency = FinanceState.primaryCurrency;
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.creditCard;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final _currencies = ['USD', 'EUR', 'GBP', 'ZAR', 'ZWG', 'BWP'];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    if (FinanceState.categories.isNotEmpty) _selectedCategoryId = FinanceState.categories.first.id;
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _appendDigit(String digit) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_amount == '0') {
        _amount = digit;
      } else if (_amount.length < 8) {
        _amount += digit;
      }
    });
  }

  void _appendDecimal() {
    HapticFeedback.selectionClick();
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

  void _saveTransaction() async {
    final parsedAmount = double.tryParse(_amount) ?? 0.0;
    if (parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount greater than 0'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (FinanceState.accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Add an account before recording a transaction.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _isLoading = true);
    final merchant = _merchantController.text.trim();
    try {
      await FinanceApi.instance.createTransaction({
        'account': FinanceState.accounts.first.id,
        'transaction_type': _type == TransactionType.income ? 'income' : 'expense',
        'category': _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
        'amount': parsedAmount.toStringAsFixed(2),
        'currency': _selectedCurrency,
        'description': merchant.isEmpty ? (_type == TransactionType.income ? 'Income Deposit' : 'Expense Payment') : merchant,
        'merchant': merchant,
        'transaction_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'payment_method': _paymentMethod.name.replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]!.toLowerCase()}'),
        'notes': _notesController.text.trim(),
      });
      await FinanceApi.instance.refresh();
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Recorded ${CurrencyService.getSymbol(_selectedCurrency)}${parsedAmount.toStringAsFixed(2)} ($_selectedCurrency) transaction'),
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not save transaction: $error'),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = _type == TransactionType.expense;
    final currSymbol = CurrencyService.getSymbol(_selectedCurrency);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 22),
                  ),
                  const Spacer(),
                  Text(
                    'Record Transaction',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Segmented Type Selector (Expense vs Income)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
                height: 42,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : const Color(0xFFEFF3EE),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _type = TransactionType.expense;
                            _selectedCategoryId = FinanceState.categories.isEmpty ? '' : FinanceState.categories.first.id;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isExpense
                                ? (isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isExpense
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        isDark ? 0.2 : 0.05,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.north_east_rounded,
                                  size: 15,
                                  color: isExpense
                                      ? AppColors.expense
                                      : (isDark
                                            ? AppColors.textTertiaryDark
                                            : AppColors.textSecondaryLight),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Expense',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: isExpense
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isExpense
                                        ? (isDark
                                              ? const Color(0xFFF87171)
                                              : AppColors.expense)
                                        : (isDark
                                              ? AppColors.textTertiaryDark
                                              : AppColors.textSecondaryLight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _type = TransactionType.income;
                            _selectedCategoryId = FinanceState.categories.isEmpty ? '' : FinanceState.categories.first.id;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: !isExpense
                                ? (isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !isExpense
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        isDark ? 0.2 : 0.05,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.south_west_rounded,
                                  size: 15,
                                  color: !isExpense
                                      ? AppColors.income
                                      : (isDark
                                            ? AppColors.textTertiaryDark
                                            : AppColors.textSecondaryLight),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Income',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: !isExpense
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: !isExpense
                                        ? AppColors.income
                                        : (isDark
                                              ? AppColors.textTertiaryDark
                                              : AppColors.textSecondaryLight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Currency Selector Strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _currencies.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final c = _currencies[index];
                    final isSelected = _selectedCurrency == c;
                    final flag = CurrencyService.rates[c]?.flag ?? '';
                    return ChoiceChip(
                      label: Text('$flag $c'),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCurrency = c);
                      },
                      selectedColor: isDark
                          ? AppColors.primary
                          : AppColors.primary,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ),
            ),

            // Hero Amount Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'AMOUNT ($_selectedCurrency)',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${isExpense ? '-' : '+'}$currSymbol$_amount',
                        style: GoogleFonts.inter(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.0,
                          color: isExpense
                              ? (isDark
                                    ? const Color(0xFFF87171)
                                    : AppColors.expense)
                              : AppColors.income,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Category & Form options
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selection Label
                    Text(
                      'Category',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Category Grid
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: FinanceState.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = FinanceState.categories[index];
                          final isSelected = _selectedCategoryId == cat.id;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCategoryId = cat.id);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.cardDark
                                          : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    cat.icon,
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : cat.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Merchant / Description
                    Text(
                      'Merchant / Description',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _merchantController,
                      style: GoogleFonts.inter(fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'e.g. Whole Foods, Starbucks, Client Invoice',
                        prefixIcon: const Icon(
                          Icons.storefront_outlined,
                          size: 19,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Payment Method selector
                    Text(
                      'Payment Method',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PaymentMethod.values.map((method) {
                        final isSelected = _paymentMethod == method;
                        return ChoiceChip(
                          label: Text(method.name.toUpperCase()),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _paymentMethod = method);
                          },
                          labelStyle: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                          ),
                          selectedColor: AppColors.primary,
                          backgroundColor: isDark
                              ? AppColors.cardDark
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Keypad & Save Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3'], isDark),
                  _buildKeypadRow(['4', '5', '6'], isDark),
                  _buildKeypadRow(['7', '8', '9'], isDark),
                  _buildKeypadRow(['.', '0', '⌫'], isDark),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _saveTransaction,
                      style: FilledButton.styleFrom(
                        backgroundColor: isExpense
                            ? AppColors.primary
                            : AppColors.income,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save Transaction ($_selectedCurrency)',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: keys.map((key) {
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (key == '⌫') {
                    _deleteDigit();
                  } else if (key == '.') {
                    _appendDecimal();
                  } else {
                    _appendDigit(key);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  child: Text(
                    key,
                    style: GoogleFonts.inter(
                      fontSize: key == '⌫' ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
