import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper around `permission_handler`.
class PermissionHelper {
  /// Ask for foreground-location access.
  Future<bool> requestLocation() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Ask for access to Health / Activity recognition.
  Future<bool> requestHealth() async {
    final statuses = await [
      Permission.activityRecognition,
      Permission.sensors, // Wear OS
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }
}
