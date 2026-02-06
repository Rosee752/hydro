import 'package:flutter/material.dart';

class MoodBackground extends StatelessWidget {
  const MoodBackground({super.key, required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final c1 = Color.lerp(const Color(0xFFE0F7FA), const Color(0xFFB2FFF4), progress)!;
    final c2 = Color.lerp(const Color(0xFF00BCD4), const Color(0xFF00C795), progress)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin : Alignment.topLeft,
          end   : Alignment.bottomRight,
          colors: [c1, c2],
        ),
      ),
    );
  }
}
