import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/currency_service.dart';

class MockData {
  // ── Multi-Currency Accounts ──────────────────────────────────────────────────
  static List<AccountSummary> accounts = [
    const AccountSummary(
      id: 'acc_1',
      name: 'Everyday Checking',
      type: 'Bank Account',
      currency: 'USD',
      balance: 4820.50,
      icon: Icons.account_balance_outlined,
      color: Color(0xFF10B981),
    ),
    const AccountSummary(
      id: 'acc_2',
      name: 'Euro Reserve',
      type: 'Savings',
      currency: 'EUR',
      balance: 11500.00,
      icon: Icons.savings_outlined,
      color: Color(0xFF3B82F6),
    ),
    const AccountSummary(
      id: 'acc_3',
      name: 'EcoCash Wallet',
      type: 'Mobile Money',
      currency: 'ZWG',
      balance: 35000.00,
      icon: Icons.phone_android_rounded,
      color: Color(0xFFF59E0B),
    ),
    const AccountSummary(
      id: 'acc_4',
      name: 'Rand Portfolio',
      type: 'Investment',
      currency: 'ZAR',
      balance: 25000.00,
      icon: Icons.show_chart_rounded,
      color: Color(0xFF8B5CF6),
    ),
    const AccountSummary(
      id: 'acc_5',
      name: 'UK Travel Card',
      type: 'Credit Card',
      currency: 'GBP',
      balance: 2100.00,
      icon: Icons.credit_card_rounded,
      color: Color(0xFFEC4899),
    ),
    const AccountSummary(
      id: 'acc_6',
      name: 'Cash Reserve',
      type: 'Cash',
      currency: 'USD',
      balance: 330.30,
      icon: Icons.wallet_outlined,
      color: Color(0xFF14B8A6),
    ),
  ];

  // Primary display currency selected by user
  static String primaryCurrency = 'USD';

  // Total balance converted across all multi-currency accounts
  static double get totalBalance =>
      CurrencyService.calculateTotalIn(accounts, primaryCurrency);

  static double totalBalanceIn(String currency) =>
      CurrencyService.calculateTotalIn(accounts, currency);

  // ── Categories ──────────────────────────────────────────────────────────────
  static final List<Category> categories = [
    const Category(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: Color(0xFF10B981),
      backgroundColor: Color(0x1910B981),
    ),
    const Category(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF06B6D4),
      backgroundColor: Color(0x1906B6D4),
    ),
    const Category(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFF59E0B),
      backgroundColor: Color(0x19F59E0B),
    ),
    const Category(
      id: 'health',
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: Color(0xFFF43F5E),
      backgroundColor: Color(0x19F43F5E),
    ),
    const Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFF8B5CF6),
      backgroundColor: Color(0x198B5CF6),
    ),
    const Category(
      id: 'utilities',
      name: 'Utilities',
      icon: Icons.bolt_rounded,
      color: Color(0xFF14B8A6),
      backgroundColor: Color(0x1914B8A6),
    ),
    const Category(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF84CC16),
      backgroundColor: Color(0x1984CC16),
    ),
    const Category(
      id: 'travel',
      name: 'Travel',
      icon: Icons.flight_rounded,
      color: Color(0xFFF97316),
      backgroundColor: Color(0x19F97316),
    ),
    const Category(
      id: 'income',
      name: 'Salary',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF10B981),
      backgroundColor: Color(0x1910B981),
    ),
    const Category(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.work_rounded,
      color: Color(0xFF3B82F6),
      backgroundColor: Color(0x193B82F6),
    ),
  ];

  static Category categoryById(String id) =>
      categories.firstWhere((c) => c.id == id, orElse: () => categories.first);

  // ── Transactions ─────────────────────────────────────────────────────────────
  static List<Transaction> transactions = [
    Transaction(
      id: 't1',
      title: 'Starbucks Coffee',
      merchant: 'Starbucks',
      amount: 8.50,
      currency: 'USD',
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      paymentMethod: PaymentMethod.creditCard,
    ),
    Transaction(
      id: 't2',
      title: 'Monthly Salary',
      merchant: 'TechCorp Inc.',
      amount: 5200.00,
      currency: 'USD',
      type: TransactionType.income,
      categoryId: 'income',
      date: DateTime.now().subtract(const Duration(days: 1)),
      paymentMethod: PaymentMethod.bankTransfer,
    ),
    Transaction(
      id: 't3',
      title: 'Uber London Ride',
      merchant: 'Uber UK',
      amount: 18.50,
      currency: 'GBP',
      type: TransactionType.expense,
      categoryId: 'transport',
      date: DateTime.now().subtract(const Duration(days: 1)),
      paymentMethod: PaymentMethod.wallet,
    ),
    Transaction(
      id: 't4',
      title: 'Netflix Subscription',
      merchant: 'Netflix',
      amount: 15.99,
      currency: 'USD',
      type: TransactionType.expense,
      categoryId: 'entertainment',
      date: DateTime.now().subtract(const Duration(days: 2)),
      paymentMethod: PaymentMethod.creditCard,
    ),
    Transaction(
      id: 't5',
      title: 'Euro Bistro Dinner',
      merchant: 'Le Marais Paris',
      amount: 85.00,
      currency: 'EUR',
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime.now().subtract(const Duration(days: 2)),
      paymentMethod: PaymentMethod.debitCard,
    ),
    Transaction(
      id: 't6',
      title: 'Freelance Design',
      merchant: 'Global Client',
      amount: 800.00,
      currency: 'USD',
      type: TransactionType.income,
      categoryId: 'freelance',
      date: DateTime.now().subtract(const Duration(days: 3)),
      paymentMethod: PaymentMethod.bankTransfer,
    ),
    Transaction(
      id: 't7',
      title: 'Electric Bill',
      merchant: 'City Power',
      amount: 67.40,
      currency: 'USD',
      type: TransactionType.expense,
      categoryId: 'utilities',
      date: DateTime.now().subtract(const Duration(days: 3)),
      paymentMethod: PaymentMethod.bankTransfer,
    ),
    Transaction(
      id: 't8',
      title: 'Harare Market Groceries',
      merchant: 'TM Pick n Pay',
      amount: 650.00,
      currency: 'ZWG',
      type: TransactionType.expense,
      categoryId: 'shopping',
      date: DateTime.now().subtract(const Duration(days: 4)),
      paymentMethod: PaymentMethod.wallet,
    ),
    Transaction(
      id: 't9',
      title: 'Cape Town Gym',
      merchant: 'Virgin Active',
      amount: 450.00,
      currency: 'ZAR',
      type: TransactionType.expense,
      categoryId: 'health',
      date: DateTime.now().subtract(const Duration(days: 5)),
      paymentMethod: PaymentMethod.creditCard,
    ),
    Transaction(
      id: 't10',
      title: 'Flight Tickets',
      merchant: 'Delta Airlines',
      amount: 420.00,
      currency: 'USD',
      type: TransactionType.expense,
      categoryId: 'travel',
      date: DateTime.now().subtract(const Duration(days: 6)),
      paymentMethod: PaymentMethod.creditCard,
    ),
    Transaction(
      id: 't11',
      title: 'Online Course',
      merchant: 'Udemy',
      amount: 19.99,
      currency: 'USD',
      type: TransactionType.expense,
      categoryId: 'education',
      date: DateTime.now().subtract(const Duration(days: 7)),
      paymentMethod: PaymentMethod.creditCard,
    ),
    Transaction(
      id: 't12',
      title: 'Spotify Premium',
      merchant: 'Spotify',
      amount: 9.99,
      currency: 'USD',
      type: TransactionType.expense,
      categoryId: 'entertainment',
      date: DateTime.now().subtract(const Duration(days: 8)),
      paymentMethod: PaymentMethod.creditCard,
    ),
  ];

  // ── Budgets ─────────────────────────────────────────────────────────────────
  static List<Budget> budgets = [
    Budget(
      id: 'b1',
      name: 'Food & Dining',
      categoryId: 'food',
      limit: 600,
      spent: 458.50,
      month: DateTime.now(),
      color: const Color(0xFF10B981),
    ),
    Budget(
      id: 'b2',
      name: 'Transport',
      categoryId: 'transport',
      limit: 300,
      spent: 183.30,
      month: DateTime.now(),
      color: const Color(0xFF06B6D4),
    ),
    Budget(
      id: 'b3',
      name: 'Shopping',
      categoryId: 'shopping',
      limit: 400,
      spent: 388.99,
      month: DateTime.now(),
      color: const Color(0xFFF59E0B),
    ),
    Budget(
      id: 'b4',
      name: 'Entertainment',
      categoryId: 'entertainment',
      limit: 150,
      spent: 75.97,
      month: DateTime.now(),
      color: const Color(0xFF8B5CF6),
    ),
    Budget(
      id: 'b5',
      name: 'Health & Medical',
      categoryId: 'health',
      limit: 200,
      spent: 129.00,
      month: DateTime.now(),
      color: const Color(0xFFF43F5E),
    ),
    Budget(
      id: 'b6',
      name: 'Utilities',
      categoryId: 'utilities',
      limit: 250,
      spent: 147.39,
      month: DateTime.now(),
      color: const Color(0xFF14B8A6),
    ),
  ];

  // ── Goals ───────────────────────────────────────────────────────────────────
  static List<Goal> goals = [
    Goal(
      id: 'g1',
      name: 'Europe Vacation',
      emoji: '✈️',
      target: 5000,
      saved: 3200,
      deadline: DateTime.now().add(const Duration(days: 180)),
      color: const Color(0xFF06B6D4),
      backgroundColor: const Color(0x1906B6D4),
    ),
    Goal(
      id: 'g2',
      name: 'Emergency Fund',
      emoji: '🛡️',
      target: 10000,
      saved: 6500,
      deadline: DateTime.now().add(const Duration(days: 365)),
      color: const Color(0xFF10B981),
      backgroundColor: const Color(0x1910B981),
    ),
    Goal(
      id: 'g3',
      name: 'New MacBook Pro',
      emoji: '💻',
      target: 3499,
      saved: 2800,
      deadline: DateTime.now().add(const Duration(days: 60)),
      color: const Color(0xFF3B82F6),
      backgroundColor: const Color(0x193B82F6),
    ),
    Goal(
      id: 'g4',
      name: 'House Deposit',
      emoji: '🏡',
      target: 50000,
      saved: 18000,
      deadline: DateTime.now().add(const Duration(days: 730)),
      color: const Color(0xFFF59E0B),
      backgroundColor: const Color(0x19F59E0B),
    ),
    Goal(
      id: 'g5',
      name: 'Car Fund',
      emoji: '🚗',
      target: 25000,
      saved: 9500,
      deadline: DateTime.now().add(const Duration(days: 540)),
      color: const Color(0xFFF97316),
      backgroundColor: const Color(0x19F97316),
    ),
  ];

  // ── Bills ────────────────────────────────────────────────────────────────────
  static List<Bill> bills = [
    Bill(
      id: 'bill1',
      name: 'Netflix',
      merchant: 'Netflix Inc.',
      amount: 15.99,
      dueDate: DateTime.fromMillisecondsSinceEpoch(1773489600000),
      icon: Icons.movie_rounded,
      color: Color(0xFFF43F5E),
    ),
    Bill(
      id: 'bill2',
      name: 'Electric Bill',
      merchant: 'City Power',
      amount: 67.40,
      dueDate: DateTime.fromMillisecondsSinceEpoch(1773748800000),
      icon: Icons.bolt_rounded,
      color: Color(0xFFF59E0B),
    ),
    Bill(
      id: 'bill3',
      name: 'Internet',
      merchant: 'Comcast',
      amount: 79.99,
      dueDate: DateTime.fromMillisecondsSinceEpoch(1774008000000),
      icon: Icons.wifi_rounded,
      color: Color(0xFF06B6D4),
    ),
    Bill(
      id: 'bill4',
      name: 'Gym Membership',
      merchant: 'FitLife',
      amount: 49.00,
      dueDate: DateTime.fromMillisecondsSinceEpoch(1774353600000),
      icon: Icons.fitness_center_rounded,
      color: Color(0xFF10B981),
    ),
  ];

  // ── Monthly Data (for charts) ─────────────────────────────────────────────
  static final List<double> monthlyIncome = [
    4800,
    5200,
    4900,
    5500,
    5200,
    5800,
    6000,
  ];
  static final List<double> monthlyExpenses = [
    3200,
    3800,
    3100,
    4200,
    3500,
    3900,
    1450.75,
  ];
  static final List<String> monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
  ];

  // ── Summary Metrics ──────────────────────────────────────────────────────────
  static double get monthlyIncomeCurrent => 6000.00;
  static double get monthlyExpenseCurrent => 1450.75;
  static double get savingsThisMonth =>
      monthlyIncomeCurrent - monthlyExpenseCurrent;
  static double get spendingScore => 78;
  static double get aiHealthScore => 85;

  static final Map<String, double> categorySpending = {
    'food': 458.50,
    'transport': 183.30,
    'shopping': 388.99,
    'entertainment': 75.97,
    'health': 129.00,
    'utilities': 147.39,
    'travel': 420.00,
    'education': 19.99,
  };
}
