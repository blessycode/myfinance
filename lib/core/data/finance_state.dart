import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/currency_service.dart';

/// In-memory view state populated from the authenticated API. This class no
/// longer contains prefilled demo accounts, transactions, budgets, or goals.
class FinanceState {
  static List<AccountSummary> accounts = [];
  static String primaryCurrency = 'USD';
  static double get totalBalance => CurrencyService.calculateTotalIn(accounts, primaryCurrency);
  static double totalBalanceIn(String currency) => CurrencyService.calculateTotalIn(accounts, currency);

  static List<Category> categories = [];
  static Category categoryById(String id) => categories.firstWhere(
        (category) => category.id == id,
        orElse: () => const Category(
          id: '',
          name: 'Uncategorized',
          icon: Icons.category_outlined,
          color: Color(0xFF94A3B8),
          backgroundColor: Color(0x1994A3B8),
        ),
      );

  static List<Transaction> transactions = [];
  static List<Budget> budgets = [];
  static List<Goal> goals = [];
  static List<Bill> bills = [];
  static List<Map<String, dynamic>> notifications = [];
  static List<Map<String, dynamic>> debts = [];
  static Map<String, dynamic> profile = {};
  static Map<String, dynamic> dashboard = {};
  static List<Map<String, dynamic>> spendingTrends = [];
  static Map<String, double> categorySpending = {};
  static List<double> monthlyIncome = [];
  static List<double> monthlyExpenses = [];
  static List<String> monthLabels = [];

  static double get monthlyIncomeCurrent => _number(dashboard['monthly_income']);
  static double get monthlyExpenseCurrent => _number(dashboard['monthly_expense']);
  static double get savingsThisMonth => _number(dashboard['net_savings']);
  static double get spendingScore => _number(dashboard['savings_rate']) * 100;
  static double get aiHealthScore => 0;

  static double _number(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;
}
