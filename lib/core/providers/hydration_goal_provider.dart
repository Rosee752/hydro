import 'package:flutter/widgets.dart';

/// Exposes the user’s daily-goal (mL) to the whole widget tree.
class HydrationGoalProvider extends InheritedWidget {
  final int hydrationGoal;
  final ValueChanged<int> updateGoal;

  const HydrationGoalProvider({
    super.key,
    required this.hydrationGoal,
    required this.updateGoal,
    required super.child,
  });

  static HydrationGoalProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HydrationGoalProvider>();

  @override
  bool updateShouldNotify(HydrationGoalProvider old) =>
      hydrationGoal != old.hydrationGoal;
}
