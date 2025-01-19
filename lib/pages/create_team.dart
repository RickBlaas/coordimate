import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/teams_service.dart';
import '../models/team.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  // Form key to manage form state and validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for form input fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Loading state for API calls
  bool _isLoading = false;

  Future<void> _submitForm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Manage snackbar messages and navigator
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = context.pop;
    
    setState(() => _isLoading = true);
    
    if (mounted) {
      try {
        // Create a new team object with the filled in values
        final team = Team(
          name: _nameController.text,
          description: _descriptionController.text,
        );
        // Call API to create a team
        await TeamsService().createTeam(team);
        
        // Navigate back to my teams page
        navigator(true); 
      } catch (e) {
        // Show error snackbar message
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error creating team: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
    
  }

  // Cleans up when leaving the page
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    // Check desktop screen fo the appbar
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      // Show app bar only on mobile
      appBar: isDesktop ? null : AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Team', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[400],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button on desktop
              if (isDesktop)
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.blue),
                        label: Text('Back', style: TextStyle(color: Colors.blue[400])),
                      ),
                    ],
                  ),
                ),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Team Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a team name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Team'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}