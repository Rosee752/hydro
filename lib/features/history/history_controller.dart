import '../../core/models/water_entry.dart';
import '../../core/services/local_storage.dart';

class HistoryController {
  final LocalStorage _storage = LocalStorage();

  /// Map `yyyy-MM-dd` → list of entries (newest day first).
  Map<String, List<WaterEntry>> getEntriesGroupedByDate() {
    final entries = _storage.getAllEntries();
    final Map<String, List<WaterEntry>> grouped = {};
    for (final entry in entries) {
      final dateKey = dateToKey(entry.timestamp);
      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  static String dateToKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')}';

  List<WaterEntry> getEntriesInRange(DateTime from, DateTime to) =>
      _storage.getEntriesInRange(from, to);

  List<WaterEntry> getEntriesForDate(DateTime date) => _storage.getEntriesForDate(date);
}
