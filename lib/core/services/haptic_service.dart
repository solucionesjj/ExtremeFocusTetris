import 'package:flutter/services.dart';

/// Haptic feedback via Flutter's native `HapticFeedback` API — spec.md
/// section 6.4. No third-party `vibration` package: the built-in impact
/// levels already cover every event the spec asks for.
class HapticService {
  bool hapticsEnabled = true;

  void setHapticsEnabled(bool enabled) => hapticsEnabled = enabled;

  void onMove() {
    if (hapticsEnabled) HapticFeedback.selectionClick();
  }

  void onRotate() {
    if (hapticsEnabled) HapticFeedback.lightImpact();
  }

  void onLock() {
    if (hapticsEnabled) HapticFeedback.mediumImpact();
  }

  void onLineClear() {
    if (hapticsEnabled) HapticFeedback.heavyImpact();
  }

  void onGameOver() {
    if (hapticsEnabled) HapticFeedback.vibrate();
  }
}
