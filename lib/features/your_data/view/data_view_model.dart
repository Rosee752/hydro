import 'package:flutter/material.dart';

import '../activity_level.dart';
import '../hydration_calculator.dart';
import '../../../core/helpers/permission_helper.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/health_repository.dart';

@immutable
class DataState {
  const DataState({
    required this.sex,
    required this.age,
    this.weightKg,
    this.locationName,
    required this.ambientTempC,
    this.caloriesToday,
    required this.activity,
    required this.litresPerDay,
  });

  final String sex;
  final int age;
  final double? weightKg;
  final String? locationName;
  final double ambientTempC;
  final double? caloriesToday;
  final ActivityLevel activity;
  final double litresPerDay;

  DataState copyWith({
    String? sex,
    int? age,
    double? weightKg,
    String? locationName,
    double? ambientTempC,
    double? caloriesToday,
    ActivityLevel? activity,
    double? litresPerDay,
  }) =>
      DataState(
        sex: sex ?? this.sex,
        age: age ?? this.age,
        weightKg: weightKg ?? this.weightKg,
        locationName: locationName ?? this.locationName,
        ambientTempC: ambientTempC ?? this.ambientTempC,
        caloriesToday: caloriesToday ?? this.caloriesToday,
        activity: activity ?? this.activity,
        litresPerDay: litresPerDay ?? this.litresPerDay,
      );
}

/// Drives the Your-Data screen via a simple `ValueNotifier`.
class DataViewModel {
  DataViewModel({
    required PermissionHelper permissionHelper,
    required LocationService locationService,
    required HealthRepository healthRepository,
  })  : _perm = permissionHelper,
        _loc  = locationService;

  final PermissionHelper _perm;
  final LocationService  _loc;
  final HydrationCalculator _calc = HydrationCalculator();

  final ValueNotifier<DataState> _state = ValueNotifier(const DataState(
    sex: 'male',
    age: 23,
    ambientTempC: 22,
    activity: ActivityLevel.sedentary,
    litresPerDay: 3.7,
  ));

  ValueNotifier<DataState> get notifier => _state;

  // ── setters wired from UI ─────────────────────────────────
  void setSex(String v)           => _patch(sex: v);
  void setAge(int v)              => _patch(age: v);
  void setWeight(double? kg)      => _patch(weightKg: kg);
  void setSlider(ActivityLevel l) => _patch(activity: l);

  Future<void> toggleAutoLocation(bool on) async {
    if (!on) return;
    if (!await _perm.requestLocation()) return;
    final info = await _loc.currentCityAndTemp();
    _patch(locationName: info.city, ambientTempC: info.tempC);
  }

  // ── internal helper ──────────────────────────────────────
  void _patch({
    String? sex,
    int? age,
    double? weightKg,
    String? locationName,
    double? ambientTempC,
    double? caloriesToday,
    ActivityLevel? activity,
  }) {
    final s = _state.value.copyWith(
      sex: sex,
      age: age,
      weightKg: weightKg,
      locationName: locationName,
      ambientTempC: ambientTempC,
      caloriesToday: caloriesToday,
      activity: activity,
    );

    final litres = _calc.litresPerDay(
      sex: s.sex,
      weightKg: s.weightKg,
      ambientTempC: s.ambientTempC,
      caloriesBurned: s.caloriesToday,
      activity: s.activity,
    );

    _state.value = s.copyWith(litresPerDay: litres);
  }
}
