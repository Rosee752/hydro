import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../state/app_state.dart';            // waterTodayProvider
import '../../../shared/widgets/glass_card.dart';  // your frosted card
import '../../../core/models/water_entry.dart';
import '../../../core/services/local_storage.dart';

/// Bottom-sheet that lets the user log a quick drink.
class AddWaterSheet extends ConsumerWidget {
  const AddWaterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Four common amounts – tweak to taste.
    const amounts = [200, 300, 500, 750];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.only(top: 24, bottom: 40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.20),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // grab-handle
            const SizedBox(height: 4),
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // amount chips
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: amounts
                  .map(
                    (ml) => GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: InkWell(
                    splashFactory: InkRipple.splashFactory,
                    onTap: () {
                      _addDrink(ref, ml);        // ← save & refresh
                      Navigator.pop(context);    // close sheet
                    },
                    child: Text(
                      '+$ml ml',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── persist + invalidate ────────────────────────────────────────────
  void _addDrink(WidgetRef ref, int ml) {
    // 1 ─ persist to the singleton LocalStorage
    final entry = WaterEntry(
      id: const Uuid().v4(),
      amountMl: ml,
      timestamp: DateTime.now().toLocal(),
    );
    LocalStorage().addEntry(entry);

    // 2 ─ refresh UI everywhere (dashboard, history, badges…)
    ref.read(waterTodayProvider.notifier).add(ml);
  }
}
