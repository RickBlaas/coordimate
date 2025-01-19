import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:coordimate/services/teams_service.dart';
import 'package:coordimate/models/team.dart';
import 'teams_service_test.mocks.dart';

// Generate Mocks
@GenerateMocks([http.Client, FlutterSecureStorage])

void main() {
  late TeamsService teamsService;
  late MockClient mockClient;
  late MockFlutterSecureStorage mockStorage;
  const testToken = 'test_token';
  const testTeamId = 1;

  setUp(() {
    mockClient = MockClient();
    mockStorage = MockFlutterSecureStorage();
    teamsService = TeamsService(client: mockClient, storage: mockStorage);
  });
  

  group('TeamsService', () {
    // Test GET all teams
    group('Get teams tests', () {
      test('Get teams successfully', () async {
        // Mock storage to return test token
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => testToken);

        // Mock HTTP GET request to return team data
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({
            "message": "Success",
            "data": [
              {
                "id": 1,
                "name": "Team Alpha",
                "description": "First team",
                "metadata": {"Icon": "calendar_today"},
                "members": [{"id": 1, "name": "Alice"}],
                "ownerId": 1
              }
            ],
            "error": null
          }), 
          200
        ));

        // Call GET teams method 
        final teams = await teamsService.getTeams();

        // Expectations
        expect(teams.length, 1);
        expect(teams[0].name, 'Team Alpha');
        expect(teams[0].description, 'First team');
      });

      test('throws exception when token is missing', () async {
        // Mock storage to return null token
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => null);

        // Expectation: Throws exception with message
        expect(
          () => teamsService.getTeams(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No authentication token found')
          ))
        );
      });

      test('throws exception on server error', () async {
        // Mock storage to return test token
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => testToken);

        // Mock HTTP GET request to return server error
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({
            "message": "Server Error",
            "data": null,
            "error": "Internal server error"
          }), 
          500
        ));

        // Expectation: Throws exception with message
        expect(
          () => teamsService.getTeams(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to load teams: 500')
          ))
        );
      });
    });
    
    // Test create team 
    group('Create a team', () {
      // Test team data
      final testTeam = Team(
        name: 'Test Team',
        description: 'Test Description',
      );

      test('creates team successfully', () async {
        // Mock storage to return test token
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => testToken);

        // Mock HTTP POST request to return team data
        when(mockClient.post(
          Uri.parse('${TeamsService.baseUrl}/teams'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({
            "message": "Success",
            "data": {
              "id": 1,
              "name": "Test Team",
              "description": "Test Description",
              "metadata": {"Icon": "calendar_today"},
              "members": [{"id": 1, "name": "Alice"}],
              "ownerId": 1
            },
            "error": null
          }), 
          201
        ));

        // POST team data and get result
        final result = await teamsService.createTeam(testTeam);

        // Expectations: Check team data
        expect(result.name, equals('Test Team'));
        expect(result.description, equals('Test Description'));
      });

      test('throws when token is missing', () async {
        // Mock storage to return null token
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => null);

        // Expectation: Throws exception with message
        expect(
          () => teamsService.createTeam(testTeam),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No authentication token found')
          ))
        );
      });

      test('throws on server error', () async {
        // Mock storage to return test token
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => testToken);

        // Mock HTTP POST request to return server error
        when(mockClient.post(
          Uri.parse('${TeamsService.baseUrl}/teams'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({
            "message": "Error",
            "data": null,
            "error": "Server error"
          }), 
          500
        ));

        // Expectation: Throws exception with message
        expect(
          () => teamsService.createTeam(testTeam),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to create team: 500')
          ))
        );
      });
    });

    // Test delete team
    group('Delete team', () {
      test('deletes team successfully', () async {
        // Mock storage to return test token
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => testToken);

        // Mock HTTP DELETE request to return success
        when(mockClient.delete(
          Uri.parse('${TeamsService.baseUrl}/teams/1'),
          headers: {
            'Authorization': 'Bearer $testToken',
            'Content-Type': 'application/json',
          },
        )).thenAnswer((_) async => http.Response('', 200));

        // Delete team with ID 1
        await teamsService.deleteTeam(1);

        // Verify that delete request was made
        verify(mockClient.delete(
          Uri.parse('${TeamsService.baseUrl}/teams/1'),
          headers: {
            'Authorization': 'Bearer $testToken',
            'Content-Type': 'application/json',
          },
        )).called(1);
      });

      test('throws when token is missing', () async {
        // Mock storage to return null token
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => null);

        // Expectation: Throws exception with message
        expect(
          () => teamsService.deleteTeam(testTeamId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No authentication token found')
          ))
        );
      });

      test('throws exception on server error', () async {
        // Mock storage to return test token
        when(mockStorage.read(key: 'jwt'))
            .thenAnswer((_) async => testToken);

        // Mock HTTP DELETE request to return server error
        when(mockClient.delete(
          Uri.parse('${TeamsService.baseUrl}/teams/1'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode({
            "message": "Error",
            "error": "Server error"
          }), 
          500
        ));

        // Expectation: Throws exception with message
        expect(
          () => teamsService.deleteTeam(1),
          throwsA(isA<Exception>())
        );
      });
    });
  });
 
}