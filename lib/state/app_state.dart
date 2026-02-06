import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/models/water_entry.dart';   // ← adjust path if your model lives elsewhere

final _uuid = Uuid();

/// Today’s water entries (non-nullable list).
final waterTodayProvider =
StateNotifierProvider<WaterTodayNotifier, List<WaterEntry>>(
      (_) => WaterTodayNotifier(),
);

class WaterTodayNotifier extends StateNotifier<List<WaterEntry>> {
  WaterTodayNotifier() : super(const []);

  /// Log a new drink.
  void add(int amountMl) => state = [
    ...state,
    WaterEntry(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      amountMl: amountMl,
    ),
  ];

  void delete(String id) =>
      state = state.where((e) => e.id != id).toList(growable: false);

  int get totalMl => state.fold(0, (s, e) => s + e.amountMl);
}
