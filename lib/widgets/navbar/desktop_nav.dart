import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class DesktopNavBar extends StatelessWidget {
  DesktopNavBar({super.key});

  final _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[400],
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Coordimate', style: TextStyle(color: Colors.white)),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.home, color: Colors.white),
                      label: const Text('Home', style: TextStyle(color: Colors.white)),
                      onPressed: () => context.go('/home'),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.group, color: Colors.white),
                      label: const Text('Teams', style: TextStyle(color: Colors.white)),
                      onPressed: () => context.go('/myteams'),
                    ),
                     TextButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text('Logout', style: TextStyle(color: Colors.white)),
                      onPressed: () => _handleLogout(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await _authService.logout();
                if (context.mounted) {
                  context.go('/');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
