/// High-level page that stitches all dashboard widgets together.
library;

import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../state/app_state.dart';
import '../../../shared/widgets/hydro_drawer.dart';
import '../widgets/mood_background.dart';
import '../widgets/bubble_field.dart';
import '../widgets/weather_chip.dart';
import '../widgets/hydro_orbit.dart';
import '../widgets/water_card.dart';

const _goalMl            = 2500.0;
const _maxSkins          = 5;
const _celebrateDuration = Duration(seconds: 3);
const _amberGold         = Color(0xFFFFC53A);

class CalmDashboard extends ConsumerStatefulWidget {
  const CalmDashboard({super.key});
  @override
  ConsumerState<CalmDashboard> createState() => _DashState();
}

class _DashState extends ConsumerState<CalmDashboard>
    with TickerProviderStateMixin {
  // animation controllers
  late final _waveCtl =
  AnimationController(vsync: this, duration: const Duration(seconds: 2))
    ..repeat();
  late final _confetti = ConfettiController(duration: _celebrateDuration);

  // persistent UI state
  bool   _celebrated = false;
  int    _unlocked   = 1;   // how many planet skins are unlocked
  int    _skinIdx    = 0;   // which skin is currently shown
  String? _banner;          // overlay message

  @override
  void initState() {
    super.initState();
    _restorePrefs();
  }

  Future<void> _restorePrefs() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _unlocked = sp.getInt('unlockedSkins') ?? 1;
      _skinIdx  = sp.getInt('skinIdx')        ?? 0;
    });
  }

  Future<void> _persistPrefs() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('unlockedSkins', _unlocked);
    await sp.setInt('skinIdx', _skinIdx);
  }

  @override
  void dispose() {
    _waveCtl.dispose();
    _confetti.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────── UI
  @override
  Widget build(BuildContext context) {
    final entries  = ref.watch(waterTodayProvider);
    final consumed = entries.fold<double>(0, (s, e) => s + e.amountMl);
    final progress = (consumed / _goalMl).clamp(0.0, 1.0);

    // celebrate once we cross the goal
    if (progress >= 1 && !_celebrated) {
      _celebrated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _celebrate());
    }
    if (progress < 1 && _celebrated) _celebrated = false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar : _topBar(context),
      drawer : const HydroDrawer(),
      body   : Stack(
        children: [
          MoodBackground(progress: progress),
          const BubbleField(),
          // planet + moons
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: HydroOrbit(
                percent     : progress,
                skinIdx     : _skinIdx,
                onPlanetTap : () {
                  setState(() => _skinIdx = (_skinIdx + 1) % _unlocked);
                  _persistPrefs();
                },
                goldHue     : _amberGold,
              ),
            ),
          ),
          const WeatherChip(),
          // confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController : _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency  : 0.08,
              numberOfParticles  : 30,
              maxBlastForce      : 20,
              minBlastForce      : 5,
              colors             : [_amberGold, Colors.white, const Color(0xFF00C795)],
            ),
          ),
          // banner
          if (_banner != null)
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _banner = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(153),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _banner!,
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          // water card
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: WaterCard(
                percent  : progress,
                consumed : consumed,
                waveCtl  : _waveCtl,
                goldHue  : _amberGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────── top-bar
  PreferredSizeWidget _topBar(BuildContext ctx) => PreferredSize(
    preferredSize: const Size.fromHeight(48),
    child: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: Colors.white.withAlpha(38), // ~15 %
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Hydro!',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
      ),
    ),
  );

  // ─────────────────────────────────────────────────── celebration logic
  Future<void> _celebrate() async {
    // unlock new skin if any remain
    if (_unlocked < _maxSkins) {
      setState(() {
        _unlocked++;
        _skinIdx = _unlocked - 1;
        _banner  = 'Planet $_unlocked unlocked!';
      });
      await _persistPrefs();
    } else {
      setState(() => _banner = 'Daily goal reached!');
    }

    // heavy haptics
    for (var i = 0; i < 15; i++) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 90));
    }
    await HapticFeedback.vibrate();

    // confetti
    _confetti.play();
    Future.delayed(
      _celebrateDuration,
          () => mounted ? setState(() => _banner = null) : null,
    );
  }
}
