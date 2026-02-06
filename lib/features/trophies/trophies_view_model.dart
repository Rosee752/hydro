import 'package:flutter/foundation.dart';

/// Change-notifier that drives the Challenge Dashboard.
class TrophiesViewModel extends ChangeNotifier {
  int? _openCardIndex;
  int _completedTipsToday = 0;

  /// Index of the expanded card (null → none).
  int? get openCardIndex => _openCardIndex;

  /// 0-3 tips ticked off today.
  int get completedTipsToday => _completedTipsToday;

  /// Single-expand logic.
  void toggleCard(int index) {
    _openCardIndex = _openCardIndex == index ? null : index;
    notifyListeners();
  }

  /// Mark how many tips are done (future use).
  void setCompletedTips(int value) {
    _completedTipsToday = value.clamp(0, 3);
    notifyListeners();
  }

  void onSeeAll() {
    // TODO: navigate to a dedicated tips screen
  }
}
