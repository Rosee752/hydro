import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hydro/core/providers/hydration_goal_provider.dart'
    show HydrationGoalProvider;
import 'package:intl/intl.dart';

import '../history_controller.dart';
import '../../dashboard/widgets/mood_background.dart';
import '../../dashboard/widgets/bubble_field.dart';
import '../../dashboard/widgets/weather_chip.dart';

// ───────────────────────────────────────────────────── shadow helper
const _textShadow = [
  Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black45),
];

// ───────────────────────────────────────────────────── range enum
enum HistoryRange { week, month, custom }

extension on HistoryRange {
  String get label => switch (this) {
    HistoryRange.week => 'Week',
    HistoryRange.month => 'Month',
    HistoryRange.custom => 'Custom',
  };
}

// ───────────────────────────────────────────────────── screen
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _ctrl = HistoryController();
  HistoryRange _range = HistoryRange.week;
  late DateTime _customFrom, _customTo;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _customTo = now;
    _customFrom = now.subtract(const Duration(days: 6));
  }

  // convenience
  DateTime get _rangeStart {
    final now = DateTime.now();
    return switch (_range) {
      HistoryRange.week => now.subtract(const Duration(days: 6)),
      HistoryRange.month => DateTime(now.year, now.month, 1),
      HistoryRange.custom => _customFrom,
    };
  }

  DateTime get _rangeEnd =>
      _range == HistoryRange.custom ? _customTo : DateTime.now();

  @override
  Widget build(BuildContext context) {
    // hydrate goal from provider
    final goal = HydrationGoalProvider.of(context)?.hydrationGoal ?? 2000;

    // group entries
    final entries = _ctrl.getEntriesInRange(_rangeStart, _rangeEnd);
    final grouped = <String, int>{}; // key → total ml
    for (final e in entries) {
      final k = HistoryController.dateToKey(e.timestamp);
      grouped[k] = (grouped[k] ?? 0) + e.amountMl;
    }

    final todayTotal =
        grouped[HistoryController.dateToKey(DateTime.now())] ?? 0;
    final todayPercent = todayTotal / goal;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _glassAppBar(context),
      body: Stack(
        children: [
          MoodBackground(progress: todayPercent),
          const BubbleField(),
          const WeatherChip(),

          // top scrim for contrast ────────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x65000000), // 67 % black at top
                      Color(0x00000000), // transparent mid-screen
                    ],
                  ),
                ),
              ),
            ),
          ),

          // main content ───────────────────────────────────────────
          Positioned.fill(
            top: kToolbarHeight + MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // ── range selector pill
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _RangeSelector(
                    range: _range,
                    onChanged: (r) async {
                      if (r == HistoryRange.custom) {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                          initialDateRange:
                          DateTimeRange(start: _customFrom, end: _customTo),
                        );
                        if (picked == null) return;
                        setState(() {
                          _customFrom = picked.start;
                          _customTo = picked.end;
                          _range = r;
                        });
                      } else {
                        setState(() => _range = r);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // ── stat cards
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16),
                    children: _buildStatCards(grouped, goal),
                  ),
                ),
                const SizedBox(height: 4),

                // ── chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _HistoryChart(
                    start: _rangeStart,
                    end: _rangeEnd,
                    grouped: grouped,
                    goal: goal,
                    range: _range,
                  ),
                ),
                const SizedBox(height: 6),

                // ── daily list
                Expanded(
                  child: _DailyList(
                    start: _rangeStart,
                    end: _rangeEnd,
                    grouped: grouped,
                    goal: goal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────── helpers
  AppBar _glassAppBar(BuildContext ctx) => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Text('Your history',
        style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: _textShadow)),
    centerTitle: false,
    iconTheme: const IconThemeData(color: Colors.white),
  );

  List<Widget> _buildStatCards(Map<String, int> grouped, int goal) {
    if (grouped.isEmpty) {
      return [
        const _StatCard(label: 'No data yet', value: '—'),
      ];
    }
    final totals = grouped.values.toList()..sort();
    final highest = totals.last;
    final avg = totals.reduce((a, b) => a + b) / totals.length;
    final streak = _calcLongestStreak(grouped, goal);

    return [
      _StatCard(label: 'Highest day', value: '$highest ml'),
      _StatCard(label: '7-day avg', value: '${avg.round()} ml'),
      _StatCard(label: 'Longest streak', value: '$streak d'),
      _StatCard(
          label: 'Total cups',
          value: '${(totals.reduce((a, b) => a + b) / 250).round()}'),
    ];
  }

  int _calcLongestStreak(Map<String, int> grouped, int goal) {
    var streak = 0, longest = 0;
    final keys = grouped.keys.toList()..sort();
    for (final k in keys) {
      if (grouped[k]! >= goal) {
        streak++;
        if (streak > longest) longest = streak;
      } else {
        streak = 0;
      }
    }
    return longest;
  }
}

// ───────────────────────────────────────────────────── Range pill
class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.range,
    required this.onChanged,
  });

  final HistoryRange range;
  final ValueChanged<HistoryRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withOpacity(.25), // darker than .15
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final r in HistoryRange.values)
            _pill(
              context,
              label: r.label,
              selected: r == range,
              onTap: () => onChanged(r),
            ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext ctx,
      {required String label,
        required bool selected,
        required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
          decoration: BoxDecoration(
            color:
            selected ? Colors.white.withOpacity(.30) : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(label,
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                shadows: _textShadow,
              )),
        ),
      );
}

// ───────────────────────────────────────────────────── Stat card
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) => Container(
    width: 110,
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.28), // was .20
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value,
            style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: _textShadow)),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
                fontSize: 12,
                color: Colors.white70,
                height: 1.2,
                shadows: _textShadow)),
      ],
    ),
  );
}

// ───────────────────────────────────────────────────── Chart
class _HistoryChart extends StatelessWidget {
  const _HistoryChart({
    required this.start,
    required this.end,
    required this.grouped,
    required this.goal,
    required this.range,
  });

  final DateTime start, end;
  final Map<String, int> grouped;
  final int goal;
  final HistoryRange range;

  @override
  Widget build(BuildContext context) {
    final days = end.difference(start).inDays + 1;
    final spots = <FlSpot>[];
    final bottomLabels = <String>[];

    for (int i = 0; i < days; i++) {
      final d = start.add(Duration(days: i));
      final key = HistoryController.dateToKey(d);
      spots
          .add(FlSpot(i.toDouble(), (grouped[key] ?? 0).toDouble()));
      bottomLabels.add(range == HistoryRange.week
          ? DateFormat.E().format(d).substring(0, 1)
          : '${d.day}');
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: goal.toDouble() * 1.2,
          gridData: FlGridData(
            show: true,
            horizontalInterval: goal.toDouble() / 2,
            getDrawingHorizontalLine: (_) => FlLine(
                strokeWidth: .6, color: Colors.white54), // stronger grid
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: goal.toDouble() / 2,
                getTitlesWidget: (v, _) => Text('${v.toInt()}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= bottomLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(bottomLabels[idx],
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11));
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.white,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.white.withOpacity(.10), // was .15
              ),
              dotData: FlDotData(
                show: spots.length <= 31,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────── daily list
class _DailyList extends StatelessWidget {
  const _DailyList({
    required this.start,
    required this.end,
    required this.grouped,
    required this.goal,
  });

  final DateTime start, end;
  final Map<String, int> grouped;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final days = end.difference(start).inDays + 1;
    return ListView.builder(
      itemCount: days,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (_, i) {
        final d = end.subtract(Duration(days: i)); // newest first
        final key = HistoryController.dateToKey(d);
        final total = grouped[key] ?? 0;
        final pct = (total / goal).clamp(0.0, 1.0);
        return _DailyRow(date: d, ml: total, percent: pct);
      },
    );
  }
}

class _DailyRow extends StatelessWidget {
  const _DailyRow({
    required this.date,
    required this.ml,
    required this.percent,
  });

  final DateTime date;
  final int ml;
  final double percent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.28), // was .20
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(DateFormat('MMM d').format(date),
              style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: _textShadow)),
          const SizedBox(width: 10),
          Expanded(
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(.15),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text('$ml ml',
              style: GoogleFonts.fredoka(
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.2,
                  shadows: _textShadow)),
        ],
      ),
    ),
  );
}
