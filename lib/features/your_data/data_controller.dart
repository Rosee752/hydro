import '../../core/services/local_storage.dart';
import '../../core/models/water_entry.dart';   // fixed relative path

class DataController {
  final LocalStorage _storage = LocalStorage();

  /// Total intake per day for the last 7 days (oldest → newest).
  List<int> getLast7DaysIntake() {
    final now = DateTime.now();
    return [
      for (int i = 6; i >= 0; i--)
        _storage
            .getEntriesForDate(now.subtract(Duration(days: i)))
            .fold<int>(0, (sum, e) => sum + e.amountMl)
    ];
  }

  /// Week-day labels for the last 7 days (oldest → newest).
  List<String> getLast7DaysLabels() {
    final now = DateTime.now();
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return [
      for (int i = 6; i >= 0; i--)
        labels[(now.subtract(Duration(days: i)).weekday - 1) % 7],
    ];
  }

  /// Sum of **today’s** intake.
  int getTodayTotalIntake() =>
      _storage.getEntriesForDate(DateTime.now())
          .fold<int>(0, (sum, e) => sum + e.amountMl);

  /// Sum of **all** entries.
  int getTotalIntake() =>
      _storage.getAllEntries().fold<int>(0, (sum, e) => sum + e.amountMl);

  /// Add a new entry.
  void addEntry(WaterEntry entry) => _storage.addEntry(entry);
}
