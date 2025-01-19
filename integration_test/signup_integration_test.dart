import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Tests', () {
    // Test 1: Login with valid credentials
    testWidgets('Signup new account with valid credentials', (tester) async {

      // Generate unique username with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueUsername = 'testuser_$timestamp';

      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Tap register button to switch to signup mode
      await tester.tap(find.text('REGISTER'));
      await tester.pumpAndSettle();
      
      // Enter signup details
      await tester.enterText(find.byType(TextFormField).at(0), uniqueUsername);
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');  
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');  

      // Tap signup button and wait for navigation
      await tester.tap(find.text('REGISTER'));
      await tester.pumpAndSettle();

      // Verify navigation to home page
      expect(find.text('Homepagina'), findsOneWidget);
    });

    // Test 2: Signup with existing username
    testWidgets('Signup with existing username', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Tap register button to switch to signup mode
      await tester.tap(find.text('REGISTER'));
      await tester.pumpAndSettle();
      
      // Enter signup details with existing username
      await tester.enterText(find.byType(TextFormField).at(0), 'Daniel');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      // Tap signup button
      await tester.tap(find.text('REGISTER'));
      await tester.pumpAndSettle();

      // Verify we did not navigate to home page
      expect(find.text('REGISTER'), findsOneWidget);
      expect(find.text('Homepagina'), findsNothing);
    });

    // Test 3: Signup with mismatching passwords
    testWidgets('Signup with mismatched passwords', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Tap register button to switch to signup mode
      await tester.tap(find.text('REGISTER'));
      await tester.pumpAndSettle();
      
      // Enter signup details with mismatched passwords
      await tester.enterText(find.byType(TextFormField).at(0), 'testuser');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'differentpass');

      // Tap signup button
      await tester.tap(find.text('REGISTER'));
      await tester.pumpAndSettle();

      // Verify we did not navigate to home page
      expect(find.text('REGISTER'), findsOneWidget);
      expect(find.text('Homepagina'), findsNothing);
    });

    // Test 4: Signup with empty fields
    testWidgets('Signup with empty fields', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Tap register button to switch to signup mode
      await tester.tap(find.text('REGISTER'));
      await tester.pumpAndSettle();
      
      // Tap signup button
      await tester.tap(find.text('REGISTER'));
      await tester.pumpAndSettle();

      // Verify we did not navigate to home page
      expect(find.text('REGISTER'), findsOneWidget);
      expect(find.text('Homepagina'), findsNothing);
    });
  });
}