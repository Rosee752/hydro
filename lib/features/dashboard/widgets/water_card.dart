import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../widgets/add_water_sheet.dart';

/// Card that shows daily-water progress with a wave animation.
class WaterCard extends StatelessWidget {
  const WaterCard({
    super.key,
    required this.percent,
    required this.consumed,
    required this.waveCtl,
    required this.goldHue,
  });

  final double percent;               // 0.0 – 1.0
  final double consumed;              // ml consumed so far
  final AnimationController waveCtl;  // drives the waving effect
  final Color goldHue;                // accent colour when goal reached

  @override
  Widget build(BuildContext context) {
    final goalReached = percent >= 1;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: 230,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tank(context, goalReached),
              const SizedBox(height: 14),
              _goalBar(goalReached),
              const SizedBox(height: 6),
              Text(
                '${consumed.round()} / 2500 ml',
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── circular meter with wave fill ───────────────────────────────
  Widget _tank(BuildContext context, bool goal) => SizedBox(
    width: 180,
    height: 180,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircularPercentIndicator(
          radius: 80,
          lineWidth: 10,
          percent: percent.clamp(0.0, 1.0),
          progressColor: goal ? goldHue : const Color(0xFF00BCD4),
          backgroundColor: Colors.white24,
          circularStrokeCap: CircularStrokeCap.round,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ClipOval(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: percent.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 600),
              builder: (_, value, _) => AnimatedBuilder(
                animation: waveCtl,
                builder: (_, _) => ClipPath(
                  clipper: _WaveClipper(
                    value,
                    waveCtl.value * 2 * math.pi,
                    amp: 8.0, // amplitude of the wave
                  ),
                  child: Container(
                    color: goal ? goldHue : const Color(0xFF00BCD4),
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          color: Colors.white,
          iconSize: 32,
          onPressed: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddWaterSheet(),
          ),
        ),
      ],
    ),
  );

  // ── horizontal goal bar under the circle ────────────────────────
  Widget _goalBar(bool goal) => Stack(
    children: [
      Container(
        width: 170,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 170 * percent.clamp(0.0, 1.0),
        height: 16,
        decoration: BoxDecoration(
          color: goal ? goldHue : const Color(0xFFB2EBF2),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ],
  );
}

// ──────────────────────────────────────────────────────────────────
// Custom clipper that creates a sine-wave fill inside the circle.
//
class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper(
      this.progress,
      this.phase, {
        this.amp = 8.0, // default amplitude; tweak to make wave taller/shorter
      });

  final double progress; // 0.0 – 1.0
  final double phase;    // wave phase in radians
  final double amp;      // wave amplitude in px

  @override
  Path getClip(Size size) {
    final baseY = size.height * (1 - progress);
    final path  = Path()..moveTo(0, baseY);

    for (double x = 0; x <= size.width; x++) {
      final y = baseY +
          math.sin((x / size.width) * 2 * math.pi + phase) * amp;
      path.lineTo(x, y);
    }

    return path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_WaveClipper old) =>
      old.progress != progress ||
          old.phase != phase ||
          old.amp != amp;
}
