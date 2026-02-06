// lib/core/models/user_profile.dart
/// A single user’s immutable profile.
///
/// If you need to change something, use `copyWith` rather than mutating fields.
class UserProfile {
  final String id;

  // “male” / “female” / “other”
  final String sex;

  /// Age in **whole years**.
  final int age;

  /// Body-weight in kilograms (kg).
  final double weightKg;

  /// “low”, “medium” or “high” (used to compute a personalised goal later)
  final String activityLevel;

  /// Personalised daily hydration goal (ml).
  /// ────────────────
  /// **Display**: convert to litres in the UI (`/ 1000`).
  /// **Storage**: keep it as millilitres to avoid rounding issues.
  final double dailyGoalMl;

  const UserProfile({
    required this.id,
    required this.sex,
    required this.age,
    required this.weightKg,
    required this.activityLevel,
    required this.dailyGoalMl,
  });

  /// Shallow copy helper — lets you change only the fields you need.
  UserProfile copyWith({
    String? sex,
    int? age,
    double? weightKg,
    String? activityLevel,
    double? dailyGoalMl,
  }) {
    return UserProfile(
      id: id,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
    );
  }
}
