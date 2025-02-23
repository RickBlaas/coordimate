import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../models/event.dart';

class EventService {
  static const String baseUrl = 'https://team-management-api.dops.tech/api/v2';
  final storage = const FlutterSecureStorage();
  final logger = Logger();

  // GET /events
  Future<List<Event>> getEvents() async {
    final token = await storage.read(key: 'jwt');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/events'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> eventsJson = jsonResponse['data'];
      return eventsJson.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events: ${response.statusCode}');
    }
  }

  // GET /events/{id}
  Future<Event> getEvent(int id) async {
    final token = await storage.read(key: 'jwt');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/events/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Event.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load event: ${response.statusCode}');
    }
  }

  Future<Event> createEvent(Event event) async {
    final token = await storage.read(key: 'jwt');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': event.title,
        'description': event.description,
        'location': event.location,
        'teamId': event.teamId,
        'datetimeStart': event.datetimeStart.toUtc().toIso8601String(),
        'datetimeEnd': event.datetimeEnd.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return Event.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to create event: ${response.statusCode}');
    }
  }

  // PUT /events/{id}
  Future<Event> updateEvent(Event event) async {
    final token = await storage.read(key: 'jwt');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.put(
      Uri.parse('$baseUrl/events/${event.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
      'title': event.title,
      'description': event.description,
      'teamId': event.teamId,
      'datetimeStart': event.datetimeStart.toUtc().toIso8601String(),
      'datetimeEnd': event.datetimeEnd.toUtc().toIso8601String(),
      'location': event.location,
      'metadata': event.metadata ?? {'Icon': 'calendar_today'},
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Event.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to update event: ${response.statusCode}');
    }
  }

  // DELETE /events/{id}
  Future<void> deleteEvent(int id) async {
    final token = await storage.read(key: 'jwt');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/events/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event: ${response.statusCode}');
    }
  }
}
