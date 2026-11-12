import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/services/currency_service.dart';
import '../core/utils/formatters.dart';

class FinancialBalanceCard extends StatelessWidget {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlySavings;
  final String currency;
  final String percentageChange;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;

  const FinancialBalanceCard({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlySavings,
    this.currency = 'USD',
    this.percentageChange = '',
    required this.isBalanceVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.emeraldCardGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle background decorative ambient glow
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.08),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Label, Visibility toggle, and Performance Badge
                Row(
                  children: [
                    Text(
                      'TOTAL BALANCE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      tooltip: isBalanceVisible ? 'Hide balance' : 'Show balance',
                      onPressed: onToggleVisibility,
                      icon: Icon(
                        isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 17,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.accentLight),
                          const SizedBox(width: 4),
                          Text(
                            percentageChange,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Main balance figure
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      isBalanceVisible
                          ? '${CurrencyService.getSymbol(currency)}${Formatters.amount(totalBalance)}'
                          : '••••••••',
                      style: GoogleFonts.inter(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        currency,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Divider line with subtle opacity
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.12),
                ),

                const SizedBox(height: 16),

                // Mini statistics row: Income | Expenses | Savings
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStat(
                        label: 'Income',
                        amount: monthlyIncome,
                        icon: Icons.arrow_downward_rounded,
                        color: AppColors.accentLight,
                        prefix: '+',
                      ),
                    ),
                    Container(width: 1, height: 36, color: Colors.white.withOpacity(0.12)),
                    Expanded(
                      child: _buildMiniStat(
                        label: 'Expenses',
                        amount: monthlyExpense,
                        icon: Icons.arrow_upward_rounded,
                        color: const Color(0xFFFCA5A5),
                        prefix: '-',
                      ),
                    ),
                    Container(width: 1, height: 36, color: Colors.white.withOpacity(0.12)),
                    Expanded(
                      child: _buildMiniStat(
                        label: 'Savings',
                        amount: monthlySavings,
                        icon: Icons.savings_outlined,
                        color: Colors.white,
                        prefix: '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    required String prefix,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isBalanceVisible
              ? '$prefix${CurrencyService.getSymbol(currency)}${Formatters.amount(amount)}'
              : '••••',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
