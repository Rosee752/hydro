// lib/features/trophies/view/trophies_screen.dart
//
// Only contrast-related tweaks applied: top scrim, darker glass, text-shadows.
// Business logic, widget structure and providers remain untouched.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp; // Riverpod
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as pv; // classic Provider

import '../../../state/app_state.dart';
import '../../dashboard/widgets/bubble_field.dart';
import '../../dashboard/widgets/mood_background.dart';
import '../../dashboard/widgets/weather_chip.dart';
import '../trophies_view_model.dart';
import 'widgets/glass_challenge_card.dart';
import 'widgets/tip_card.dart';

// ───────────────────────────────────────────────────── misc
const _textShadow = [
  Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black45),
];

/// Challenge / Trophies dashboard screen.
class TrophiesScreen extends StatelessWidget {
  const TrophiesScreen({super.key, required this.vm});
  final TrophiesViewModel vm;

  @override
  Widget build(BuildContext context) => pv.ChangeNotifierProvider.value(
    value: vm,
    child: rp.Consumer(
      builder: (ctx, ref, _) {
        // ── hydration progress (0‥1+) ───────────────────────
        final entries = ref.watch(waterTodayProvider);
        final consumed =
        entries.fold<double>(0, (s, e) => s + e.amountMl);
        const goalMl = 2500.0;
        final progress = (consumed / goalMl).clamp(0.0, 1.0);

        final textColor =
        progress >= 1 ? Colors.black87 : Colors.black;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Stack(
            children: [
              MoodBackground(progress: progress),
              const BubbleField(),
              const Positioned(top: 8, right: 12, child: WeatherChip()),

              // ── top scrim for readability ─────────────────
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x5C000000), // 67 % black
                          Color(0x00000000), // transparent
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── scrollable content ────────────────────────
              Positioned.fill(
                top: kToolbarHeight +
                    MediaQuery.of(context).padding.top,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Quests',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                            color: textColor,
                            shadows: _textShadow),
                      ),
                      const SizedBox(height: 16),

                      // ── challenge cards ───────────────────
                      pv.Consumer<TrophiesViewModel>(
                        builder: (_, vm, _) => Column(
                          children: [
                            GlassChallengeCard(
                              key: const Key('challenge_card_0'),
                              index: 0,
                              title: 'Escape Caffeine!!',
                              accent: const Color(0xFF5D3A00),
                              icon: Icons.coffee_rounded,
                              bullets: const [
                                'Improves sleep quality and duration',
                                'Lowers blood pressure & resting heart rate',
                                'Reduces anxiety & jitters',
                                'Gentle detox for adrenal system',
                              ],
                              healthScore: 4,
                              expanded: vm.openCardIndex == 0,
                              onToggle: () => vm.toggleCard(0),
                            ),
                            const SizedBox(height: 12),
                            GlassChallengeCard(
                              key: const Key('challenge_card_1'),
                              index: 1,
                              title: 'Drink Tea!!',
                              accent: const Color(0xFF208E45),
                              icon: Icons.emoji_nature,
                              bullets: const [
                                'Rich in antioxidants that fight inflammation',
                                'Provides calm, sustained focus (L-theanine)',
                                'Supports cardiovascular health',
                                'Naturally hydrating with minimal calories',
                              ],
                              healthScore: 5,
                              expanded: vm.openCardIndex == 1,
                              onToggle: () => vm.toggleCard(1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── progress & tips header row ────────
                      pv.Consumer<TrophiesViewModel>(
                        builder: (_, vm, _) => Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 56,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: textColor.withOpacity(.6)),
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white.withOpacity(
                                    .28), // subtle glass
                              ),
                              child: Text('${vm.completedTipsToday} / 3',
                                  style: GoogleFonts.fredoka(
                                      color: textColor,
                                      shadows: _textShadow)),
                            ),
                            Row(
                              children: [
                                Text('Today’s tips',
                                    style: GoogleFonts.fredoka(
                                        color: textColor,
                                        fontSize: 18,
                                        shadows: _textShadow)),
                                const SizedBox(width: 6),
                                Icon(Icons.local_florist,
                                    color:
                                    textColor.withOpacity(.7)),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: vm.onSeeAll,
                                  child: const Text('See all'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── tips grid ─────────────────────────
                      GridView.count(
                        physics:
                        const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        shrinkWrap: true,
                        childAspectRatio: 1.6,
                        children: const [
                          TipCard(
                              icon: Icons.flag,
                              label: '3 days\nFirst step'),
                          TipCard(
                              icon: Icons.spa,
                              label: '7 days\nGoal start'),
                          TipCard(
                              icon: Icons.grass,
                              label: '14 days\nMaintenance'),
                          TipCard(
                              icon: Icons.park,
                              label: '30 days\nGoal grow'),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
