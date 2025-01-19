import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Team Creation Flow Test', () {
    // Test 1:  Create a new team
    testWidgets('Create new team', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Find username/password fields and enter valid credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'Daniel');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Tap login button and wait for navigation 
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      // Navigate to create team
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Team'));
      await tester.pumpAndSettle();

      // Generate unique team name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueTeamName = 'Test Team $timestamp';

      // Fill team creation form
      await tester.enterText(find.byType(TextFormField).at(0), uniqueTeamName);
      await tester.enterText(find.byType(TextFormField).at(1), 'Test team description');

      // Submit empty form
      final createButton = find.widgetWithText(FilledButton, 'Create Team');
      await tester.ensureVisible(createButton);
      await tester.pumpAndSettle();
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Verify successful team creation
      expect(find.text('Create Team'), findsOneWidget);
      expect(find.widgetWithText(SnackBar, 'Successfully create a team'), findsOneWidget);
    });

    // Test 2:  Submit empty create team form
    testWidgets('Submitting empty create team form', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Find username/password fields and enter valid credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'Daniel');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Tap login button and wait for navigation 
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      // Navigate to create team
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Team'));
      await tester.pumpAndSettle();

      // Submit empty form
      final createButton = find.widgetWithText(FilledButton, 'Create Team');
      await tester.ensureVisible(createButton);
      await tester.pumpAndSettle();
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Verify validation messages
      expect(find.text('Please enter a team name'), findsOneWidget);
      expect(find.text('Please enter a description'), findsOneWidget);
    });
  });

  
}