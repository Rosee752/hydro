import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class InfoTipBubble extends StatelessWidget {
  const InfoTipBubble({super.key});

  static const _size = 140.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 16,
      child: GestureDetector(
        onTap: () => _showSheet(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              width: _size,
              height: _size,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Regular sips keep energy, mood and cognition high.\nLittle drinks, big gains!',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(height: 1.2),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSheet(BuildContext ctx) async {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Hydration facts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const Text('• Even mild dehydration can impair cognitive performance.'),
            const Text('• Water helps regulate body temperature and energy.'),
            const Text('• Aim for small sips every 1–2 hours.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(
                    'https://www.uclahealth.org/news/article/hydration-hacks-how-drink-more-water-every-day'),
              ),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Learn more (NIH)'),
            ),
          ],
        ),
      ),
    );
  }
}
