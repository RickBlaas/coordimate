import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:coordimate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Event Creation Flow Tests', () {
    // Test 1:  Create a new event
    testWidgets('Create new event', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(find.byType(TextFormField).at(0), 'Daniel');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      // Navigate to teams
      await tester.tap(find.text('Teams'));
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
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Team $timestamp');
      await tester.enterText(find.byType(TextFormField).at(1), 'Test team description');

      // Submit form
      await tester.tap(find.widgetWithText(FilledButton, 'Create Team'));
      await tester.pumpAndSettle();

      // Wait for snackbar to appear and dismiss
      await tester.pump(const Duration(seconds: 4)); 
      await tester.pumpAndSettle();

      // Find and scroll to newly created team
      final teamFinder = find.text(uniqueTeamName);
      await tester.scrollUntilVisible(
        teamFinder,
        500.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Select recently created team
      await tester.tap(teamFinder); 
      await tester.pumpAndSettle();

      // Find and tap event FAB (floating action button) by icon
      final eventFAB = find.ancestor(
        of: find.byIcon(Icons.event),
        matching: find.byType(FloatingActionButton),
      );
      await tester.tap(eventFAB);
      await tester.pumpAndSettle();

      // Generate unique event title
      final uniqueEventTitle = 'Test Event $timestamp';

      // Fill event creation form
      await tester.enterText(find.byType(TextFormField).at(0), uniqueEventTitle);
      await tester.enterText(find.byType(TextFormField).at(1), 'Test event description');
      await tester.pumpAndSettle();

      // Set start date
      final startDateField = find.textContaining('Start Date');
      await tester.tap(startDateField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('15')); 
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); 
      await tester.pumpAndSettle();

      // Set end date
      final endDateField = find.textContaining('End Date');
      await tester.tap(endDateField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('20')); 
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); 
      await tester.pumpAndSettle();

      // Submit form
      final createButton = find.widgetWithText(FilledButton, 'Create Event');
      await tester.ensureVisible(createButton);
      await tester.pumpAndSettle();
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Wait for the event to be loaded in the team page
      await tester.pump(const Duration(seconds: 2)); 

      // Verify event appears in list
      expect(find.text(uniqueEventTitle), findsOneWidget);
    });

    // Test 2:  Submitting empty create event form
    testWidgets('Submitting empty create event form', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(find.byType(TextFormField).at(0), 'Daniel');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      // Navigate to teams
      await tester.tap(find.text('Teams'));
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
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Team $timestamp');
      await tester.enterText(find.byType(TextFormField).at(1), 'Test team description');

      // Submit form
      await tester.tap(find.widgetWithText(FilledButton, 'Create Team'));
      await tester.pumpAndSettle();

      // Wait for snackbar to appear and dismiss
      await tester.pump(const Duration(seconds: 4)); 
      await tester.pumpAndSettle();

      // Find and scroll to newly created team
      final teamFinder = find.text(uniqueTeamName);
      await tester.scrollUntilVisible(
        teamFinder,
        500.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Select recently created team
      await tester.tap(teamFinder); 
      await tester.pumpAndSettle();

      // Find and tap event FAB (floating action button) by icon
      final eventFAB = find.ancestor(
        of: find.byIcon(Icons.event),
        matching: find.byType(FloatingActionButton),
      );
      await tester.tap(eventFAB);
      await tester.pumpAndSettle();

      // Try to submit empty form
      final createButton = find.widgetWithText(FilledButton, 'Create Event');
      await tester.ensureVisible(createButton);
      await tester.pumpAndSettle();
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Verify validation messages
      expect(find.text('Please enter an event title'), findsOneWidget);
      expect(find.text('Please enter a description'), findsOneWidget);
    });
  });
}