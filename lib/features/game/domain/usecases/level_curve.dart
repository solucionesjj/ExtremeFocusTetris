/// Level progression and drop-speed curve — spec.md section 8.6.
abstract final class LevelCurve {
  static const int linesPerLevel = 10;

  static int levelForLines(int totalLinesCleared) =>
      (totalLinesCleared ~/ linesPerLevel) + 1;

  /// In Focus Mode the effective level is capped at 10 so the drop speed
  /// never exceeds a calm pace, regardless of the real level reached.
  static Duration dropInterval(int level, {required bool focusMode}) {
    final effectiveLevel = focusMode && level > 10 ? 10 : level;
    final milliseconds = switch (effectiveLevel) {
      1 => 1000,
      2 => 850,
      3 => 700,
      4 => 600,
      5 => 500,
      6 => 400,
      7 => 330,
      8 => 270,
      9 => 220,
      10 => 180,
      >= 11 && <= 13 => 150,
      >= 14 && <= 16 => 120,
      >= 17 && <= 19 => 100,
      _ => 80,
    };
    return Duration(milliseconds: milliseconds);
  }
}
