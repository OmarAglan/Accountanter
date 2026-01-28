import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accountanter/features/clients/widgets/client_summary_card.dart';
import 'package:accountanter/features/dashboard/widgets/action_item_card.dart';
import 'package:accountanter/features/expenses/widgets/expense_summary_card.dart';
import 'package:accountanter/features/inventory/widgets/inventory_summary_card.dart';

void main() {
  Future<void> pumpTestWidget(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('ActionItemCard renders title and subtitle', (WidgetTester tester) async {
    await pumpTestWidget(
      tester,
      const ActionItemCard(
        icon: Icons.check,
        color: Colors.blue,
        title: 'Review invoices',
        subtitle: '3 pending approvals',
      ),
    );

    expect(find.text('Review invoices'), findsOneWidget);
    expect(find.text('3 pending approvals'), findsOneWidget);
  });

  testWidgets('ClientSummaryCard renders value and title', (WidgetTester tester) async {
    await pumpTestWidget(
      tester,
      const ClientSummaryCard(
        icon: Icons.person,
        title: 'Clients',
        value: '12',
        color: Colors.green,
      ),
    );

    expect(find.text('Clients'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('ExpenseSummaryCard renders value and subtitle', (WidgetTester tester) async {
    await pumpTestWidget(
      tester,
      const ExpenseSummaryCard(
        icon: Icons.receipt_long,
        title: 'Total Expenses',
        value: '\$1,234.00',
        color: Colors.red,
        subtitle: 'This month',
      ),
    );

    expect(find.text('Total Expenses'), findsOneWidget);
    expect(find.text('\$1,234.00'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
  });

  testWidgets('InventorySummaryCard renders value and title', (WidgetTester tester) async {
    await pumpTestWidget(
      tester,
      const InventorySummaryCard(
        icon: Icons.inventory_2,
        title: 'Items',
        value: '48',
        color: Colors.orange,
      ),
    );

    expect(find.text('Items'), findsOneWidget);
    expect(find.text('48'), findsOneWidget);
  });
}
