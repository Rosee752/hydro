import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HydroOrbit extends StatefulWidget {
  const HydroOrbit({
    super.key,
    required this.percent,
    required this.skinIdx,
    required this.onPlanetTap,
    required this.goldHue,
  });

  final double    percent;    // 0‒1
  final int       skinIdx;    // 0‒4
  final VoidCallback onPlanetTap;
  final Color     goldHue;

  @override
  State<HydroOrbit> createState() => _HydroOrbitState();
}

class _HydroOrbitState extends State<HydroOrbit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl =
  AnimationController(vsync: this, duration: const Duration(seconds: 8))
    ..repeat();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();                       //  ← must-call-super
  }

  @override
  Widget build(BuildContext context) {
    final moons = (widget.percent * 2500 / 250).clamp(0, 8).floor();
    final goal  = widget.percent >= 1;
    final planetAsset = 'assets/planet_${widget.skinIdx}.svg';

    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, _) => GestureDetector(
        onTap: widget.onPlanetTap,
        child: SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // orbit ring
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30),
                ),
              ),
              // central planet
              SvgPicture.asset(planetAsset, width: 80),
              // moons
              for (var i = 0; i < moons; i++)
                _Moon(
                  angle: (2 * math.pi / moons) * i + _ctl.value * 2 * math.pi,
                  color: goal ? widget.goldHue : const Color(0xFFE0F7FA),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Moon extends StatelessWidget {
  const _Moon({required this.angle, required this.color});
  final double angle;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    const radius = 95.0;
    return Transform.translate(
      offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      child: SvgPicture.asset(
        'assets/droplet.svg',
        width: 22,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
