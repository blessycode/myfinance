import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/services/currency_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/app_section_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Expense', 'Income', 'USD', 'EUR', 'ZWG', 'ZAR', 'Food', 'Transport', 'Shopping'];

  List<Transaction> get _filteredTransactions {
    var list = MockData.transactions;
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) => t.title.toLowerCase().contains(q) || t.merchant.toLowerCase().contains(q) || t.currency.toLowerCase().contains(q)).toList();
    }
    switch (_selectedFilter) {
      case 'Expense':
        return list.where((t) => t.type == TransactionType.expense).toList();
      case 'Income':
        return list.where((t) => t.type == TransactionType.income).toList();
      case 'USD':
      case 'EUR':
      case 'ZWG':
      case 'ZAR':
        return list.where((t) => t.currency == _selectedFilter).toList();
      case 'Food':
        return list.where((t) => t.categoryId == 'food').toList();
      case 'Transport':
        return list.where((t) => t.categoryId == 'transport').toList();
      case 'Shopping':
        return list.where((t) => t.categoryId == 'shopping').toList();
      default:
        return list;
    }
  }

  Map<String, List<Transaction>> get _groupedTransactions {
    final map = <String, List<Transaction>>{};
    for (final t in _filteredTransactions) {
      final key = Formatters.relativeDate(t.date);
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section Header & Add action
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppSectionHeader(
                          title: 'Transactions',
                          subtitle: '${_filteredTransactions.length} records in your multi-currency ledger',
                          actionLabel: '+ Add',
                          onAction: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                            );
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Search input
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search merchant, title or currency...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 19,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 17),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filter Chips Carousel
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = _selectedFilter == filter;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.cardDark : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                filter,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),

            // Transactions List
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No Transactions Found',
                      description: 'Try adjusting your search criteria or currency filters.',
                      actionLabel: 'Reset Filters',
                      onAction: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedFilter = 'All';
                        });
                      },
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: _groupedTransactions.entries.map((entry) {
                        return _buildDateGroup(entry.key, entry.value, isDark);
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateGroup(String dateLabel, List<Transaction> transactions, bool isDark) {
    // Convert to primary currency for accurate day total without naive addition of disparate currencies
    final netDayTotal = transactions.fold<double>(
      0,
      (sum, t) {
        final converted = CurrencyService.convert(t.amount, t.currency, MockData.primaryCurrency);
        return t.type == TransactionType.income ? sum + converted : sum - converted;
      },
    );
    final primarySym = CurrencyService.getSymbol(MockData.primaryCurrency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 10),
          child: Row(
            children: [
              Text(
                dateLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              Text(
                '${netDayTotal >= 0 ? '+' : ''}$primarySym${Formatters.amount(netDayTotal.abs())}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: netDayTotal >= 0 ? AppColors.income : (isDark ? const Color(0xFFF87171) : AppColors.expense),
                ),
              ),
            ],
          ),
        ),
        Container(
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
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: transactions.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 68,
              endIndent: 16,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final cat = MockData.categoryById(tx.categoryId);
              return Dismissible(
                key: Key(tx.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.expense.withOpacity(0.2),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Transaction'),
                          content: Text('Are you sure you want to delete ${tx.title}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (_) {
                  setState(() => MockData.transactions.removeWhere((item) => item.id == tx.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deleted ${tx.title}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: TransactionTile(
                  transaction: tx,
                  category: cat,
                  onTap: () => _showDetailSheet(tx, cat, isDark),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDetailSheet(Transaction tx, Category cat, bool isDark) {
    final sym = CurrencyService.getSymbol(tx.currency);
    final converted = CurrencyService.convert(tx.amount, tx.currency, MockData.primaryCurrency);
    final primarySym = CurrencyService.getSymbol(MockData.primaryCurrency);

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
                          tx.title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          tx.merchant,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${tx.type == TransactionType.income ? '+' : '-'}$sym${Formatters.amount(tx.amount)}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: tx.type == TransactionType.income ? AppColors.income : AppColors.expense,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLightSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildRow('Category', cat.name, isDark),
                    const Divider(height: 16),
                    _buildRow('Original Currency', '${tx.currency} ($sym)', isDark),
                    if (tx.currency != MockData.primaryCurrency) ...[
                      const Divider(height: 16),
                      _buildRow(
                        'Converted to ${MockData.primaryCurrency}',
                        '$primarySym${Formatters.amount(converted)}',
                        isDark,
                      ),
                    ],
                    const Divider(height: 16),
                    _buildRow('Date', Formatters.dateTime(tx.date), isDark),
                    const Divider(height: 16),
                    _buildRow('Payment Method', tx.paymentMethod.name.toUpperCase(), isDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _buildRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
