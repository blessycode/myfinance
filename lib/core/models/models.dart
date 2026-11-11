import 'package:flutter/material.dart';

enum TransactionType { income, expense }

enum PaymentMethod { cash, creditCard, debitCard, bankTransfer, wallet }

class AccountSummary {
  final String id;
  final String name;
  final String type;
  final String currency;
  final double balance;
  final IconData icon;
  final Color? color;

  const AccountSummary({
    this.id = '',
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
    required this.icon,
    this.color,
  });
}

class Transaction {
  final String id;
  final String title;
  final String merchant;
  final double amount;
  final String currency;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String? notes;
  final String? receiptUrl;

  const Transaction({
    required this.id,
    required this.title,
    required this.merchant,
    required this.amount,
    this.currency = 'USD',
    required this.type,
    required this.categoryId,
    required this.date,
    required this.paymentMethod,
    this.notes,
    this.receiptUrl,
  });
}

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

class Budget {
  final String id;
  final String name;
  final String categoryId;
  final double limit;
  final double spent;
  final DateTime month;
  final Color color;

  const Budget({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.limit,
    required this.spent,
    required this.month,
    required this.color,
  });

  double get remaining => limit - spent;
  double get percentage => (spent / limit).clamp(0.0, 1.0);
  bool get isExceeded => spent > limit;
  bool get isWarning => percentage > 0.8;
}

class Goal {
  final String id;
  final String name;
  final String emoji;
  final double target;
  final double saved;
  final DateTime deadline;
  final Color color;
  final Color backgroundColor;

  const Goal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.target,
    required this.saved,
    required this.deadline,
    required this.color,
    required this.backgroundColor,
  });

  double get percentage => (saved / target).clamp(0.0, 1.0);
  double get remaining => target - saved;
  bool get isCompleted => saved >= target;

  int get daysRemaining => deadline.difference(DateTime.now()).inDays;
}

class Bill {
  final String id;
  final String name;
  final String merchant;
  final double amount;
  final DateTime dueDate;
  final IconData icon;
  final Color color;

  const Bill({
    required this.id,
    required this.name,
    required this.merchant,
    required this.amount,
    required this.dueDate,
    required this.icon,
    required this.color,
  });

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  bool get isOverdue => daysUntilDue < 0;
  bool get isDueSoon => daysUntilDue <= 3 && daysUntilDue >= 0;
}
