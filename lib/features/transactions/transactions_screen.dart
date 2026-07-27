import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/glass_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'All';
  String _search = '';
  final _searchCtrl = TextEditingController();

  final List<String> _filters = ['All', 'Expense', 'Income', 'Food', 'Transport', 'Shopping'];

  List<Transaction> get _filteredTransactions {
    var txs = MockData.transactions;
    if (_search.isNotEmpty) {
      txs = txs.where((t) => t.title.toLowerCase().contains(_search.toLowerCase()) || t.merchant.toLowerCase().contains(_search.toLowerCase())).toList();
    }
    switch (_filter) {
      case 'Expense': return txs.where((t) => t.type == TransactionType.expense).toList();
      case 'Income': return txs.where((t) => t.type == TransactionType.income).toList();
      case 'Food': return txs.where((t) => t.categoryId == 'food').toList();
      case 'Transport': return txs.where((t) => t.categoryId == 'transport').toList();
      case 'Shopping': return txs.where((t) => t.categoryId == 'shopping').toList();
      default: return txs;
    }
  }

  Map<String, List<Transaction>> get _grouped {
    final map = <String, List<Transaction>>{};
    for (final t in _filteredTransactions) {
      final key = Formatters.relativeDate(t.date);
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transactions', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, letterSpacing: -1)).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _search = v),
                      style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        hintStyle: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                        prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight, size: 20),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); })
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 14),

                  // Filters
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final f = _filters[index];
                        final isSelected = _filter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : (isDark ? AppColors.cardDark : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)] : [],
                            ),
                            child: Center(
                              child: Text(f, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))),
                            ),
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // List
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: _grouped.entries.map((entry) {
                        return _buildGroup(entry.key, entry.value, isDark);
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(String dateLabel, List<Transaction> transactions, bool isDark) {
    final dayTotal = transactions.fold<double>(0, (sum, t) => t.type == TransactionType.income ? sum + t.amount : sum - t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(dateLabel, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              const Spacer(),
              Text(
                '${dayTotal >= 0 ? '+' : ''}\$${dayTotal.abs().toStringAsFixed(2)}',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: dayTotal >= 0 ? AppColors.income : AppColors.expense),
              ),
            ],
          ),
        ),

        ...transactions.map((t) => _buildTransactionCard(t, isDark)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction t, bool isDark) {
    final cat = MockData.categoryById(t.categoryId);
    final isIncome = t.type == TransactionType.income;

    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.expense.withOpacity(0.15), borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
      ),
      child: GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(15)),
              child: Icon(cat.icon, color: cat.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                  const SizedBox(height: 2),
                  Row(children: [
                    Text(t.merchant, style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    const SizedBox(width: 8),
                    Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(Formatters.time(t.date), style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ]),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: isIncome ? AppColors.income : AppColors.expense),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(cat.name.split(' ').first, style: GoogleFonts.inter(fontSize: 10, color: cat.color, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('No transactions found', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
          const SizedBox(height: 8),
          Text('Try adjusting your search or filters', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}
