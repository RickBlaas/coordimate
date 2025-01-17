import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coordimate/pages/home.dart';

void main() {
  testWidgets('HomePage shows Create Team button', (WidgetTester tester) async {
    // Build HomePage widget
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );

    // Find button with text 'Ga naar teams'
    final buttonFinder = find.widgetWithText(FilledButton, 'Ga naar teams');
    
    // Verify button exists
    expect(buttonFinder, findsOneWidget);
  });
}