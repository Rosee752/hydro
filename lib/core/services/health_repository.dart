import 'package:health/health.dart';

/// Small helper around the `health` plugin that returns the user’s
/// active-energy expenditure (kcal) from midnight to now.
///
/// Returns `null` if permission is denied or the platform source
/// (Google Fit / Apple Health / Health Connect) is unavailable.
class HealthRepository {
  // For health 4.x the constructor takes no arguments
  final HealthFactory _health = HealthFactory();

  /// Sum of ‘active energy burned’ since today’s midnight, in kcal.
  Future<double?> caloriesToday() async {
    final now      = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    const types = [HealthDataType.ACTIVE_ENERGY_BURNED];

    // Show the native permission dialog once
    final authorised = await _health.requestAuthorization(types);
    if (!authorised) return null;

    // Fetch data points
    final points = await _health.getHealthDataFromTypes(
      midnight,
      now,
      types,
    );

    // Sum up kcal values (each value is num in 4.x API)
    return points.fold<double>(
      0,
          (sum, p) => sum + (p.value as num).toDouble(),
    );
  }
}
