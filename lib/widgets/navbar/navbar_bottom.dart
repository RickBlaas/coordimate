import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: calculateSelectedIndex(context),
      onTap: (index) => onItemTapped(index, context),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Teams',
        ),
      ],
    );
  }

  int calculateSelectedIndex(BuildContext context) {
    // Get current location
    final String location = GoRouterState.of(context).uri.path;

    if (location == '/home') return 0;
    if (location.startsWith('/teams') || location == '/myteams') return 1;
    return 0;
  }

  // Update onItemTapped method
  void onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/myteams');
        break;
    }
  }
}