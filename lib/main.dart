import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:coordimate/pages/teams/create_team.dart';
import 'package:coordimate/pages/teams/edit_team.dart';
import 'package:coordimate/pages/home.dart';
// Add this line to import EventDetailsPage

// import 'package:coordimate/pages/teams.dart';
// import 'package:coordimate/pages/all_teams.dart';
import 'package:coordimate/pages/teams/my_teams.dart';
import 'package:coordimate/pages/events/create_event.dart';
import 'package:coordimate/widgets/navbar/desktop_nav.dart';
import 'package:coordimate/widgets/navbar/navbar_bottom.dart';
import 'package:coordimate/pages/events/edit_event.dart';
import 'package:coordimate/pages/events/event_details.dart';

import 'pages/login.dart';
import 'pages/teams/team.dart';
import 'models/team.dart';
import 'models/event.dart'; 

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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {  // Desktop layout
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: DesktopNavBar(),
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200), // Like Tailwind's container
                child: child,
              ),
            ),
          );
        } else {  // Mobile layout
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavBar(),
          );
        }
      },
    );
  }
}

// Update router
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/myteams',
            builder: (context, state) => const MyTeamsPage(),
          ),
          // Keep other routes outside shell route
          GoRoute(
            path: '/teams/create',
            builder: (context, state) => const CreateTeamPage(),
          ),
          GoRoute(
            path: '/teams/:id',
            builder: (context, state) {
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
          GoRoute(
            path: '/teams/:teamId/events/create',
            builder: (context, state) {
              final teamId = int.parse(state.pathParameters['teamId']!);
              return CreateEventPage(teamId: teamId);
            },
          ),
          // Add new route
          GoRoute(
            path: '/events/:id',
            builder: (context, state) {
              final event = state.extra as Event;
              return EventDetailsPage(event: event);
            },
          ),
          GoRoute(
            path: '/teams/events/:id/edit',
            builder: (context, state) {
              final event = state.extra as Event;
              return EditEventPage(event: event);
            },
          ),
        ]),
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
