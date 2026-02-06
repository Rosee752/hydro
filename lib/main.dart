// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p; // classic Provider alias
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_calendar/device_calendar.dart';

import 'routes/app_router.dart';
import 'core/providers/hydration_goal_provider.dart';
import 'core/providers/reminder_settings_vm.dart';
import 'core/services/reminder_scheduler.dart';
import 'core/services/local_notification_service.dart';
import 'features/auth/widgets/auth_controller.dart'; // ← NEW import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── create singletons used across the app ─────────────────────────
  final prefs         = await SharedPreferences.getInstance();
  final calendar      = DeviceCalendarPlugin();
  final notifications = LocalNotificationService();
  final scheduler     = ReminderScheduler(
    calendar: calendar,
    notifications: notifications,
  );

  runApp(
    _HydrationGoalRoot(
      prefs: prefs,
      scheduler: scheduler,
    ),
  );
}

/// Root widget:
///  • keeps the user’s hydration goal,
///  • exposes global providers (ReminderScheduler + ReminderSettingsVM + AuthController),
///  • embeds Riverpod’s ProviderScope.
class _HydrationGoalRoot extends StatefulWidget {
  const _HydrationGoalRoot({
    required this.prefs,
    required this.scheduler,
  });

  final SharedPreferences prefs;
  final ReminderScheduler scheduler;

  @override
  State<_HydrationGoalRoot> createState() => _HydrationGoalRootState();
}

class _HydrationGoalRootState extends State<_HydrationGoalRoot> {
  int _goal = 2000; // ml default

  void _setGoal(int g) => setState(() => _goal = g);

  @override
  Widget build(BuildContext context) {
    return HydrationGoalProvider(
      hydrationGoal: _goal,
      updateGoal: _setGoal,
      child: p.MultiProvider(
        providers: [
          // ── global scheduler
          p.Provider<ReminderScheduler>.value(value: widget.scheduler),

          // ── main reminder-settings ViewModel
          p.ChangeNotifierProvider(
            create: (_) => ReminderSettingsVM(
              calendarPermission: Permission.calendar,
              prefs: widget.prefs,
              scheduler: widget.scheduler,
            ),
          ),

          // ── **NEW** auth singleton so Login / Register can read/watch it
          p.ChangeNotifierProvider<AuthController>(
            create: (_) => AuthController(),
          ),
        ],

        // Riverpod ↴
        child: const ProviderScope(
          child: MyApp(),
        ),
      ),
    );
  }
}

/// Standard MaterialApp.router using GoRouter for navigation.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hydro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: router, // from routes/app_router.dart
    );
  }
}
