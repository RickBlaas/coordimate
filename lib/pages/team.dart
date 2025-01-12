import 'package:coordimate/utils/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../models/team.dart';
import '../services/teams_service.dart';

class TeamPage extends StatefulWidget {
  final int teamId;
  
  const TeamPage({super.key, required this.teamId});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  // Services and controllers
  final _teamsService = TeamsService();
  final _storage = const FlutterSecureStorage();
  final _userIdController = TextEditingController();

  // State variables
  Team? _team;
  bool _isLoading = true;
  int? _currentUserId;
  
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
    try {
      // Get current user ID and put it in _currentUserId
      final userIdStr = await _storage.read(key: 'user_id');
      _currentUserId = int.parse(userIdStr ?? '0');

      // Fetch team details from TeamsService API
      final team = await _teamsService.getTeam(widget.teamId);
      
      setState(() {
        _team = team;
        _isLoading = false;
      });
    } catch (e) {
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
      // List of team members
      body: ListView.builder(
        itemCount: _team!.members.length,
        itemBuilder: (context, index) {

          final member = _team!.members[index];
          // Check if member id is the same as the current user ID
          final isSelf = member.id == _currentUserId;
  
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(member.name),
            subtitle: Text(
              isSelf 
                ? (isOwner ? 'You (Owner)' : 'You (Member)')
                : (member.id == _team!.ownerId ? 'Owner' : 'Member')
            ),
            trailing: isOwner && !isSelf
                ? IconButton(
                    icon: const Icon(Icons.person_remove, color: Colors.red),
                    onPressed: () => _removeMember(member),
                  )
                : null,
          );
        },
      ),
      // Show an "add member" button only for the owner
      floatingActionButton: isOwner 
          ? FloatingActionButton(
              onPressed: _showAddMemberDialog,
              child: const Icon(Icons.person_add),
            ) 
          : null,
    );
  }
}