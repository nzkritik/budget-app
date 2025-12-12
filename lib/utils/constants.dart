import 'package:flutter/material.dart';

class AppConstants {
  // Transaction types
  static const String typeIncome = 'income';
  static const String typeExpense = 'expense';

  // Default categories
  static const List<String> incomeCategories = [
    'Salary',
    'Business',
    'Investments',
    'Gifts',
    'Other Income',
  ];

  static const List<String> expenseCategories = [
    'Food & Dining',
    'Shopping',
    'Transportation',
    'Bills & Utilities',
    'Entertainment',
    'Healthcare',
    'Education',
    'Mortgage',
    'Management Fees',
    'Accountant',
    'Maintenance',
    'Other Expense',
  ];

  // Colors
  static const Color incomeColor = Colors.green;
  static const Color expenseColor = Colors.red;
  static const Color primaryColor = Colors.blue;

  // Date formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String shortMonthFormat = 'MMM';
}
