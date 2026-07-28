import '../entities/line_clear_outcome.dart';
import '../entities/t_spin_type.dart';

/// The points awarded for a lock and the combo/Back-to-Back state that
/// follows it.
class ScoreResult {
  final int pointsAwarded;
  final int newCombo;
  final bool newBackToBack;

  const ScoreResult({
    required this.pointsAwarded,
    required this.newCombo,
    required this.newBackToBack,
  });
}

/// Full scoring table — spec.md section 8.5.
abstract final class CalculateScore {
  static ScoreResult call({
    required LineClearOutcome outcome,
    required int level,
    required int currentCombo,
    required bool currentBackToBack,
  }) {
    final noClearAtAll = outcome.linesCleared == 0 && outcome.tSpinType == TSpinType.none;
    if (noClearAtAll) {
      return const ScoreResult(pointsAwarded: 0, newCombo: -1, newBackToBack: false);
    }

    final base = _baseScore(outcome, level);
    final b2bApplies = outcome.isDifficult && currentBackToBack;
    final afterB2B = b2bApplies ? (base * 1.5).floor() : base;

    final newCombo = outcome.linesCleared > 0 ? currentCombo + 1 : -1;
    final comboBonus = newCombo > 0 ? 50 * newCombo * level : 0;

    final perfectClearBonus = outcome.isPerfectClear
        ? _perfectClearBonus(outcome.linesCleared, level)
        : 0;

    final newBackToBack = outcome.linesCleared > 0 ? outcome.isDifficult : currentBackToBack;

    return ScoreResult(
      pointsAwarded: afterB2B + comboBonus + perfectClearBonus,
      newCombo: newCombo,
      newBackToBack: newBackToBack,
    );
  }

  static int softDropPoints(int cellsTravelled) => cellsTravelled;

  static int hardDropPoints(int cellsTravelled) => cellsTravelled * 2;

  static int _baseScore(LineClearOutcome outcome, int level) {
    final lines = outcome.linesCleared;
    return switch (outcome.tSpinType) {
      TSpinType.full => switch (lines) {
        0 => 400 * level,
        1 => 800 * level,
        2 => 1200 * level,
        3 => 1600 * level,
        _ => throw ArgumentError('A T-Spin cannot clear $lines lines'),
      },
      TSpinType.mini => switch (lines) {
        0 => 100 * level,
        1 => 200 * level,
        2 => 400 * level,
        _ => throw ArgumentError('A T-Spin Mini cannot clear $lines lines'),
      },
      TSpinType.none => switch (lines) {
        1 => 100 * level,
        2 => 300 * level,
        3 => 500 * level,
        4 => 800 * level,
        _ => 0,
      },
    };
  }

  static int _perfectClearBonus(int lines, int level) => switch (lines) {
    1 => 800 * level,
    2 => 1200 * level,
    3 => 1800 * level,
    4 => 2000 * level,
    _ => 0,
  };
}
