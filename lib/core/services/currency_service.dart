import '../models/models.dart';

class CurrencyRate {
  final String code;
  final String symbol;
  final String name;
  final double rateToUSD;
  final String flag;

  const CurrencyRate({
    required this.code,
    required this.symbol,
    required this.name,
    required this.rateToUSD,
    this.flag = '',
  });
}

class CurrencyService {
  static Map<String, CurrencyRate> rates = {};

  static void loadFromApi(
    List<Map<String, dynamic>> currencies,
    List<Map<String, dynamic>> exchangeRates,
  ) {
    final rateToUsd = <String, double>{'USD': 1};
    for (final row in exchangeRates) {
      final base = row['base_currency']?.toString();
      final target = row['target_currency']?.toString();
      final rate = double.tryParse(row['rate']?.toString() ?? '');
      if (rate == null || rate <= 0) continue;
      if (target == 'USD' && base != null) rateToUsd[base] = rate;
      if (base == 'USD' && target != null) rateToUsd[target] = 1 / rate;
    }
    rates = {
      for (final row in currencies)
        if (row['code'] != null)
          row['code'].toString(): CurrencyRate(
            code: row['code'].toString(),
            symbol: (row['symbol'] ?? row['code']).toString(),
            name: (row['name'] ?? row['code']).toString(),
            rateToUSD: rateToUsd[row['code'].toString()] ?? 0,
          ),
    };
  }

  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    final fromRate = rates[fromCurrency]?.rateToUSD ?? 0;
    final toRate = rates[toCurrency]?.rateToUSD ?? 0;
    if (fromRate <= 0 || toRate <= 0) return amount;
    return amount * fromRate / toRate;
  }

  static double calculateTotalIn(List<AccountSummary> accounts, String targetCurrency) {
    return accounts.fold<double>(
      0,
      (total, account) => total + convert(account.balance, account.currency, targetCurrency),
    );
  }

  static String format(double amount, String currencyCode) {
    final symbol = rates[currencyCode]?.symbol ?? currencyCode;
    final formatted = amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
    return '$symbol$formatted';
  }

  static String getSymbol(String currencyCode) => rates[currencyCode]?.symbol ?? currencyCode;
}
