import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/models/transaction.dart';

void main() {
  group('Transaction Model Tests', () {
    test('Transaction creation', () {
      final now = DateTime.now();
      final transaction = Transaction(
        type: 'income',
        amount: 100.0,
        description: 'Test Income',
        category: 'Salary',
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(transaction.type, 'income');
      expect(transaction.amount, 100.0);
      expect(transaction.description, 'Test Income');
      expect(transaction.category, 'Salary');
    });

    test('Transaction toMap', () {
      final now = DateTime.now();
      final transaction = Transaction(
        id: 1,
        type: 'expense',
        amount: 50.0,
        description: 'Test Expense',
        category: 'Food',
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      final map = transaction.toMap();
      expect(map['id'], 1);
      expect(map['type'], 'expense');
      expect(map['amount'], 50.0);
      expect(map['description'], 'Test Expense');
      expect(map['category'], 'Food');
    });

    test('Transaction fromMap', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'type': 'income',
        'amount': 100.0,
        'description': 'Test',
        'category': 'Salary',
        'date': now.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final transaction = Transaction.fromMap(map);
      expect(transaction.id, 1);
      expect(transaction.type, 'income');
      expect(transaction.amount, 100.0);
      expect(transaction.description, 'Test');
    });

    test('Transaction copyWith', () {
      final now = DateTime.now();
      final transaction = Transaction(
        id: 1,
        type: 'income',
        amount: 100.0,
        description: 'Original',
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      final updated = transaction.copyWith(
        description: 'Updated',
        amount: 200.0,
      );

      expect(updated.id, 1);
      expect(updated.description, 'Updated');
      expect(updated.amount, 200.0);
      expect(updated.type, 'income');
    });
  });
}
