import 'dart:async';

import 'package:collection/collection.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';

import 'package:hydro/core/services/local_notification_service.dart';
import 'package:hydro/core/providers/reminder_settings_vm.dart';

/// Computes *when* reminders should fire and delegates the actual
/// notification-creation to [LocalNotificationService].
class ReminderScheduler {
  ReminderScheduler({
    required DeviceCalendarPlugin calendar,
    required LocalNotificationService notifications,
  })  : _calendar = calendar,
        _notifications = notifications;

  final DeviceCalendarPlugin      _calendar;
  final LocalNotificationService _notifications;

  //─────────────────────────────────────────────────────────
  // Entry-point – called every time user settings change
  //─────────────────────────────────────────────────────────
  Future<void> syncWithSettings(ReminderSettingsVM s) async {
    if (!s.remindersEnabled) {
      await _notifications.cancelHydrationReminders();
      return;
    }


    await _notifications.cancelHydrationReminders(); // wipe stale ones

    final today     = DateTime.now();
    final weekday   = today.weekday; // 1 = Mon … 7 = Sun
    if (!s.activeWeekdays.contains(weekday)) return;

    final start = _timeOfDayToday(s.quietFrom);
    final end   = _timeOfDayToday(s.quietUntil);

    if (s.useSmart) {
      await _scheduleSmart(start, end, s);
    } else {
      await _scheduleCustom(start, end, s);
    }
  }

  //─────────────────────────────────────────────────────────
  // Smart algorithm
  //─────────────────────────────────────────────────────────
  static const _baseInterval = Duration(minutes: 90);

  Future<void> _scheduleSmart(
      DateTime start,
      DateTime end,
      ReminderSettingsVM s,
      ) async {
    final calendars    = await _calendar.retrieveCalendars();
    final calendarId   = calendars.data?.first.id;
    if (calendarId == null) return;

    final eventsResult = await _calendar.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: start, endDate: end),
    );
    final events = eventsResult.data ?? <Event>[];

    final slots  = _generateSlots(start, end, _baseInterval);

    for (final slot in slots) {
      final clash = events.firstWhereOrNull(
            (e) => e.start!.isBefore(slot) && e.end!.isAfter(slot),
      );

      final scheduled = clash != null ? _nextQuarterHour(clash.end!) : slot;
      if (scheduled.isAfter(end)) continue;

      await _notifications.scheduleHydrationNotification(
        scheduled,
        vibrationOnly: clash != null,
      );
    }
  }

  /// Returns the next three scheduled times *for preview in the UI*.
  Future<List<DateTime>> nextThreeSmart(ReminderSettingsVM s) async {
    if (!s.remindersEnabled || !s.useSmart) return [];

    final start = _timeOfDayToday(s.quietFrom);
    final end   = _timeOfDayToday(s.quietUntil);

    final calendars    = await _calendar.retrieveCalendars();
    final calendarId   = calendars.data?.first.id;
    if (calendarId == null) return [];

    final eventsResult = await _calendar.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: start, endDate: end),
    );
    final events = eventsResult.data ?? <Event>[];

    final out   = <DateTime>[];
    final slots = _generateSlots(start, end, _baseInterval);

    for (final slot in slots) {
      final clash = events.firstWhereOrNull(
            (e) => e.start!.isBefore(slot) && e.end!.isAfter(slot),
      );
      final t = clash != null ? _nextQuarterHour(clash.end!) : slot;
      if (t.isAfter(DateTime.now())) out.add(t);
      if (out.length == 3) break;
    }
    return out;
  }

  //─────────────────────────────────────────────────────────
  // Custom algorithm
  //─────────────────────────────────────────────────────────
  Future<void> _scheduleCustom(
      DateTime start,
      DateTime end,
      ReminderSettingsVM s,
      ) async {
    for (DateTime t = start; t.isBefore(end); t = t.add(s.interval)) {
      await _notifications.scheduleHydrationNotification(t);
    }
  }

  //─────────────────────────────────────────────────────────
  // helpers
  //─────────────────────────────────────────────────────────
  List<DateTime> _generateSlots(
      DateTime start,
      DateTime end,
      Duration step,
      ) {
    final out = <DateTime>[];
    for (var t = start; t.isBefore(end); t = t.add(step)) {
      out.add(t);
    }
    return out;
  }

  DateTime _nextQuarterHour(DateTime t) {
    final minute = ((t.minute + 14) ~/ 15) * 15;
    return DateTime(t.year, t.month, t.day, t.hour, minute);
  }

  DateTime _timeOfDayToday(TimeOfDay tod) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  }
}
