import 'package:flutter/material.dart';
import '../data/finance_state.dart';
import '../models/models.dart';
import 'api_client.dart';
import 'currency_service.dart';

class FinanceApi {
  FinanceApi._();
  static final FinanceApi instance = FinanceApi._();
  final ApiClient _api = ApiClient.instance;

  Future<void> refresh() async {
    final first = await Future.wait<dynamic>([
      _api.get('profile/'),
      _api.get('accounts/'),
      _api.get('categories/'),
      _api.get('currencies/'),
      _getRows('exchange-rates/'),
    ]);
    final profile = _map(first[0]);
    final accounts = _rows(first[1]);
    final categoryRows = _rows(first[2]);
    final currencyRows = _rows(first[3]);
    final exchangeRows = _rows(first[4]);

    final second = await Future.wait<dynamic>([
      _getRows('transactions/'),
      _getRows('budgets/'),
      _getRows('goals/'),
      _getRows('subscriptions/'),
      _getRows('notifications/'),
      _api.get('analytics/dashboard/'),
      _api.get('analytics/spending-breakdown/'),
      _api.get('analytics/spending-trends/'),
      _getRows('debts/'),
    ]);

    FinanceState.profile = profile;
    FinanceState.primaryCurrency = (profile['preferred_currency'] ?? 'USD').toString();
    FinanceState.accounts = accounts.map(_account).toList();
    FinanceState.categories = categoryRows.map(_category).toList();
    FinanceState.transactions = _rows(second[0]).map(_transaction).toList();
    FinanceState.budgets = _rows(second[1]).map(_budget).toList();
    FinanceState.goals = _rows(second[2]).map(_goal).toList();
    FinanceState.bills = _rows(second[3]).map(_bill).toList();
    FinanceState.notifications = _rows(second[4]);
    FinanceState.dashboard = _map(second[5]);
    FinanceState.categorySpending = {
      for (final row in _rows(second[6]))
        (row['category_id'] ?? '').toString(): _number(row['amount']),
    };
    FinanceState.spendingTrends = _rows(second[7]);
    FinanceState.debts = _rows(second[8]);
    FinanceState.monthLabels = FinanceState.spendingTrends.map((row) => (row['label'] ?? '').toString()).toList();
    FinanceState.monthlyIncome = FinanceState.spendingTrends.map((row) => _number(row['income'])).toList();
    FinanceState.monthlyExpenses = FinanceState.spendingTrends.map((row) => _number(row['expense'])).toList();
    _loadCurrencyRates(currencyRows, exchangeRows);
  }

  Future<void> refreshNotifications() async {
    FinanceState.notifications = await _getRows('notifications/');
  }

  Future<Map<String, dynamic>> createAccount(Map<String, dynamic> data) async =>
      _api.post('accounts/', body: data, authenticated: true);

  Future<void> addAccount({
    required String name,
    required String accountType,
    required String currency,
    required double openingBalance,
    required String color,
    required String icon,
  }) async {
    const accountTypes = {
      'Bank Account': 'bank',
      'Savings': 'savings',
      'Cash Wallet': 'cash',
      'Mobile Money': 'mobile_money',
      'Investment': 'investment',
      'Credit Card': 'credit_card',
    };
    await createAccount({
      'name': name,
      'account_type': accountTypes[accountType] ?? 'other',
      'currency': currency,
      'opening_balance': openingBalance.toStringAsFixed(2),
      'color': color,
      'icon': icon,
    });
    await refresh();
  }

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async =>
      _api.post('transactions/', body: data, authenticated: true);

  Future<Map<String, dynamic>> createTransfer(Map<String, dynamic> data) async =>
      _api.post('transactions/transfer/', body: data, authenticated: true);

  Future<Map<String, dynamic>> createBudget(Map<String, dynamic> data) async =>
      _api.post('budgets/', body: data, authenticated: true);

  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> data) async =>
      _api.post('goals/', body: data, authenticated: true);

  Future<Map<String, dynamic>> contributeToGoal(String id, Map<String, dynamic> data) async =>
      _api.post('goals/$id/contributions/', body: data, authenticated: true);

  Future<Map<String, dynamic>> createSubscription(Map<String, dynamic> data) async =>
      _api.post('subscriptions/', body: data, authenticated: true);

  Future<Map<String, dynamic>> createDebt(Map<String, dynamic> data) async =>
      _api.post('debts/', body: data, authenticated: true);

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async =>
      _api.patch('profile/', body: data);

  Future<void> reverseTransaction(String id) async {
    await _api.delete('transactions/$id/');
  }

  Future<void> deleteBudget(String id) async {
    await _api.delete('budgets/$id/');
  }

  Future<void> deleteGoal(String id) async {
    await _api.delete('goals/$id/');
  }

  Future<void> markNotificationRead(String id) async {
    await _api.patch('notifications/$id/read/');
  }

  Future<void> markAllNotificationsRead() async {
    await _api.post('notifications/read-all/', authenticated: true);
  }

  Future<List<Map<String, dynamic>>> insights() async {
    final response = await _api.get('analytics/dashboard/');
    final data = _map(response);
    return (data['insights'] as List<dynamic>? ?? const [])
        .map((value) => {'text': value.toString()})
        .toList();
  }

  Future<String> answerQuestion(String question) async {
    final results = await Future.wait<dynamic>([
      _api.get('analytics/dashboard/'),
      _api.get('analytics/spending-breakdown/?days=30'),
    ]);
    final dashboard = _map(results[0]);
    final breakdown = _rows(results[1]);
    final query = question.toLowerCase();
    if (query.contains('food') || query.contains('category') || query.contains('spend')) {
      final searchTerms = query.split(RegExp(r'[^a-z0-9]+')).where((word) => word.length > 3).toList();
      Map<String, dynamic>? category;
      for (final row in breakdown) {
        if (searchTerms.any((term) =>
            (row['category_name'] ?? '').toString().toLowerCase().contains(term))) {
          category = row;
          break;
        }
      }
      if (category != null) {
        return 'In the last 30 days, ${category['category_name']} spending was ${category['amount']} ${dashboard['currency'] ?? ''} (${category['percentage']}% of tracked expenses).';
      }
    }
    final insights = (dashboard['insights'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toList();
    if (insights.isEmpty) return 'There is not enough recorded financial activity to answer yet.';
    return insights.join('\n\n');
  }

  static List<Map<String, dynamic>> _rows(dynamic value) {
    if (value is List) return value.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
    if (value is Map) {
      final rows = value['results'] ?? value['items'];
      if (rows is List) return _rows(rows);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _getRows(String path) async {
    const pageSize = 100;
    final firstPage = await _api.get('$path?page=1&page_size=$pageSize');
    final rows = _rows(firstPage);
    final totalPages = firstPage is Map
        ? int.tryParse((firstPage['total_pages'] ?? '1').toString()) ?? 1
        : 1;
    for (var page = 2; page <= totalPages; page++) {
      rows.addAll(_rows(await _api.get('$path?page=$page&page_size=$pageSize')));
    }
    return rows;
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static double _number(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;

  static Color _color(dynamic value, [Color fallback = const Color(0xFF059669)]) {
    final raw = value?.toString().replaceFirst('#', '');
    if (raw == null) return fallback;
    final parsed = int.tryParse(raw, radix: 16);
    if (parsed == null) return fallback;
    return Color(raw.length == 6 ? 0xFF000000 | parsed : parsed);
  }

  static IconData _icon(dynamic value) {
    final key = value?.toString().toLowerCase() ?? '';
    if (key.contains('restaurant') || key.contains('food')) return Icons.restaurant_rounded;
    if (key.contains('shopping') || key.contains('store')) return Icons.shopping_bag_rounded;
    if (key.contains('car') || key.contains('transport')) return Icons.directions_car_rounded;
    if (key.contains('health') || key.contains('medical')) return Icons.favorite_rounded;
    if (key.contains('movie') || key.contains('entertain')) return Icons.movie_rounded;
    if (key.contains('school') || key.contains('education')) return Icons.school_rounded;
    if (key.contains('flight') || key.contains('travel')) return Icons.flight_rounded;
    if (key.contains('savings')) return Icons.savings_rounded;
    if (key.contains('phone')) return Icons.phone_android_rounded;
    if (key.contains('credit')) return Icons.credit_card_rounded;
    if (key.contains('work') || key.contains('laptop')) return Icons.work_rounded;
    if (key.contains('bolt') || key.contains('utility')) return Icons.bolt_rounded;
    return Icons.account_balance_wallet_rounded;
  }

  static AccountSummary _account(Map<String, dynamic> row) => AccountSummary(
        id: row['id'].toString(),
        name: (row['name'] ?? '').toString(),
        type: (row['account_type'] ?? 'other').toString().replaceAll('_', ' '),
        currency: (row['currency'] ?? 'USD').toString(),
        balance: _number(row['current_balance']),
        icon: _icon(row['icon']),
        color: _color(row['color']),
      );

  static Category _category(Map<String, dynamic> row) {
    final color = _color(row['color']);
    return Category(
      id: row['id'].toString(),
      name: (row['name'] ?? 'Category').toString(),
      icon: _icon(row['icon']),
      color: color,
      backgroundColor: color.withOpacity(0.12),
    );
  }

  static Transaction _transaction(Map<String, dynamic> row) {
    final type = row['transaction_type'] == 'income' ? TransactionType.income : TransactionType.expense;
    final methodName = (row['payment_method'] ?? '').toString().replaceAll('_', '').toLowerCase();
    final method = PaymentMethod.values.firstWhere(
      (value) => value.name.toLowerCase() == methodName,
      orElse: () => PaymentMethod.bankTransfer,
    );
    return Transaction(
      id: row['id'].toString(),
      title: (row['description'] ?? '').toString(),
      merchant: (row['merchant'] ?? '').toString(),
      amount: _number(row['amount']),
      currency: (row['currency'] ?? 'USD').toString(),
      type: type,
      categoryId: (row['category'] ?? row['category_details']?['id'] ?? '').toString(),
      date: DateTime.tryParse((row['transaction_date'] ?? '').toString()) ?? DateTime.now(),
      paymentMethod: method,
      notes: row['notes']?.toString(),
    );
  }

  static Budget _budget(Map<String, dynamic> row) => Budget(
        id: row['id'].toString(),
        name: (row['name'] ?? '').toString(),
        categoryId: (row['category'] ?? '').toString(),
        limit: _number(row['amount']),
        spent: _number(row['spent']),
        currency: (row['currency'] ?? 'USD').toString(),
        month: DateTime.tryParse((row['start_date'] ?? '').toString()) ?? DateTime.now(),
        color: _color(row['color']),
      );

  static Goal _goal(Map<String, dynamic> row) => Goal(
        id: row['id'].toString(),
        name: (row['name'] ?? '').toString(),
        emoji: (row['emoji'] ?? '🎯').toString(),
        target: _number(row['target_amount']),
        saved: _number(row['current_amount']),
        currency: (row['currency'] ?? 'USD').toString(),
        deadline: DateTime.tryParse((row['target_date'] ?? '').toString()) ?? DateTime.now(),
        color: _color(row['color']),
        backgroundColor: _color(row['color']).withOpacity(0.12),
      );

  static Bill _bill(Map<String, dynamic> row) => Bill(
        id: row['id'].toString(),
        name: (row['name'] ?? '').toString(),
        merchant: (row['merchant'] ?? '').toString(),
        amount: _number(row['amount']),
        dueDate: DateTime.tryParse((row['next_due_date'] ?? '').toString()) ?? DateTime.now(),
        icon: _icon(row['icon']),
        color: _color(row['color']),
      );

  static void _loadCurrencyRates(List<Map<String, dynamic>> currencies, List<Map<String, dynamic>> rates) {
    CurrencyService.loadFromApi(currencies, rates);
  }
}
