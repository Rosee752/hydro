import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hydro/features/settings/view/reminder_settings_screen.dart';
import 'package:hydro/core/providers/reminder_settings_vm.dart';
import 'package:hydro/core/services/reminder_scheduler.dart';
import 'package:hydro/core/services/local_notification_service.dart';
import 'package:device_calendar/device_calendar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reminder Settings – widget tests', () {
    late ReminderSettingsVM vm;

    setUp(() async {
      // Real in-memory SharedPreferences provided by Flutter SDK
      final prefs = await SharedPreferences.getInstance();

      vm = ReminderSettingsVM(
        calendarPermission: Permission.calendar,
        prefs: prefs,
        scheduler: _StubScheduler(),
      );
    });

    testWidgets('Master toggle disables controls', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: const MaterialApp(home: ReminderSettingsScreen()),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(vm.remindersEnabled, isFalse);
    });

    testWidgets('Slider displays correct interval label', (tester) async {
      vm.useSmart = false;           // force Custom mode

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: const MaterialApp(home: ReminderSettingsScreen()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pumpAndSettle();

      expect(find.textContaining('hour'), findsOneWidget);
    });
  });
}

//─────────────────────────────────────────────────────────
// Stub – no real scheduling, just satisfies type checks
//─────────────────────────────────────────────────────────
class _StubScheduler extends ReminderScheduler {
  _StubScheduler()
      : super(
    calendar: DeviceCalendarPlugin(),           // unused
    notifications: LocalNotificationService(),  // unused
  );

  @override
  Future<void> syncWithSettings(ReminderSettingsVM s) async {}

  @override
  Future<List<DateTime>> nextThreeSmart(ReminderSettingsVM s) async => [];
}
