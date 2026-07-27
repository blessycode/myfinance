import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final NumberFormat _compact = NumberFormat.compact();

  static String currency(double amount) => _currency.format(amount);

  static String compactCurrency(double amount) {
    if (amount >= 1000) return '\$${_compact.format(amount)}';
    return _currency.format(amount);
  }

  static String amount(double amount) {
    final formatted = amount.toStringAsFixed(2);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final withCommas = intPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '$withCommas.$decPart';
  }

  static String date(DateTime date) => DateFormat('MMM dd, yyyy').format(date);

  static String dateShort(DateTime date) => DateFormat('MMM dd').format(date);

  static String time(DateTime date) => DateFormat('h:mm a').format(date);

  static String dateTime(DateTime date) => DateFormat('MMM dd, yyyy • h:mm a').format(date);

  static String monthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';

    final diff = today.difference(d).inDays;
    if (diff < 7) return '${diff}d ago';
    return DateFormat('MMM dd').format(date);
  }

  static String percentage(double value) => '${(value * 100).toStringAsFixed(0)}%';

  static String sign(double amount, bool isIncome) =>
      isIncome ? '+\$${amount.toStringAsFixed(2)}' : '-\$${amount.toStringAsFixed(2)}';
}
