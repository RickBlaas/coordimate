import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Tests', () {

    // Test 1: Login with valid credentials
    testWidgets('Login with valid credentials', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Find username/password fields and enter valid credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'Daniel');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Tap login button and wait for navigation 
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      // Verify navigation to home page
      expect(find.text('Homepagina'), findsOneWidget);
    });

    // Test 2: Login with invalid credentials
    testWidgets('Login with invalid credentials', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Find username/password fields and enter invalid credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'wronguser');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');

      // Tap login button and wait for navigation 
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      // Verify we did not navigate to home page
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Homepagina'), findsNothing);
    });

    // Test 3: Login with empty fields
    testWidgets('Login with empty fields', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Tap login button without entering any text
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      // Verify we did not navigate to home page
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Homepagina'), findsNothing);
    });
  });
}