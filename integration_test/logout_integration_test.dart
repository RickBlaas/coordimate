import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Logout Flow Tests', () {
    testWidgets('Successfully logout from app', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(find.byType(TextFormField).at(0), 'Daniel');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      // Logout button for desktop & mobile
      final logoutButtonDesktop = find.widgetWithIcon(TextButton, Icons.logout);
      final logoutButtonMobile = find.byIcon(Icons.logout);

      // Tap correct logout button
      if (logoutButtonDesktop.evaluate().isNotEmpty) {
        await tester.tap(logoutButtonDesktop);
      } else {
        await tester.tap(logoutButtonMobile);
      }
      await tester.pumpAndSettle();

      // Confirm logout in dialog
      await tester.tap(find.widgetWithText(TextButton, 'Logout'));
      await tester.pumpAndSettle();

      // Verify we're back at login page
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Homepagina'), findsNothing);
    });
  });
}