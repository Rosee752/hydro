import '../../core/models/water_entry.dart';

/// Demo in-memory storage.
///
/// • Holds the hydration `WaterEntry` list.
/// • Exposes ultra-light key-value helpers so other features (e.g. auth
///   “remember me”) can cache data.
///   _Everything is lost when the app restarts._
class LocalStorage {
  LocalStorage._internal();
  static final LocalStorage _singleton = LocalStorage._internal();
  factory LocalStorage() => _singleton;

  // ─────────────────────────────────── hydration log
  final List<WaterEntry> _entries = [];

  void addEntry(WaterEntry entry) => _entries.add(entry);

  List<WaterEntry> getAllEntries() => List.unmodifiable(_entries);

  List<WaterEntry> getEntriesForDate(DateTime date) => _entries
      .where((e) =>
  e.timestamp.year == date.year &&
      e.timestamp.month == date.month &&
      e.timestamp.day == date.day)
      .toList();

  List<WaterEntry> getEntriesInRange(DateTime from, DateTime to) => _entries
      .where((e) => !e.timestamp.isBefore(from) && !e.timestamp.isAfter(to))
      .toList();

  // ─────────────────────────────────── tiny KV section
  final Map<String, dynamic> _kv = {};

  bool?   getBool   (String key)            => _kv[key] as bool?;
  String? getString (String key)            => _kv[key] as String?;

  /// Synchronous setters wrapped in a Future so callers may `await`.
  Future<void> setBool   (String key, bool   value) async => _kv[key] = value;
  Future<void> setString (String key, String value) async => _kv[key] = value;
  Future<void> remove    (String key)             async => _kv.remove(key);
}
