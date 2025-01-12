import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../models/team.dart';

class TeamsService {
  static const String baseUrl = 'https://team-management-api.dops.tech/api/v2';
  final storage = const FlutterSecureStorage();
  final logger = Logger();

  // Get all teams
  Future<List<Team>> getTeams() async {
    try {
      final token = await storage.read(key: 'jwt'); // Updated key

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/teams'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> teamsJson = jsonResponse['data'];

        return teamsJson.map((json) => Team.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      logger.d('Failed to load tedams: $e');
      throw Exception('Failesd to load teamssss: $e');
    }
  }

  // Get a single team
  Future<Team> getTeam(int teamId) async {
    try {
      final token = await storage.read(key: 'jwt');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/teams/$teamId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Team.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to load team: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load team: $e');
    }
  }

  // Create a team
  Future<Team> createTeam(Team team) async {
    final token = await storage.read(key: 'jwt');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/teams'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': team.name,
        'description': team.description,
        'metadata': {'Icon': 'calendar_today'},
      }),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return Team.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to create team: ${response.statusCode}');
    }
  }

  // Delete member from team
  Future<void> removeMember(int teamId, int userId) async {
    final token = await storage.read(key: 'jwt');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/teams/$teamId/removeUser'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove member: ${response.statusCode}');
    }
  }

  // Add member to team
  Future<void> addMember(int teamId, int userId) async {
    final token = await storage.read(key: 'jwt');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/teams/$teamId/addUser'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add member: ${response.statusCode}');
    }
  }

  // Update/edit team
  Future<Team> updateTeam(Team team) async {
    final token = await storage.read(key: 'jwt');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/teams/${team.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': team.name,
        'description': team.description,
        'metadata': {'Icon': 'calendar_month'},
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Team.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to update team: ${response.statusCode}');
    }
  }

  // Leave team as a member
  Future<void> leaveTeam(int teamId) async {
    final token = await storage.read(key: 'jwt');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/teams/$teamId/leave'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to leave team: ${response.statusCode}');
    }
  }

  // Delete team
  Future<void> deleteTeam(int teamId) async {
    final token = await storage.read(key: 'jwt');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/teams/$teamId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete team: ${response.statusCode}');
    }
  }
}
