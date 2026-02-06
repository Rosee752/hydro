import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:hydro/core/providers/reminder_settings_vm.dart';
import 'package:hydro/core/services/reminder_scheduler.dart';

class SmartRemindersPanel extends StatelessWidget {
  const SmartRemindersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderSettingsVM>(
      builder: (_, vm, _) {
        // Only hit the scheduler if calendar-permission is granted.
        final previewFuture = vm.calendarPerm.isGranted
            ? context.read<ReminderScheduler>().nextThreeSmart(vm)
            : Future.value(<DateTime>[]);

        return FutureBuilder<List<DateTime>>(
          future: previewFuture,
          builder: (_, snap) {
            final times = snap.data ?? [];

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                if (vm.calendarPerm.isDenied ||
                    vm.calendarPerm.isPermanentlyDenied)
                  _PermissionBanner(onPressed: vm.requestCalendarPerm),
                const _QuietModeExplainer(),
                const SizedBox(height: 8),
                if (times.isNotEmpty) _PreviewList(times: times),
                // Show progress only while waiting *after* permission granted.
                if (times.isEmpty && vm.calendarPerm.isGranted)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────
// Static helper widgets
// ──────────────────────────────────────────────────────────
class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: ListTile(
        title: const Text('Connect Calendar'),
        subtitle: const Text(
          'Grant access so reminders stay discreet during meetings.',
        ),
        trailing: ElevatedButton(
          onPressed: onPressed,
          child: const Text('Allow'),
        ),
      ),
    );
  }
}

class _QuietModeExplainer extends StatelessWidget {
  const _QuietModeExplainer();

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.vibration),
    title: const Text('Discreet meeting mode'),
    subtitle: const Text(
      'During calendar events, reminders vibrate so you stay discreet.',
    ),
  );
}

class _PreviewList extends StatelessWidget {
  const _PreviewList({required this.times});
  final List<DateTime> times;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: times
          .map(
            (t) => ListTile(
          leading: const Icon(Icons.water_drop_outlined),
          title: Text(TimeOfDay.fromDateTime(t).format(context)),
        ),
      )
          .toList(),
    );
  }
}
