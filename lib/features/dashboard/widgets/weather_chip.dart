import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherChip extends StatelessWidget {
  const WeatherChip({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final now = DateFormat('HH:mm').format(DateTime.now());

    // ↓ push chip below status-bar + app-bar
    final double topOffset = MediaQuery.of(context).padding.top + kToolbarHeight + 8;

    return Positioned(
      top: topOffset,          //  ← was just 10
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wb_sunny, size: 18, color: Colors.white),
            const SizedBox(width: 4),
            const Text('22 °C',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 6),
            Text(now, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
