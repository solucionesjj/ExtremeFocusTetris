import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/cell_texture.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/tetromino_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('colorForTetromino', () {
    test('the colorblind-safe palette gives all 7 pieces a distinct color', () {
      final colors = TetrominoType.values.map((type) => colorForTetromino(type, colorblindMode: true)).toSet();
      expect(colors.length, TetrominoType.values.length);
    });

    test('the standard palette gives all 7 pieces a distinct color', () {
      final colors = TetrominoType.values.map((type) => colorForTetromino(type)).toSet();
      expect(colors.length, TetrominoType.values.length);
    });

    test('colorblind mode changes the color used for every piece', () {
      for (final type in TetrominoType.values) {
        expect(colorForTetromino(type, colorblindMode: true), isNot(colorForTetromino(type)));
      }
    });

    test('focusMode desaturation still applies on top of the colorblind palette', () {
      final base = colorForTetromino(TetrominoType.i, colorblindMode: true);
      final desaturated = colorForTetromino(TetrominoType.i, colorblindMode: true, focusMode: true);
      expect(desaturated, isNot(base));
    });
  });

  group('textureForTetromino', () {
    test('every piece type gets a distinct texture pattern', () {
      final textures = TetrominoType.values.map(textureForTetromino).toSet();
      expect(textures.length, TetrominoType.values.length);
    });
  });
}
