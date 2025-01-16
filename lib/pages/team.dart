import 'package:coordimate/utils/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../models/team.dart';
import '../services/teams_service.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import 'package:intl/intl.dart';

class TeamPage extends StatefulWidget {
  final int teamId;

  const TeamPage({super.key, required this.teamId});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  // Services and controllers
  final _eventService = EventService();
  final _teamsService = TeamsService();
  final _storage = const FlutterSecureStorage();
  final _userIdController = TextEditingController();

  // State variables
  Team? _team;
  bool _isLoading = true;
  int? _currentUserId;
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Cleans up adding user by user ID controller when leaving the page
  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  // Load team details
  Future<void> _loadData() async {
    final logger = Logger();
    try {
      final userIdStr = await _storage.read(key: 'user_id');
      _currentUserId = int.parse(userIdStr ?? '0');

      logger.d('Loading team with ID: ${widget.teamId}'); // Debug log
      final team = await _teamsService.getTeam(widget.teamId);

      // Debug logs for team data
      logger.d('Team found: ${team.name}');
      logger.d('Team owner: ${team.ownerId}');
      logger.d('Number of members: ${team.members.length}');
      logger.d('Members:');
      for (var member in team.members) {
        logger.d('- ID: ${member.id}, Name: ${member.name}');
      }

      final events = await _eventService.getEvents();
      final teamEvents =
          events.where((event) => event.teamId == widget.teamId).toList();

      setState(() {
        _team = team;
        _events = teamEvents;
        _isLoading = false;
      });
    } catch (e) {
      logger.d('Error loading team: $e'); // Debug error log
      setState(() => _isLoading = false);
    }
  }

  // Dialog to remove member as an owner
  Future<void> _removeMember(TeamMember member) async {
    // Manage snackbar messages
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show confirmation dialog
    final confirmed = await CustomDialogs.removeMember(context, member.name);

    // Check if the owner confirmed to remove member and widget still exists
    if (confirmed == true && mounted) {
      try {
        // Call API to remove member
        await _teamsService.removeMember(widget.teamId, member.id);

        // Refresh team data and show successful snackbar message
        _loadData();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Successfully removed ${member.name}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.yellow,
              onPressed: () => scaffoldMessenger.hideCurrentSnackBar(),
            ),
          ),
        );
      } catch (e) {
        // Show error snackbar message
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error removing member: $e'),
            backgroundColor: Colors.red,
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
  }

  // Dialog to add member as an owner
  Future<void> _showAddMemberDialog() async {
    // Manage snackbar messages
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show confirmation dialog
    final confirmed = await CustomDialogs.addMember(context, _userIdController);

    // Check if the owner confirmed to add member and widget still exists
    if (confirmed == true && mounted) {
      // Get user ID from input
      final userId = int.tryParse(_userIdController.text);

      if (userId != null) {
        try {
          // Call API to add member
          await _teamsService.addMember(widget.teamId, userId);

          // Refresh team data and clear input field
          _loadData();
          _userIdController.clear();
        } catch (e) {
          // Show error snackbar message
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error adding member: $e')),
          );
        }
      }
    }
  }

  // Dialog to leave team as a member
  Future<void> _showLeaveConfirmation() async {
    // Manage snackbar messages and navigator
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = context.go;

    // Show confirmation dialog
    final confirmed = await CustomDialogs.leaveTeam(context);

    // Check if the member confirmed to leave team and widget still exists
    if (confirmed == true && mounted) {
      try {
        // Call API to leave team
        await _teamsService.leaveTeam(widget.teamId);

        // Navigate back to my teams list
        navigator('/myteams');
      } catch (e) {
        // Show error snackbar message
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error leaving team: $e')),
        );
      }
    }
  }

  // Dialog to delete a team as an owner
  Future<void> _showDeleteConfirmation() async {
    // Manage snackbar messages and navigator
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = context.go;

    // Show confirmation dialog
    final confirmed = await CustomDialogs.deleteTeam(context);

    // Check if the owner confirmed to deleten his team and widget still exists
    if (confirmed == true && mounted) {
      try {
        // Call API to delete team
        await _teamsService.deleteTeam(widget.teamId);

        // Navigate back to my teams list
        navigator('/myteams');
      } catch (e) {
        // Show error snackbar message
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting team: $e')),
        );
      }
    }
  }

  // Add delete method
  Future<void> _deleteEvent(Event event) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final confirmed = await CustomDialogs.deleteEvent(context);
    
    if (confirmed == true && mounted) {
      try {
        await _eventService.deleteEvent(event.id!);
        _loadData();
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error deleting event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state while fetching data
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Team Members'),
          backgroundColor: Colors.blue[400],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error message if team not found
    if (_team == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Team Members'),
          backgroundColor: Colors.blue[400],
        ),
        body: const Center(child: Text('Team not found')),
      );
    }

    // Check if current user is team owner
    final isOwner = _team!.ownerId == _currentUserId;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/myteams'),
        ),
        title: Text(_team!.name),
        backgroundColor: Colors.blue[400],
        actions: [
          // Show edit and delete buttons only for the owner
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push(
                '/teams/${widget.teamId}/edit',
                extra: _team,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          ]
          // Show leave button only for members
          else if (_team!.members.any((m) => m.id == _currentUserId)) ...[
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.red),
              onPressed: _showLeaveConfirmation,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Members section
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Members',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _team!.members.length,
              itemBuilder: (context, index) {
                final member = _team!.members[index];
                // Check if member id is the same as the current user ID
                final isSelf = member.id == _currentUserId;

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(member.name),
                  subtitle: Text(isSelf
                      ? (isOwner ? 'You (Owner)' : 'You (Member)')
                      : (member.id == _team!.ownerId ? 'Owner' : 'Member')),
                  trailing: isOwner && !isSelf
                      ? IconButton(
                          icon: const Icon(Icons.person_remove,
                              color: Colors.red),
                          onPressed: () => _removeMember(member),
                        )
                      : null,
                );
              },
            ),

            // Events section
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Events',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(event.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.description),
                        const SizedBox(height: 8),
                        Text(
                            'Start: ${DateFormat('yyyy-MM-dd HH:mm').format(event.datetimeStart.toLocal())}'),
                        Text(
                            'End: ${DateFormat('yyyy-MM-dd HH:mm').format(event.datetimeEnd.toLocal())}'),
                      ],
                    ),
                    onTap: () => context.push('/events/${event.id}', extra: event),
                    trailing: isOwner
                        ? SizedBox(
                            width: 80, // Fixed width for buttons
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  key: ValueKey('edit_event_${event.id}'),
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final navigator = context.push;
                                    final eventToEdit =
                                        await _eventService.getEvent(event.id!);
                                    if (mounted) {
                                      final updated = await navigator<bool>(
                                          '/teams/events/${event.id}/edit',
                                          extra: eventToEdit);
                                      if (updated == true) {
                                        _loadData();
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  key: ValueKey('delete_event_${event.id}'),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteEvent(event),
                                ),
                              ],
                            ),
                          )
                        : null,
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: isOwner
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // add event button for team owner
                FloatingActionButton(
                  onPressed: () async {
                    final updated = await context.push<bool>('/teams/${widget.teamId}/events/create');
                    if (updated == true) {
                      _loadData();
                    }
                  },
                  backgroundColor: Colors.blue[400],
                  child: const Icon(Icons.event),
                ),
                const SizedBox(height: 16),

                // Show an "add member" button only for the owner
                FloatingActionButton(
                  onPressed: _showAddMemberDialog,
                  backgroundColor: Colors.blue[400],
                  child: const Icon(Icons.person_add),
                ),
              ],
            )
          : null,
    );
  }
}
