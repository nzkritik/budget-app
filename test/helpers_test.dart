import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/utils/helpers.dart';

void main() {
  group('Helpers Tests', () {
    test('formatCurrency formats correctly', () {
      expect(Helpers.formatCurrency(100.50), '\$100.50');
      expect(Helpers.formatCurrency(1000.00), '\$1,000.00');
      expect(Helpers.formatCurrency(0.99), '\$0.99');
    });

    test('formatDate formats correctly', () {
      final date = DateTime(2024, 1, 15);
      expect(Helpers.formatDate(date), 'Jan 15, 2024');
    });

    test('formatMonthYear formats correctly', () {
      final date = DateTime(2024, 1, 15);
      expect(Helpers.formatMonthYear(date), 'January 2024');
    });

    test('getFirstDayOfMonth returns correct date', () {
      final result = Helpers.getFirstDayOfMonth(2024, 3);
      expect(result.year, 2024);
      expect(result.month, 3);
      expect(result.day, 1);
    });

    test('getLastDayOfMonth returns correct date', () {
      final result = Helpers.getLastDayOfMonth(2024, 2);
      expect(result.year, 2024);
      expect(result.month, 2);
      expect(result.day, 29); // 2024 is a leap year
    });

    test('isSameMonth returns true for same month', () {
      final date1 = DateTime(2024, 3, 15);
      final date2 = DateTime(2024, 3, 20);
      expect(Helpers.isSameMonth(date1, date2), true);
    });

    test('isSameMonth returns false for different months', () {
      final date1 = DateTime(2024, 3, 15);
      final date2 = DateTime(2024, 4, 15);
      expect(Helpers.isSameMonth(date1, date2), false);
    });
  });
}
