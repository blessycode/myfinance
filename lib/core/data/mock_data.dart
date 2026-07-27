import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

class MockData {
  // ── Categories ──────────────────────────────────────────────────────────────
  static final List<Category> categories = [
    const Category(id: 'food', name: 'Food & Dining', icon: Icons.restaurant_rounded, color: Color(0xFFEF4444), backgroundColor: Color(0xFFFF444415)),
    const Category(id: 'transport', name: 'Transport', icon: Icons.directions_car_rounded, color: Color(0xFF06B6D4), backgroundColor: Color(0xFF06B6D415)),
    const Category(id: 'shopping', name: 'Shopping', icon: Icons.shopping_bag_rounded, color: Color(0xFF8B5CF6), backgroundColor: Color(0xFF8B5CF615)),
    const Category(id: 'health', name: 'Health', icon: Icons.favorite_rounded, color: Color(0xFFEF4444), backgroundColor: Color(0xFFEF444415)),
    const Category(id: 'entertainment', name: 'Entertainment', icon: Icons.movie_rounded, color: Color(0xFFF59E0B), backgroundColor: Color(0xFFF59E0B15)),
    const Category(id: 'utilities', name: 'Utilities', icon: Icons.bolt_rounded, color: Color(0xFF10B981), backgroundColor: Color(0xFF10B98115)),
    const Category(id: 'education', name: 'Education', icon: Icons.school_rounded, color: Color(0xFF14B8A6), backgroundColor: Color(0xFF14B8A615)),
    const Category(id: 'travel', name: 'Travel', icon: Icons.flight_rounded, color: Color(0xFFEC4899), backgroundColor: Color(0xFFEC489915)),
    const Category(id: 'income', name: 'Salary', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF22C55E), backgroundColor: Color(0xFF22C55E15)),
    const Category(id: 'freelance', name: 'Freelance', icon: Icons.work_rounded, color: Color(0xFF10B981), backgroundColor: Color(0xFF10B98115)),
  ];

  static Category categoryById(String id) =>
      categories.firstWhere((c) => c.id == id, orElse: () => categories.first);

  // ── Transactions ─────────────────────────────────────────────────────────────
  static final List<Transaction> transactions = [
    Transaction(id: 't1', title: 'Starbucks Coffee', merchant: 'Starbucks', amount: 8.50, type: TransactionType.expense, categoryId: 'food', date: DateTime.now().subtract(const Duration(hours: 2)), paymentMethod: PaymentMethod.creditCard),
    Transaction(id: 't2', title: 'Monthly Salary', merchant: 'TechCorp Inc.', amount: 5200.00, type: TransactionType.income, categoryId: 'income', date: DateTime.now().subtract(const Duration(days: 1)), paymentMethod: PaymentMethod.bankTransfer),
    Transaction(id: 't3', title: 'Uber Ride', merchant: 'Uber', amount: 18.30, type: TransactionType.expense, categoryId: 'transport', date: DateTime.now().subtract(const Duration(days: 1)), paymentMethod: PaymentMethod.wallet),
    Transaction(id: 't4', title: 'Netflix Subscription', merchant: 'Netflix', amount: 15.99, type: TransactionType.expense, categoryId: 'entertainment', date: DateTime.now().subtract(const Duration(days: 2)), paymentMethod: PaymentMethod.creditCard),
    Transaction(id: 't5', title: 'Whole Foods Market', merchant: 'Whole Foods', amount: 94.20, type: TransactionType.expense, categoryId: 'food', date: DateTime.now().subtract(const Duration(days: 2)), paymentMethod: PaymentMethod.debitCard),
    Transaction(id: 't6', title: 'Freelance Project', merchant: 'Client A', amount: 800.00, type: TransactionType.income, categoryId: 'freelance', date: DateTime.now().subtract(const Duration(days: 3)), paymentMethod: PaymentMethod.bankTransfer),
    Transaction(id: 't7', title: 'Electric Bill', merchant: 'City Power', amount: 67.40, type: TransactionType.expense, categoryId: 'utilities', date: DateTime.now().subtract(const Duration(days: 3)), paymentMethod: PaymentMethod.bankTransfer),
    Transaction(id: 't8', title: 'Amazon Purchase', merchant: 'Amazon', amount: 129.99, type: TransactionType.expense, categoryId: 'shopping', date: DateTime.now().subtract(const Duration(days: 4)), paymentMethod: PaymentMethod.creditCard),
    Transaction(id: 't9', title: 'Gym Membership', merchant: 'FitLife Gym', amount: 49.00, type: TransactionType.expense, categoryId: 'health', date: DateTime.now().subtract(const Duration(days: 5)), paymentMethod: PaymentMethod.creditCard),
    Transaction(id: 't10', title: 'Flight Tickets', merchant: 'Delta Airlines', amount: 420.00, type: TransactionType.expense, categoryId: 'travel', date: DateTime.now().subtract(const Duration(days: 6)), paymentMethod: PaymentMethod.creditCard),
    Transaction(id: 't11', title: 'Online Course', merchant: 'Udemy', amount: 19.99, type: TransactionType.expense, categoryId: 'education', date: DateTime.now().subtract(const Duration(days: 7)), paymentMethod: PaymentMethod.creditCard),
    Transaction(id: 't12', title: 'Spotify Premium', merchant: 'Spotify', amount: 9.99, type: TransactionType.expense, categoryId: 'entertainment', date: DateTime.now().subtract(const Duration(days: 8)), paymentMethod: PaymentMethod.creditCard),
    Transaction(id: 't13', title: 'Doctor Visit', merchant: 'City Medical', amount: 80.00, type: TransactionType.expense, categoryId: 'health', date: DateTime.now().subtract(const Duration(days: 9)), paymentMethod: PaymentMethod.debitCard),
    Transaction(id: 't14', title: 'Gas Station', merchant: 'Shell', amount: 55.00, type: TransactionType.expense, categoryId: 'transport', date: DateTime.now().subtract(const Duration(days: 10)), paymentMethod: PaymentMethod.debitCard),
    Transaction(id: 't15', title: 'Dividend Income', merchant: 'Fidelity', amount: 245.00, type: TransactionType.income, categoryId: 'income', date: DateTime.now().subtract(const Duration(days: 12)), paymentMethod: PaymentMethod.bankTransfer),
    Transaction(id: 't16', title: 'Restaurant Dinner', merchant: 'The Capital Grille', amount: 145.80, type: TransactionType.expense, categoryId: 'food', date: DateTime.now().subtract(const Duration(days: 13)), paymentMethod: PaymentMethod.creditCard),
    Transaction(id: 't17', title: 'New Shoes', merchant: 'Nike Store', amount: 159.00, type: TransactionType.expense, categoryId: 'shopping', date: DateTime.now().subtract(const Duration(days: 14)), paymentMethod: PaymentMethod.creditCard),
    Transaction(id: 't18', title: 'Internet Bill', merchant: 'Comcast', amount: 79.99, type: TransactionType.expense, categoryId: 'utilities', date: DateTime.now().subtract(const Duration(days: 15)), paymentMethod: PaymentMethod.bankTransfer),
  ];

  // ── Budgets ─────────────────────────────────────────────────────────────────
  static final List<Budget> budgets = [
    Budget(id: 'b1', name: 'Food & Dining', categoryId: 'food', limit: 600, spent: 458.50, month: DateTime.now(), color: AppColors.expense),
    Budget(id: 'b2', name: 'Transport', categoryId: 'transport', limit: 300, spent: 183.30, month: DateTime.now(), color: AppColors.accent),
    Budget(id: 'b3', name: 'Shopping', categoryId: 'shopping', limit: 400, spent: 388.99, month: DateTime.now(), color: const Color(0xFF8B5CF6)),
    Budget(id: 'b4', name: 'Entertainment', categoryId: 'entertainment', limit: 150, spent: 75.97, month: DateTime.now(), color: AppColors.warning),
    Budget(id: 'b5', name: 'Health & Medical', categoryId: 'health', limit: 200, spent: 129.00, month: DateTime.now(), color: const Color(0xFFEC4899)),
    Budget(id: 'b6', name: 'Utilities', categoryId: 'utilities', limit: 250, spent: 147.39, month: DateTime.now(), color: AppColors.primary),
  ];

  // ── Goals ───────────────────────────────────────────────────────────────────
  static final List<Goal> goals = [
    Goal(id: 'g1', name: 'Europe Vacation', emoji: '✈️', target: 5000, saved: 3200, deadline: DateTime.now().add(const Duration(days: 180)), color: AppColors.accent, backgroundColor: const Color(0xFF06B6D415)),
    Goal(id: 'g2', name: 'Emergency Fund', emoji: '🛡️', target: 10000, saved: 6500, deadline: DateTime.now().add(const Duration(days: 365)), color: AppColors.primary, backgroundColor: const Color(0xFF10B98115)),
    Goal(id: 'g3', name: 'New MacBook Pro', emoji: '💻', target: 3499, saved: 2800, deadline: DateTime.now().add(const Duration(days: 60)), color: const Color(0xFF8B5CF6), backgroundColor: const Color(0xFF8B5CF615)),
    Goal(id: 'g4', name: 'House Deposit', emoji: '🏡', target: 50000, saved: 18000, deadline: DateTime.now().add(const Duration(days: 730)), color: AppColors.warning, backgroundColor: const Color(0xFFF59E0B15)),
    Goal(id: 'g5', name: 'Car Fund', emoji: '🚗', target: 25000, saved: 9500, deadline: DateTime.now().add(const Duration(days: 540)), color: const Color(0xFFEC4899), backgroundColor: const Color(0xFFEC489915)),
  ];

  // ── Bills ────────────────────────────────────────────────────────────────────
  static final List<Bill> bills = [
    Bill(id: 'bill1', name: 'Netflix', merchant: 'Netflix Inc.', amount: 15.99, dueDate: DateTime.now().add(const Duration(days: 2)), icon: Icons.movie_rounded, color: const Color(0xFFEF4444)),
    Bill(id: 'bill2', name: 'Electric Bill', merchant: 'City Power', amount: 67.40, dueDate: DateTime.now().add(const Duration(days: 5)), icon: Icons.bolt_rounded, color: const Color(0xFFF59E0B)),
    Bill(id: 'bill3', name: 'Internet', merchant: 'Comcast', amount: 79.99, dueDate: DateTime.now().add(const Duration(days: 8)), icon: Icons.wifi_rounded, color: const Color(0xFF06B6D4)),
    Bill(id: 'bill4', name: 'Gym Membership', merchant: 'FitLife', amount: 49.00, dueDate: DateTime.now().add(const Duration(days: 12)), icon: Icons.fitness_center_rounded, color: const Color(0xFF10B981)),
    Bill(id: 'bill5', name: 'Spotify', merchant: 'Spotify AB', amount: 9.99, dueDate: DateTime.now().add(const Duration(days: 15)), icon: Icons.headphones_rounded, color: const Color(0xFF22C55E)),
  ];

  // ── Monthly Data (for charts) ─────────────────────────────────────────────
  static final List<double> monthlyIncome = [4800, 5200, 4900, 5500, 5200, 5800, 5200];
  static final List<double> monthlyExpenses = [3200, 3800, 3100, 4200, 3500, 3900, 3400];
  static final List<String> monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];

  // ── Summary ──────────────────────────────────────────────────────────────────
  static double get totalBalance => 24750.80;
  static double get monthlyIncomeCurrent => 6000.00;
  static double get monthlyExpenseCurrent => 1450.75;
  static double get savingsThisMonth => monthlyIncomeCurrent - monthlyExpenseCurrent;
  static double get spendingScore => 78;
  static double get aiHealthScore => 82;

  // Category spending breakdown (for pie chart)
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

  // AI insights
  static final List<Map<String, String>> aiInsights = [
    {'title': 'Spending Spike', 'body': 'Your food expenses increased by 23% this month. Consider meal prepping to save \$120/month.', 'icon': '🍔', 'type': 'warning'},
    {'title': 'Great Progress!', 'body': 'You\'re on track to reach your Europe Vacation goal 2 weeks early. Keep it up! 🎉', 'icon': '✈️', 'type': 'success'},
    {'title': 'Budget Alert', 'body': 'Shopping budget is at 97%. Only \$11.01 remaining for this month.', 'icon': '🛍️', 'type': 'danger'},
    {'title': 'Investment Tip', 'body': 'You have \$1,200 idle in savings. Moving it to a high-yield account could earn \$48/year.', 'icon': '💡', 'type': 'info'},
    {'title': 'Subscription Review', 'body': 'You\'re spending \$54.97/month on subscriptions. Review unused ones to save up to \$25.', 'icon': '🔄', 'type': 'info'},
  ];
}
