import 'package:cash_up/models/transaction_model.dart';
import 'package:cash_up/widgets/receipt_card.dart';
import 'package:cash_up/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ReceiptCard displays card, amount, reference, and status badge', (tester) async {
    final tx = TransactionModel(
      id: 'CU8F2A1',
      amount: 125000,
      brand: 'Visa',
      last4: '4821',
      status: TransactionStatus.success,
      createdAt: DateTime(2026, 11, 9, 9, 41),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReceiptCard(transaction: tx),
        ),
      ),
    );

    expect(find.text('Kartu'), findsOneWidget);
    expect(find.text('Visa •••• 4821'), findsOneWidget);
    expect(find.text('No. referensi'), findsOneWidget);
    expect(find.text('CU8F2A1'), findsOneWidget);
    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text('Berhasil'), findsOneWidget);
  });
}
