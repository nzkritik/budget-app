import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/main.dart';

void main() {
  testWidgets('App starts and shows Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const BudgetApp());

    expect(find.text('Budget App'), findsOneWidget);
    expect(find.text('Total Income'), findsOneWidget);
    expect(find.text('Total Expenses'), findsOneWidget);
    expect(find.text('Current Balance'), findsOneWidget);
  });
}
