import 'dart:ui';

import 'package:extreme_focus_tetris/features/game/presentation/widgets/cell_texture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('paintCellTexture draws every pattern without throwing', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const rect = Rect.fromLTWH(0, 0, 40, 40);

    for (final texture in CellTexture.values) {
      expect(() => paintCellTexture(canvas, rect, texture), returnsNormally);
    }

    recorder.endRecording().dispose();
  });
}
