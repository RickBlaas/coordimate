import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/team.dart';
import '../services/teams_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyTeamsPage extends StatefulWidget {
  const MyTeamsPage({super.key});

  @override
  State<MyTeamsPage> createState() => _MyTeamsPageState();
}

class _MyTeamsPageState extends State<MyTeamsPage> {
  final storage = const FlutterSecureStorage();
  final TeamsService _teamsService = TeamsService();
  final logger = Logger();

  List<Team> _teams = [];
  bool _isLoading = true;
  String? _error;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserTeams();
  }

  Future<void> _loadUserTeams() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get user ID from storage
      final userIdStr = await storage.read(key: 'user_id');
      _userId = int.parse(userIdStr ?? '0');
      
      final allTeams = await _teamsService.getTeams();
      
      // Filter teams where user is owner
      // final myTeams = allTeams.where((team) => team.ownerId == _userId).toList();

      // Filter teams where user is a member
      final myTeams = allTeams.where((team) => 
        team.members.any((member) => member.id == _userId)
      ).toList();
      
      setState(() {
        _teams = myTeams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Teams', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[400],
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              context.push('/teams/create');
            },
            child: const Text('Create Team', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadUserTeams,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_teams.isEmpty) {
      return const Center(child: Text('You have no teams yet'));
    }

    return RefreshIndicator(
      onRefresh: _loadUserTeams,
      child: ListView.builder(
        itemCount: _teams.length,
        itemBuilder: (context, index) {
          final team = _teams[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(team.name),
              subtitle: Text(team.description),
              trailing: Text('Members: ${team.members.length}'),
              onTap: () {
                context.push('/teams/${team.id}');
              },
            ),
          );
        },
      ),
    );
  }
}