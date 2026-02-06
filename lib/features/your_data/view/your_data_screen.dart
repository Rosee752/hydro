// lib/features/your_data/view/your_data_screen.dart
//
// Only readability tweaks added: top scrim, darker glass for the info-tip,
// and subtle text-shadows. All logic, widgets and layout stay the same.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../dashboard/widgets/mood_background.dart';
import '../../dashboard/widgets/bubble_field.dart';
import '../../dashboard/widgets/weather_chip.dart';

import 'data_view_model.dart';
import '../activity_level.dart';
import 'widgets/sex_selector.dart';
import 'widgets/number_field.dart';
import 'widgets/hydration_gauge.dart';

// ───────────────────────────────────────────────────── shadow helper
const _textShadow = [
  Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.grey),
];

class YourDataScreen extends StatelessWidget {
  const YourDataScreen({super.key, required this.vm});
  final DataViewModel vm;

  @override
  Widget build(BuildContext context) {
    const progress = 0.0; // no gauge progress for backdrop

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Hydro!',
            style: GoogleFonts.fredoka(
                color: Colors.white, shadows: _textShadow)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const MoodBackground(progress: progress),
          const BubbleField(),
          const WeatherChip(),

          // ── top scrim to lift contrast ─────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x71000000), // 67 % black
                      Color(0x00000000), // transparent
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── main editable form ────────────────────────────────
          Positioned.fill(
            top: kToolbarHeight + MediaQuery.of(context).padding.top,
            child: ValueListenableBuilder(
              valueListenable: vm.notifier,
              builder: (_, state, _) => SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your data',
                      style: GoogleFonts.fredoka(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: _textShadow,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sex selector
                    SexSelector(value: state.sex, onChanged: vm.setSex),
                    const SizedBox(height: 24),

                    // Age
                    NumberField(
                      label: 'Age',
                      initial: state.age,
                      min: 13,
                      max: 100,
                      onSaved: vm.setAge,
                    ),
                    const SizedBox(height: 24),

                    // Weight
                    NumberField(
                      label: 'Weight (kg)',
                      initial: state.weightKg?.round() ?? 0,
                      min: 20,
                      max: 200,
                      onSaved: (v) => vm.setWeight(v.toDouble()),
                    ),
                    const SizedBox(height: 24),

                    // Location row
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.white70),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.locationName ??
                                'Enable to auto-detect city & temp',
                            style: GoogleFonts.fredoka(
                                fontSize: 14,
                                color: Colors.white,
                                shadows: _textShadow),
                          ),
                        ),
                        Switch(
                          value: state.locationName != null,
                          onChanged: vm.toggleAutoLocation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Activity slider
                    Text(
                      'Activity level',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: _textShadow,
                      ),
                    ),
                    Slider(
                      value: state.activity.index.toDouble(),
                      max: 3,
                      divisions: 3,
                      label: state.activity.label,
                      onChanged: (v) =>
                          vm.setSlider(ActivityLevel.values[v.round()]),
                    ),
                    const SizedBox(height: 36),

                    // Animated gauge
                    Center(child: HydrationGauge(litres: state.litresPerDay)),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),

          // info card
          const _InfoTip(),
        ],
      ),
    );
  }
}

/// Shrinked ℹ️ card so it never hides the gauge.
class _InfoTip extends StatelessWidget {
  const _InfoTip();

  @override
  Widget build(BuildContext context) => Positioned(
    left: 16,
    bottom: 32,
    child: GestureDetector(
      onTap: () => _showTip(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 110,
            height: 110,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.85), // slightly darker
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/info.svg', height: 28),
                const SizedBox(height: 6),
                const Text(
                  'Staying hydrated boosts energy, mood & cognition.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10.5,
                      height: 1.25,
                      shadows: _textShadow),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  static void _showTip(BuildContext context) => showModalBottomSheet(
    context: context,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Why hydration matters',
              style: GoogleFonts.fredoka(
                  fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          const Text(
            'Adequate water supports energy, cognition and mood. '
                'Even mild dehydration can impair focus and increase fatigue.',
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: () => launchUrl(Uri.parse(
                'https://www.ncoa.org/article/10-reasons-why-hydration-is-important/')),
            child: const Text('Read NIH article'),
          ),
        ],
      ),
    ),
  );
}
