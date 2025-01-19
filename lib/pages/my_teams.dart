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
      // Set loading state and clear previous error
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get user ID from storage
      final userIdStr = await storage.read(key: 'user_id');
      _userId = int.parse(userIdStr ?? '0');
      
      // Get all teams
      final allTeams = await _teamsService.getTeams();
      
      // Filter teams where user is a member
      final myTeams = allTeams.where((team) => 
        team.members.any((member) => member.id == _userId)
      ).toList();
      
      // Update state with user teams and clear loading state
      setState(() {
        _teams = myTeams;
        _isLoading = false;
      });
    } catch (e) {
      // Set error state and clear loading state
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check desktop screen
    final isDesktop = MediaQuery.of(context).size.width > 600;
    // Manage snackbar messages
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: isDesktop ? null : AppBar(
        title: const Text('My Teams', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[400],
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async{
              final shouldRefresh = await context.push<bool>('/teams/create');
              if (shouldRefresh == true) {
                _loadUserTeams();
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: const Text('Successfully create a team'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'Dismiss',
                        textColor: Colors.yellow,
                        onPressed: () => scaffoldMessenger.hideCurrentSnackBar(),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Create Team', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _buildBody(isDesktop),
    );
  }

  Widget _buildBody(bool isDesktop) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Manage snackbar messages
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('My Teams', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () async{
                    final shouldRefresh = await context.push<bool>('/teams/create');
                    if (shouldRefresh == true) {
                      _loadUserTeams();
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: const Text('Successfully create a team'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'Dismiss',
                              textColor: Colors.yellow,
                              onPressed: () => scaffoldMessenger.hideCurrentSnackBar(),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Team'), 
                ),
              ],
            ),
          ),
        
        Expanded(
          child: _error != null
              ? Center(
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
                )
              : _teams.isEmpty
                  ? const Center(child: Text('You have no teams yet'))
                  : RefreshIndicator(
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
                              
                              onTap: () async {
                                final shouldRefresh = await context.push<bool>('/teams/${team.id}');
                                // Refresh teams list if team was updated
                                if (shouldRefresh == true) {
                                  _loadUserTeams();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}