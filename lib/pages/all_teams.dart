import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/team.dart';
import '../services/teams_service.dart';
// import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AllTeamsPage extends StatefulWidget {
  const AllTeamsPage({super.key});

  @override
  State<AllTeamsPage> createState() => _AllTeamsPageState();
}

class _AllTeamsPageState extends State<AllTeamsPage> {
  final storage = const FlutterSecureStorage();
  final TeamsService _teamsService = TeamsService();
  final logger = Logger();

  List<Team> _teams = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final teams = await _teamsService.getTeams();
      
      setState(() {
        _teams = teams;
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
        title: const Text('Teams', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[400],
        centerTitle: true,
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
              onPressed: _loadTeams,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_teams.isEmpty) {
      return const Center(child: Text('No teams found'));
    }

    return RefreshIndicator(
      
      onRefresh: _loadTeams,
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
            ),
          );
        },
      ),
    );
  }
}

