import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/utils/constants.dart';

void main() {
  group('AppConstants Expense Categories Tests', () {
    test('Expense categories contain all required categories', () {
      expect(AppConstants.expenseCategories, contains('Mortgage'));
      expect(AppConstants.expenseCategories, contains('Management Fees'));
      expect(AppConstants.expenseCategories, contains('Accountant'));
      expect(AppConstants.expenseCategories, contains('Maintenance'));
    });

    test('Expense categories list has correct count', () {
      // Original 8 + 4 new = 12 total
      expect(AppConstants.expenseCategories.length, 12);
    });

    test('New expense categories are distinct', () {
      final categories = AppConstants.expenseCategories;
      final uniqueCategories = categories.toSet();
      expect(categories.length, uniqueCategories.length,
          reason: 'All categories should be unique');
    });
  });
}
