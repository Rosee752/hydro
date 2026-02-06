// lib/core/models/water_entry.dart
/// One drink the user has logged.
///
/// * `id` is a locally-generated UUID (String).
/// * `timestamp` is always in local time; store **UTC** only if you plan
///   cross-time-zone syncing later.
/// * `amountMl` is an integer number of millilitres.
class WaterEntry {
  final String id;
  final DateTime timestamp;
  final int amountMl;

  const WaterEntry({
    required this.id,
    required this.timestamp,
    required this.amountMl,
  });
}
