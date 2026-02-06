/// Four-step activity enum used when no calorie data is available.
enum ActivityLevel { sedentary, light, moderate, heavy }

extension ActivityLabel on ActivityLevel {
  String get label => switch (this) {
    ActivityLevel.sedentary => 'Sedentary',
    ActivityLevel.light     => 'Light',
    ActivityLevel.moderate  => 'Moderate',
    ActivityLevel.heavy     => 'Heavy',
  };
}

