import '../models/models.dart';

class CurrencyRate {
  final String code;
  final String symbol;
  final String name;
  final double rateToUSD; // 1 unit of this currency = X USD
  final String flag;

  const CurrencyRate({
    required this.code,
    required this.symbol,
    required this.name,
    required this.rateToUSD,
    required this.flag,
  });
}

class CurrencyService {
  static const Map<String, CurrencyRate> rates = {
    'USD': CurrencyRate(code: 'USD', symbol: '\$', name: 'US Dollar', rateToUSD: 1.0, flag: '🇺🇸'),
    'EUR': CurrencyRate(code: 'EUR', symbol: '€', name: 'Euro', rateToUSD: 1.09, flag: '🇪🇺'),
    'GBP': CurrencyRate(code: 'GBP', symbol: '£', name: 'British Pound', rateToUSD: 1.28, flag: '🇬🇧'),
    'ZAR': CurrencyRate(code: 'ZAR', symbol: 'R', name: 'South African Rand', rateToUSD: 0.055, flag: '🇿🇦'),
    'ZWG': CurrencyRate(code: 'ZWG', symbol: 'ZiG', name: 'Zimbabwe Gold', rateToUSD: 0.038, flag: '🇿🇼'),
    'BWP': CurrencyRate(code: 'BWP', symbol: 'P', name: 'Botswana Pula', rateToUSD: 0.074, flag: '🇧🇼'),
  };

  /// Convert amount from one currency to another
  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    final fromRate = rates[fromCurrency]?.rateToUSD ?? 1.0;
    final toRate = rates[toCurrency]?.rateToUSD ?? 1.0;

    // Convert from source to USD, then from USD to target
    final amountInUSD = amount * fromRate;
    return amountInUSD / toRate;
  }

  /// Calculate total portfolio value across all accounts in the given target currency
  static double calculateTotalIn(List<AccountSummary> accounts, String targetCurrency) {
    double total = 0.0;
    for (final acc in accounts) {
      total += convert(acc.balance, acc.currency, targetCurrency);
    }
    return total;
  }

  /// Format currency with its symbol
  static String format(double amount, String currencyCode) {
    final symbol = rates[currencyCode]?.symbol ?? currencyCode;
    final formattedNum = amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '$symbol$formattedNum';
  }

  /// Get symbol for currency code
  static String getSymbol(String currencyCode) {
    return rates[currencyCode]?.symbol ?? currencyCode;
  }
}
