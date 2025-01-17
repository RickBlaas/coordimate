import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DesktopNavBar extends StatelessWidget {
  const DesktopNavBar({super.key});

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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}