// lib/features/settings/view/reminder_settings_screen.dart
//
// Changes since last version:
// 1. Removed lowerBound/upperBound from _emojiScale.
// 2. Wrapped CurvedAnimation in a Tween so scale still bounces 0.8‥1.2.
// No other edits.

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:hydro/core/providers/reminder_settings_vm.dart';
import 'package:hydro/features/dashboard/widgets/mood_background.dart';
import 'package:hydro/features/settings/view/widgets/smart_reminders_panel.dart';
import 'package:hydro/features/settings/view/widgets/custom_reminders_panel.dart';
import 'package:hydro/features/settings/view/widgets/info_tip_bubble.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen>
    with SingleTickerProviderStateMixin {
  // ── FIX: let controller stay in 0–1 range; tween will map 0.8–1.2
  late final AnimationController _emojiScale = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void dispose() {
    _emojiScale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const progress = 0.4; // TODO wire to your own mood-provider.

    return Stack(
      children: [
        const Positioned.fill(child: MoodBackground(progress: progress)),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Consumer<ReminderSettingsVM>(
                builder: (_, vm, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderRow(
                        enabled: vm.remindersEnabled,
                        onToggle: (v) async {
                          await vm.toggleMaster(v);
                          _emojiScale
                            ..reset()
                            ..forward();
                        },
                        scaleCtrl: _emojiScale,
                      ),
                      const SizedBox(height: 16),
                      _ModeTabs(useSmart: vm.useSmart, onChanged: vm.switchMode),
                      const SizedBox(height: 12),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: vm.useSmart
                              ? const SmartRemindersPanel(key: ValueKey('smart'))
                              : const CustomRemindersPanel(
                              key: ValueKey('custom')),
                        ),
                      ),
                      const InfoTipBubble(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//─────────────────────────────────────────────────────────
// PRIVATE sub-widgets
//─────────────────────────────────────────────────────────
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.enabled,
    required this.onToggle,
    required this.scaleCtrl,
  });

  final bool enabled;
  final ValueChanged<bool> onToggle;
  final AnimationController scaleCtrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          color: theme.colorScheme.onSurface,
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 4),
        Text('Hydration Reminders', style: theme.textTheme.headlineSmall),
        const Spacer(),
        // ── FIX: map 0→0.8, 1→1.2 with Tween
        ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.2).animate(
            CurvedAnimation(parent: scaleCtrl, curve: Curves.elasticOut),
          ),
          child: const Text('💧', style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 4),
        Switch.adaptive(value: enabled, onChanged: onToggle),
      ],
    );
  }
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.useSmart, required this.onChanged});

  final bool useSmart;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSegmentedControl<bool>(
      children: const {
        true: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text('Smart Reminders'),
        ),
        false: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text('Custom Reminders'),
        ),
      },
      groupValue: useSmart,
      onValueChanged: onChanged,
    );
  }
}
