import 'package:extreme_focus_tetris/features/game/domain/usecases/level_curve.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('levelForLines', () {
    test('starts at level 1 with zero lines', () {
      expect(LevelCurve.levelForLines(0), 1);
    });

    test('advances one level every 10 lines', () {
      expect(LevelCurve.levelForLines(9), 1);
      expect(LevelCurve.levelForLines(10), 2);
      expect(LevelCurve.levelForLines(19), 2);
      expect(LevelCurve.levelForLines(20), 3);
    });
  });

  group('dropInterval', () {
    test('matches the spec.md 8.6 table in classic mode', () {
      expect(LevelCurve.dropInterval(1, focusMode: false), const Duration(milliseconds: 1000));
      expect(LevelCurve.dropInterval(5, focusMode: false), const Duration(milliseconds: 500));
      expect(LevelCurve.dropInterval(10, focusMode: false), const Duration(milliseconds: 180));
      expect(LevelCurve.dropInterval(12, focusMode: false), const Duration(milliseconds: 150));
      expect(LevelCurve.dropInterval(15, focusMode: false), const Duration(milliseconds: 120));
      expect(LevelCurve.dropInterval(18, focusMode: false), const Duration(milliseconds: 100));
      expect(LevelCurve.dropInterval(25, focusMode: false), const Duration(milliseconds: 80));
    });

    test('Focus Mode caps the effective speed at level 10 no matter how high the real level is', () {
      final level10 = LevelCurve.dropInterval(10, focusMode: false);
      expect(LevelCurve.dropInterval(11, focusMode: true), level10);
      expect(LevelCurve.dropInterval(20, focusMode: true), level10);
      expect(LevelCurve.dropInterval(99, focusMode: true), level10);
    });

    test('Focus Mode does not change anything below level 10', () {
      expect(
        LevelCurve.dropInterval(4, focusMode: true),
        LevelCurve.dropInterval(4, focusMode: false),
      );
    });
  });
}
