// lib/features/your_data/view/widgets/hydration_gauge.dart
//
//   • Only visual tweak: darker track colour (ring background)
//   • Public API and layout are untouched so the widget remains a
//     drop-in for YourDataScreen and anywhere else it’s used.

import 'dart:math' as math;
import 'package:flutter/material.dart';

class HydrationGauge extends StatelessWidget {
  const HydrationGauge({super.key, required this.litres});

  final double litres;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size.square(160),
    painter: _GaugePainter(litres: litres),
  );
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.litres});

  final double litres;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // TRACK (background ring) ───────────────
    final trackPaint = Paint()
      ..color = Colors.white38        // was white24 → darker ≈ 60 % more opaque
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 14 / 2, trackPaint);

    // PROGRESS ARC ──────────────────────────
    final progress = (litres / 5).clamp(0.0, 1.0); // hard-cap at 5 L
    final sweep = 2 * math.pi * progress;

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6DD5FA), Color(0xFF2196F3)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 14 / 2),
      -math.pi / 2,
      sweep,
      false,
      progressPaint,
    );

    // CENTRE TEXT ───────────────────────────
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${litres.toStringAsFixed(1)} L',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black45)
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.litres != litres;
}
