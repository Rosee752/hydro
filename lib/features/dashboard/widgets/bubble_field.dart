import 'dart:math' as math;
import 'package:flutter/material.dart';

final _rand = math.Random();
double _randDouble(double min, double max) => min + _rand.nextDouble() * (max - min);

class BubbleField extends StatefulWidget {
  const BubbleField({super.key});

  @override
  State<BubbleField> createState() => _BubbleFieldState();
}

class _Bubble {
  _Bubble(this.x, this.size, this.speed, this.phase);
  final double x, size, speed, phase;
}

class _BubbleFieldState extends State<BubbleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl =
  AnimationController(vsync: this, duration: const Duration(seconds: 20))
    ..repeat();

  late final List<_Bubble> _bubbles = List.generate(
    25,
        (_) => _Bubble(
      _randDouble(0, 1),
      _randDouble(20, 60),
      _randDouble(0.3, 1),
      _randDouble(0, 1),
    ),
  );

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();                 //  ← must-call-super
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctl,
    builder: (_, _) => CustomPaint(
      size: Size.infinite,
      painter: _BubblePainter(_ctl.value, _bubbles),
    ),
  );
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter(this.t, this.bubbles);
  final double t;
  final List<_Bubble> bubbles;

  @override
  void paint(Canvas c, Size s) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (final b in bubbles) {
      final prog = (t * b.speed + b.phase) % 1;
      final dy   = s.height - (s.height + b.size) * prog;
      c.drawCircle(Offset(b.x * s.width, dy), b.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => true;
}
