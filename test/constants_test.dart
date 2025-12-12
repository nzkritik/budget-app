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

    test('Expense categories are not empty', () {
      expect(AppConstants.expenseCategories.isNotEmpty, true);
    });

    test('All expense categories are unique', () {
      final categories = AppConstants.expenseCategories;
      final uniqueCategories = categories.toSet();
      expect(categories.length, uniqueCategories.length,
          reason: 'All categories should be unique');
    });
  });
}
