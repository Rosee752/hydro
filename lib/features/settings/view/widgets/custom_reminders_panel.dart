import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:hydro/core/providers/reminder_settings_vm.dart';
import 'package:hydro/features/settings/view/widgets/weekday_selector.dart';

class CustomRemindersPanel extends StatefulWidget {
  const CustomRemindersPanel({super.key});

  @override
  State<CustomRemindersPanel> createState() => _CustomRemindersPanelState();
}

class _CustomRemindersPanelState extends State<CustomRemindersPanel> {
  late double _sliderMinutes;

  @override
  void initState() {
    super.initState();
    final vm = context.read<ReminderSettingsVM>();
    _sliderMinutes = vm.interval.inMinutes.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReminderSettingsVM>();
    final theme = Theme.of(context);

    String intervalLabel() {
      final d = Duration(minutes: _sliderMinutes.round());
      final h = d.inHours;
      final m = d.inMinutes % 60;
      final hStr = h > 0 ? '$h hour${h == 1 ? '' : 's'} ' : '';
      final mStr = m > 0 ? '$m min' : '';
      return (hStr + mStr).trim();
    }

    return ListView(
      key: const PageStorageKey('customPanel'),
      padding: EdgeInsets.zero,
      children: [
        // Interval
        Text('Notification interval', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Center(
          child: Text(intervalLabel(), style: theme.textTheme.bodyLarge),
        ),
        Slider(
          value: _sliderMinutes,
          min: 30,
          max: 180,
          divisions: 10,
          label: intervalLabel(),
          onChanged: (v) {
            setState(() => _sliderMinutes = v);
          },
          onChangeEnd: (v) async {
            // Thumb pulse animation
            HapticFeedback.lightImpact();
            await vm.setInterval(Duration(minutes: v.round()));
          },
        ),
        const SizedBox(height: 16),
        // Quiet hours
        Text('Quiet hours', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _TimeRow(
          label: 'From',
          time: vm.quietFrom,
          onPressed: () => _pickTime(context, true),
        ),
        _TimeRow(
          label: 'Until',
          time: vm.quietUntil,
          onPressed: () => _pickTime(context, false),
        ),
        const SizedBox(height: 16),
        // Weekdays
        Text('Days of the week', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        WeekdaySelector(
          selected: vm.activeWeekdays,
          onToggle: vm.toggleWeekday,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _pickTime(BuildContext ctx, bool isFrom) async {
    final vm = ctx.read<ReminderSettingsVM>();
    final initial = isFrom ? vm.quietFrom : vm.quietUntil;
    final picked = await showTimePicker(context: ctx, initialTime: initial);
    if (picked != null) {
      if (isFrom) {
        vm.setQuietHours(picked, vm.quietUntil);
      } else {
        vm.setQuietHours(vm.quietFrom, picked);
      }
    }
  }
}

//───────────────────────────────────────────────────────────────────
// Sub-helpers
//───────────────────────────────────────────────────────────────────
class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.time,
    required this.onPressed,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final _ = Theme.of(context);
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: ElevatedButton(
        onPressed: onPressed,
        child: Text(time.format(context)),
      ),
    );
  }
}
