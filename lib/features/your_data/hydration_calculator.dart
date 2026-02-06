import 'dart:math' as math;
import 'activity_level.dart';

/// Evidence-based calculator (NAM / NIH guidance).
class HydrationCalculator {
  /// Returns required litres per day, rounded to 1 decimal.
  double litresPerDay({
    required String sex,
    double? weightKg,
    required double ambientTempC,
    double? caloriesBurned,
    required ActivityLevel activity,
  }) {
    // 1 ─ Base need
    double base = weightKg != null
        ? weightKg * 0.035
        : switch (sex.toLowerCase()) {
      'male'   => 3.7,
      'female' => 2.7,
      _        => 3.2,
    };

    // 2 ─ Heat adjustment (120 mL / °C above 22 °C)
    final heatBonus = math.max(0, ambientTempC - 22) * 0.12;

    // 3 ─ Activity adjustment
    final activityBonus = caloriesBurned != null
        ? caloriesBurned / 600                              // 1 L / 600 kcal
        : switch (activity) {
      ActivityLevel.sedentary => 0,
      ActivityLevel.light     => 0.4,
      ActivityLevel.moderate  => 0.8,
      ActivityLevel.heavy     => 1.2,
    };

    // 4 ─ Clamp 2–7 L & round
    final total = (base + heatBonus + activityBonus).clamp(2.0, 7.0);
    return (total * 10).roundToDouble() / 10;
  }
}
