// lib/features/trophies/view/widgets/glass_challenge_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Frosted quest card that expands to fit its content.
///
/// * No more fixed expanded-height → no overflow.
/// * Higher-opacity parchment tint for better legibility.
/// * “I’m ready!” snack-bar still appears on tap.
/// * Requires no external assets.
class GlassChallengeCard extends StatelessWidget {
  const GlassChallengeCard({
    super.key,
    required this.index,
    required this.title,
    required this.accent,
    required this.icon,
    required this.expanded,
    required this.bullets,
    required this.healthScore,
    required this.onToggle,
  });

  final int index;
  final String title;
  final Color accent;
  final IconData icon;
  final bool expanded;
  final List<String> bullets;
  final int healthScore;
  final VoidCallback onToggle;

  // Collapsed height only; expanded grows naturally.
  static const double _collapsed = 110;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutQuart,
      alignment: Alignment.topCenter,
      child: InkWell(
        key: Key('challenge_card_$index'),
        onTap: () {
          onToggle();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin:
              const EdgeInsets.only(top: 70, left: 90, right: 90),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              backgroundColor: accent.withOpacity(.9),
              duration: const Duration(seconds: 2),
              content: Center(
                child: Text('👍  I’m ready!',
                    style: GoogleFonts.fredoka(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        },
        highlightColor: Colors.transparent,
        splashColor: accent.withOpacity(.15),
        child: ConstrainedBox(
          constraints: expanded
              ? const BoxConstraints() // grow as needed
              : const BoxConstraints.tightFor(height: _collapsed),
          child: _FrostedSurface(
            accent: accent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _CardContent(
                title: title,
                icon: icon,
                accent: accent,
                expanded: expanded,
                bullets: bullets,
                healthScore: healthScore,
                index: index,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Blurred glass + higher-opacity parchment tint & faint grid.
class _FrostedSurface extends StatelessWidget {
  const _FrostedSurface({
    required this.accent,
    required this.child,
  });

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent, width: 2),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(.45),
              Colors.white.withOpacity(.30),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomPaint(
          painter: _GridPainter(),
          child: child,
        ),
      ),
    ),
  );
}

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.title,
    required this.icon,
    required this.accent,
    required this.expanded,
    required this.bullets,
    required this.healthScore,
    required this.index,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final bool expanded;
  final List<String> bullets;
  final int healthScore;
  final int index;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // header row
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('10-Day  •  Challenge',
                    style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.white70)),
                const SizedBox(height: 4),
                Text(title,
                    style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
          Icon(icon, size: 46, color: accent),
        ],
      ),
      const SizedBox(height: 8),

      // expanded section
      if (expanded) ...[
        Align(
          alignment: Alignment.topRight,
          child: _StarChip(
              stars: healthScore, accent: accent, idx: index),
        ),
        const SizedBox(height: 10),
        ...bullets.map(
              (b) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ',
                    style:
                    TextStyle(color: Colors.white, fontSize: 13)),
                Expanded(
                  child: Text(b,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  );
}

/// faint 20-dp grid painter
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.08)
      ..strokeWidth = 1;
    const step = 20.0;
    for (double x = 0; x <= s.width; x += step) {
      c.drawLine(Offset(x, 0), Offset(x, s.height), paint);
    }
    for (double y = 0; y <= s.height; y += step) {
      c.drawLine(Offset(0, y), Offset(s.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// little health-score pill
class _StarChip extends StatelessWidget {
  const _StarChip(
      {required this.stars, required this.accent, required this.idx});

  final int stars;
  final Color accent;
  final int idx;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$stars of 5 stars',
    child: Container(
      key: Key('health_score_$idx'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.22),
        border: Border.all(color: accent),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '★' * stars + '☆' * (5 - stars),
        style: const TextStyle(fontSize: 11, color: Colors.white),
      ),
    ),
  );
}
