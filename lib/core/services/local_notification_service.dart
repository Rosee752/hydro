import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart'       as tz;

/// Thin wrapper around `flutter_local_notifications`.
class LocalNotificationService {
  LocalNotificationService() {
    _init();
  }

  // ── internal constants ───────────────────────────────────────────
  static const _hydrationChannelId   = 'hydration_reminders';
  static const _hydrationChannelName = 'Hydration Reminders';

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> _init() async {
    tz.initializeTimeZones(); // required for `zonedSchedule`

    // Android
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // iOS / macOS
    const darwin  = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin, macOS: darwin),
    );

    // Pre-create channel (Android ≥ O)
    const channel = AndroidNotificationChannel(
      _hydrationChannelId,
      _hydrationChannelName,
      importance: Importance.defaultImportance,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  //──────────────────────────────────────────────────────────────────
  // Public API
  //──────────────────────────────────────────────────────────────────
  Future<void> cancelHydrationReminders() => _plugin.cancelAll();

  /// Schedules a one-off reminder at [when].
  /// If [vibrationOnly] is true, we mute the sound.
  Future<void> scheduleHydrationNotification(
      DateTime when, {
        bool vibrationOnly = false,
      }) async {
    final id = when.millisecondsSinceEpoch.remainder(1 << 31);

    final androidDetails = AndroidNotificationDetails(
      _hydrationChannelId,
      _hydrationChannelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      enableVibration: true,
      playSound: !vibrationOnly,
    );

    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      id,
      'Time to sip 💧',
      'A small drink keeps you energised ✨',
      tz.TZDateTime.from(when, tz.local),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: vibrationOnly ? 'vibrate' : 'sound',
    );
  }
}
