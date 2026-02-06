import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/view/login_screen.dart';
import '../features/auth/view/register_screen.dart';
import '../features/dashboard/view/calm_dashboard.dart';
import '../features/history/view/history_screen.dart';
import '../features/trophies/view/trophies_screen.dart';
import '../features/trophies/trophies_view_model.dart';
import '../features/connect/view/connect_screen.dart';
import '../features/settings/view/reminder_settings_screen.dart';
import '../features/your_data/view/your_data_screen.dart';
import '../features/your_data/view/data_view_model.dart';
import '../core/helpers/permission_helper.dart';
import '../core/services/location_service.dart';
import '../core/services/health_repository.dart';

/// Global GoRouter instance.
/// All sub-routes live under /dashboard so deep-links work.
final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, _) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (_, _) => const CalmDashboard(),
      routes: [
        GoRoute(
          path: 'history',
          builder: (_, _) => const HistoryScreen(),
        ),
        GoRoute(
          path: 'your-data',
          name: 'your-data',
          builder: (_, _) => YourDataScreen(
            vm: DataViewModel(
              permissionHelper: PermissionHelper(),
              locationService: LocationService(),
              healthRepository: HealthRepository(),
            ),
          ),
        ),
        GoRoute(
          path: 'trophies',
          builder: (_, _) => TrophiesScreen(vm: TrophiesViewModel()),
        ),
        GoRoute(
          path: 'connect',
          builder: (_, _) => const ConnectScreen(),
        ),
        GoRoute(
          path: 'reminders',
          builder: (_, _) => const ReminderSettingsScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (_, _) => const Scaffold(
    body: Center(child: Text('404 – page not found')),
  ),
);
