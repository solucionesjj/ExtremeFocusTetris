import 'package:extreme_focus_tetris/features/game/domain/entities/line_clear_outcome.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/t_spin_type.dart';
import 'package:extreme_focus_tetris/features/game/domain/usecases/calculate_score.dart';
import 'package:flutter_test/flutter_test.dart';

LineClearOutcome _outcome({
  int lines = 0,
  TSpinType tSpin = TSpinType.none,
  bool perfectClear = false,
}) => LineClearOutcome(linesCleared: lines, tSpinType: tSpin, isPerfectClear: perfectClear);

void main() {
  group('base line-clear scoring (spec.md 8.5)', () {
    for (final testCase in [
      (lines: 1, points: 100),
      (lines: 2, points: 300),
      (lines: 3, points: 500),
      (lines: 4, points: 800),
    ]) {
      test('${testCase.lines} line(s) at level 3 scores ${testCase.points * 3}', () {
        final result = CalculateScore.call(
          outcome: _outcome(lines: testCase.lines),
          level: 3,
          currentCombo: -1,
          currentBackToBack: false,
        );
        expect(result.pointsAwarded, testCase.points * 3);
      });
    }
  });

  group('T-Spin scoring', () {
    test('T-Spin Mini with no lines is 100 x level', () {
      final result = CalculateScore.call(
        outcome: _outcome(tSpin: TSpinType.mini),
        level: 2,
        currentCombo: -1,
        currentBackToBack: false,
      );
      expect(result.pointsAwarded, 200);
    });

    test('T-Spin Mini Double is 400 x level', () {
      final result = CalculateScore.call(
        outcome: _outcome(lines: 2, tSpin: TSpinType.mini),
        level: 1,
        currentCombo: -1,
        currentBackToBack: false,
      );
      expect(result.pointsAwarded, 400);
    });

    test('T-Spin Double (full) is 1200 x level', () {
      final result = CalculateScore.call(
        outcome: _outcome(lines: 2, tSpin: TSpinType.full),
        level: 1,
        currentCombo: -1,
        currentBackToBack: false,
      );
      expect(result.pointsAwarded, 1200);
    });
  });

  group('Back-to-Back', () {
    test('a Tetris right after a previous Tetris gets the x1.5 bonus', () {
      final result = CalculateScore.call(
        outcome: _outcome(lines: 4),
        level: 1,
        currentCombo: -1,
        currentBackToBack: true,
      );
      expect(result.pointsAwarded, 1200); // 800 * 1.5
      expect(result.newBackToBack, isTrue);
    });

    test('a Single breaks an active Back-to-Back streak', () {
      final result = CalculateScore.call(
        outcome: _outcome(lines: 1),
        level: 1,
        currentCombo: -1,
        currentBackToBack: true,
      );
      expect(result.pointsAwarded, 100);
      expect(result.newBackToBack, isFalse);
    });

    test('a Tetris with no prior streak establishes Back-to-Back without the bonus yet', () {
      final result = CalculateScore.call(
        outcome: _outcome(lines: 4),
        level: 1,
        currentCombo: -1,
        currentBackToBack: false,
      );
      expect(result.pointsAwarded, 800);
      expect(result.newBackToBack, isTrue);
    });
  });

  group('Combo', () {
    test('the first clear in a streak starts the combo counter but adds no bonus', () {
      final result = CalculateScore.call(
        outcome: _outcome(lines: 1),
        level: 2,
        currentCombo: -1,
        currentBackToBack: false,
      );
      expect(result.newCombo, 0);
      expect(result.pointsAwarded, 200); // just the Single, no combo bonus yet
    });

    test('the second consecutive clear adds 50 x combo x level', () {
      final result = CalculateScore.call(
        outcome: _outcome(lines: 1),
        level: 2,
        currentCombo: 0,
        currentBackToBack: false,
      );
      expect(result.newCombo, 1);
      expect(result.pointsAwarded, 200 + 50 * 1 * 2);
    });

    test('a lock with no line clear resets the combo to -1', () {
      final result = CalculateScore.call(
        outcome: _outcome(),
        level: 5,
        currentCombo: 3,
        currentBackToBack: true,
      );
      expect(result.newCombo, -1);
      expect(result.pointsAwarded, 0);
      expect(result.newBackToBack, isFalse);
    });
  });

  group('Perfect Clear bonus', () {
    test('adds on top of the base line-clear score', () {
      final result = CalculateScore.call(
        outcome: _outcome(lines: 1, perfectClear: true),
        level: 1,
        currentCombo: -1,
        currentBackToBack: false,
      );
      expect(result.pointsAwarded, 100 + 800); // Single + Perfect Clear Single
    });
  });

  group('soft/hard drop points', () {
    test('soft drop is 1 point per cell', () {
      expect(CalculateScore.softDropPoints(5), 5);
    });

    test('hard drop is 2 points per cell', () {
      expect(CalculateScore.hardDropPoints(5), 10);
    });
  });
}
