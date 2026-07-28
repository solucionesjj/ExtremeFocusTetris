import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/tetromino_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Focus Mode desaturates every block color by 10 percentage points', () {
    for (final type in TetrominoType.values) {
      final classic = colorForTetromino(type);
      final focus = colorForTetromino(type, focusMode: true);

      final classicHsl = HSLColor.fromColor(classic);
      final focusHsl = HSLColor.fromColor(focus);

      expect(focusHsl.saturation, moreOrLessEquals(classicHsl.saturation - 0.1, epsilon: 0.01));
      // Hue and lightness stay put — only saturation changes.
      expect(focusHsl.hue, moreOrLessEquals(classicHsl.hue, epsilon: 0.5));
      expect(focusHsl.lightness, moreOrLessEquals(classicHsl.lightness, epsilon: 0.01));
    }
  });
}
