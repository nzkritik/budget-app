import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/models/category.dart';

void main() {
  group('Category Model Tests', () {
    test('Category creation', () {
      final now = DateTime.now();
      final category = Category(
        name: 'Salary',
        type: 'income',
        isDefault: true,
        createdAt: now,
      );

      expect(category.name, 'Salary');
      expect(category.type, 'income');
      expect(category.isDefault, true);
      expect(category.createdAt, now);
    });

    test('Category toMap', () {
      final now = DateTime.now();
      final category = Category(
        id: 1,
        name: 'Food',
        type: 'expense',
        isDefault: false,
        createdAt: now,
      );

      final map = category.toMap();
      expect(map['id'], 1);
      expect(map['name'], 'Food');
      expect(map['type'], 'expense');
      expect(map['is_default'], 0);
      expect(map['created_at'], now.toIso8601String());
    });

    test('Category toMap with default category', () {
      final now = DateTime.now();
      final category = Category(
        id: 2,
        name: 'Salary',
        type: 'income',
        isDefault: true,
        createdAt: now,
      );

      final map = category.toMap();
      expect(map['is_default'], 1);
    });

    test('Category fromMap', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'name': 'Entertainment',
        'type': 'expense',
        'is_default': 0,
        'created_at': now.toIso8601String(),
      };

      final category = Category.fromMap(map);
      expect(category.id, 1);
      expect(category.name, 'Entertainment');
      expect(category.type, 'expense');
      expect(category.isDefault, false);
    });

    test('Category fromMap with default category', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'name': 'Salary',
        'type': 'income',
        'is_default': 1,
        'created_at': now.toIso8601String(),
      };

      final category = Category.fromMap(map);
      expect(category.isDefault, true);
    });

    test('Category copyWith', () {
      final now = DateTime.now();
      final category = Category(
        id: 1,
        name: 'Old Name',
        type: 'income',
        isDefault: false,
        createdAt: now,
      );

      final updated = category.copyWith(
        name: 'New Name',
      );

      expect(updated.id, 1);
      expect(updated.name, 'New Name');
      expect(updated.type, 'income');
      expect(updated.isDefault, false);
      expect(updated.createdAt, now);
    });
  });
}
