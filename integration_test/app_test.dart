import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// This file is the entry point for the integration tests. It imports all the other test files and runs them.
import 'create_event_integration_test.dart' as create_event_integration_test;
import 'create_team_integration_test.dart' as create_team_integration_test;
import 'login_integration_test.dart' as login_integration_test;
import 'signup_integration_test.dart' as signup_integration_test;
import 'logout_integration_test.dart' as logout_integration_test;


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // WARNING: The integration tests are currently failing when testing in a group due to the navigation 
  // between the tests (doesn't reset back to the start). 
  // The tests work fine when run individually.
  group('App Integration Tests', () {

    // Run all integration tests
    create_event_integration_test.main();
    create_team_integration_test.main();
    login_integration_test.main();
    signup_integration_test.main();
    logout_integration_test.main();
  });
}