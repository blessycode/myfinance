import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/models/models.dart';
import '../core/services/currency_service.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.type == TransactionType.income;
    final sym = CurrencyService.getSymbol(transaction.currency);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              // Category Icon in subtle tinted container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? category.color.withOpacity(0.18)
                      : category.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 13),

              // Title, Merchant and Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2.5),
                    Row(
                      children: [
                        Text(
                          transaction.merchant,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Text(
                          Formatters.relativeDate(transaction.date),
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Amount with semantic color and native currency symbol
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}$sym${Formatters.amount(transaction.amount)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: isIncome ? AppColors.income : (isDark ? const Color(0xFFF87171) : AppColors.expense),
                    ),
                  ),
                  const SizedBox(height: 2.5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (transaction.currency != 'USD') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E9E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction.currency,
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.accentLight : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          category.name.split(' ').first,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: category.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
