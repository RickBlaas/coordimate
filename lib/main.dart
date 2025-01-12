import 'package:coordimate/pages/create_team.dart';
import 'package:coordimate/pages/edit_team.dart';
import 'package:coordimate/pages/home.dart';
// import 'package:coordimate/pages/teams.dart';
// import 'package:coordimate/pages/all_teams.dart';
import 'package:coordimate/pages/my_teams.dart';
import 'package:coordimate/widgets/navbar/navbar_bottom.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/login.dart';  
import 'pages/team.dart';
import 'models/team.dart';

void main() {
  runApp(const MyApp());
}

// Scaffold wrapper navbar bottom widget
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

// Update router
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: ( context, state) => const LoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: ( context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/myteams',
          builder: ( context, state) => const MyTeamsPage(),
        ),
      ],
    ),
    // Keep other routes outside shell route
    GoRoute(
      path: '/teams/create',
      builder: ( context, state) => const CreateTeamPage(),
    ),
    GoRoute(
      path: '/teams/:id',
      builder: ( context, state) {
        final teamId = int.parse(state.pathParameters['id']!);
        return TeamPage(teamId: teamId);
      },
    ),
    GoRoute(
      path: '/teams/:id/edit',
      builder: (context, state) {
        final team = state.extra as Team;
        return EditTeamPage(team: team);
      },
    ),
  ],
);

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
