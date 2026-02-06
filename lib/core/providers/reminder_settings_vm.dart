import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/reminder_scheduler.dart';

/// Change-notifier powering the Hydration-reminder settings UI.
///
/// * Loads cached prefs, watches toggles, and reschedules notifications.
/// * Exposes `calendarPerm` so the UI can show / hide the “Connect Calendar”
///   banner without blocking the whole screen.
class ReminderSettingsVM with ChangeNotifier {
  ReminderSettingsVM({
    required Permission calendarPermission,
    required SharedPreferences prefs,
    required ReminderScheduler scheduler,
  })  : _calendarPermission = calendarPermission,
        _prefs = prefs,
        _scheduler = scheduler {
    // ── Load cached prefs ────────────────────────────────────────────
    remindersEnabled = _prefs.getBool(_kEnabled) ?? true;
    useSmart         = _prefs.getBool(_kSmart)   ?? true;

    interval         =
        Duration(minutes: _prefs.getInt(_kInterval) ?? 90);

    quietFrom  = _readTimeOfDay(_kQuietFrom)  ?? const TimeOfDay(hour: 8,  minute: 0);
    quietUntil = _readTimeOfDay(_kQuietUntil) ?? const TimeOfDay(hour: 22, minute: 0);

    activeWeekdays   = (_prefs.getStringList(_kWeekdays) ??
        List.generate(7, (i) => '${i + 1}'))
        .map(int.parse)
        .toSet();

    // Initialise calendar-permission asynchronously so UI isn’t blocked.
    _initCalendarPermission();

    // Kick off first scheduling pass.
    _refreshScheduler();
  }

  // ───────────────────────── Public state ───────────────────────────
  late bool remindersEnabled;
  late bool useSmart;
  late Duration interval;
  late TimeOfDay quietFrom, quietUntil;
  late Set<int> activeWeekdays;
  PermissionStatus calendarPerm = PermissionStatus.denied;

  // ───────────────────────── Private refs ───────────────────────────
  final Permission _calendarPermission;
  final SharedPreferences _prefs;
  final ReminderScheduler _scheduler;

  static const _kEnabled     = 'hydr.enabled';
  static const _kSmart       = 'hydr.smart';
  static const _kInterval    = 'hydr.interval';
  static const _kQuietFrom   = 'hydr.quietFrom';
  static const _kQuietUntil  = 'hydr.quietUntil';
  static const _kWeekdays    = 'hydr.weekdays';

  // ───────────────────────── Init helpers ───────────────────────────
  Future<void> _initCalendarPermission() async {
    calendarPerm = await _calendarPermission.status;
    notifyListeners();
  }

  // ───────────────────────── Actions ────────────────────────────────
  Future<void> toggleMaster(bool on) async {
    remindersEnabled = on;
    await _prefs.setBool(_kEnabled, on);
    await _refreshScheduler();
    notifyListeners();
  }

  Future<void> switchMode(bool smart) async {
    useSmart = smart;
    notifyListeners();
    await _prefs.setBool(_kSmart, smart);
    await _refreshScheduler();
  }

  Future<void> setInterval(Duration d) async {
    interval = d;
    await _prefs.setInt(_kInterval, d.inMinutes);
    await _refreshScheduler();
    notifyListeners();
  }

  Future<void> setQuietHours(TimeOfDay from, TimeOfDay until) async {
    quietFrom  = from;
    quietUntil = until;
    await _saveTimeOfDay(_kQuietFrom, from);
    await _saveTimeOfDay(_kQuietUntil, until);
    await _refreshScheduler();
    notifyListeners();
  }

  Future<void> toggleWeekday(int day) async {
    if (activeWeekdays.contains(day)) {
      activeWeekdays.remove(day);
    } else {
      activeWeekdays.add(day);
    }
    await _prefs.setStringList(
      _kWeekdays,
      activeWeekdays.map((e) => e.toString()).toList(),
    );
    await _refreshScheduler();
    notifyListeners();
  }

  Future<void> requestCalendarPerm() async {
    calendarPerm = await _calendarPermission.request();
    notifyListeners();
    if (calendarPerm.isGranted) await _refreshScheduler();
  }

  // ───────────────────────── Helpers ────────────────────────────────
  Future<void> _refreshScheduler() async {
    if (useSmart && !calendarPerm.isGranted) return;
    await _scheduler.syncWithSettings(this);
  }

  Future<void> _saveTimeOfDay(String key, TimeOfDay t) =>
      _prefs.setInt(key, t.hour * 60 + t.minute);

  TimeOfDay? _readTimeOfDay(String key) {
    final minutes = _prefs.getInt(key);
    if (minutes == null) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }
}
