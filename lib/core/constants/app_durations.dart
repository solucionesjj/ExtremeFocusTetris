/// Animation durations — spec.md section 7 (Animaciones).
abstract final class AppDurations {
  static const Duration splashLogo = Duration(milliseconds: 600);

  static const Duration screenEnter = Duration(milliseconds: 250);
  static const Duration screenExit = Duration(milliseconds: 200);
  static const Duration menuTransition = Duration(milliseconds: 220);

  static const Duration pieceRotation = Duration(milliseconds: 80);
  static const Duration lateralMove = Duration(milliseconds: 60);
  static const Duration hardDropTrail = Duration(milliseconds: 40);

  static const Duration lineClearFlash = Duration(milliseconds: 120);
  static const Duration lineClearCollapse = Duration(milliseconds: 200);
  static const Duration lineClearTotal = Duration(milliseconds: 320);

  static const Duration levelUpEnter = Duration(milliseconds: 200);
  static const Duration levelUpHold = Duration(milliseconds: 500);
  static const Duration levelUpExit = Duration(milliseconds: 200);

  /// Focus Mode's subtler stand-in for the Classic level-up banner — a
  /// brief tint fade on the board's border — spec.md section 9.2.
  static const Duration focusLevelUpBorderFade = Duration(milliseconds: 400);

  static const Duration gameOverOverlay = Duration(milliseconds: 500);
  static const Duration gameOverShake = Duration(milliseconds: 300);

  static const Duration buttonPress = Duration(milliseconds: 100);
}
