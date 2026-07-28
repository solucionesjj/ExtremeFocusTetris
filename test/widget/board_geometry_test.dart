import 'dart:ui';

import 'package:extreme_focus_tetris/features/game/presentation/widgets/board_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoardGeometry', () {
    test('letterboxes horizontally when the area is wider than 1:2', () {
      final geometry = BoardGeometry.of(const Size(400, 400));
      // height/20 (20) is the binding constraint versus width/10 (40).
      expect(geometry.cellSize, 20);
      expect(geometry.offset.dx, greaterThan(0));
      expect(geometry.offset.dy, 0);
    });

    test('letterboxes vertically when the area is narrower than 1:2', () {
      final geometry = BoardGeometry.of(const Size(100, 400));
      // width/10 (10) is the binding constraint versus height/20 (20).
      expect(geometry.cellSize, 10);
      expect(geometry.offset.dy, greaterThan(0));
      expect(geometry.offset.dx, 0);
    });

    test('columnCenterX/rowCenterY land on the middle of each cell', () {
      final geometry = BoardGeometry.of(const Size(200, 400));
      expect(geometry.columnCenterX(0), geometry.offset.dx + geometry.cellSize * 0.5);
      expect(geometry.columnCenterX(9), geometry.offset.dx + geometry.cellSize * 9.5);
      expect(geometry.rowCenterY(0), geometry.offset.dy + geometry.cellSize * 0.5);
      expect(geometry.rowCenterY(19), geometry.offset.dy + geometry.cellSize * 19.5);
    });
  });
}
