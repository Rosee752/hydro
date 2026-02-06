// lib/features/settings/view/widgets/weekday_selector.dart
//
// Same public API as before, but the chips now look more polished:
// • un-selected: transparent fill, subtle 1 px outline
// • selected   : primary-filled, soft shadow for depth
// • size, labels, animation-duration, haptic feedback → unchanged

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Horizontal row of circular chips (Mon → Sun) that lets the user
/// select any combination of weekdays.
///
/// * [selected] ‒ the currently-active weekday numbers
///   (1 = Mon … 7 = Sun)
/// * [onToggle] ‒ called with the tapped weekday number so the
///   ViewModel can update its Set<int>.
class WeekdaySelector extends StatelessWidget {
  const WeekdaySelector({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<int> selected;
  final ValueChanged<int> onToggle;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final outline = theme.dividerColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = i + 1;             // 1 = Mon
        final isActive = selected.contains(day);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle(day);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive
                  ? primary
                  : theme.colorScheme.surface,      // transparent-ish
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? primary : outline,
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: primary.withOpacity(.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
                  : const [],
            ),
            child: Text(
              _labels[i],
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive
                    ? theme.colorScheme.onPrimary
                    : theme.hintColor,
              ),
            ),
          ),
        );
      }),
    );
  }
}
