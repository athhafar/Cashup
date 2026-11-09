import 'package:cash_up/widgets/keypad_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('KeypadWidget displays all numbers and responds to tap', (tester) async {
    String pressed = '';
    bool deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KeypadWidget(
            onKeyPress: (val) => pressed = val,
            onDeletePress: () => deleted = true,
          ),
        ),
      ),
    );

    // Verify presence of keys 1-9, 0, 000
    expect(find.text('1'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('000'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // Tap '5'
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    expect(pressed, '5');

    // Tap backspace icon
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();
    expect(deleted, true);
  });
}
