import 'dart:math' as math;
import 'dart:ui';

import '../../domain/entities/board.dart';

/// The pixel mapping from a [Size] to the board's cell grid — shared by
/// [BoardPainter] (which computes it every frame anyway) and `GameScreen`
/// (which needs it once, outside of paint, to place particle emitters at
/// the correct cleared-row/column centers).
class BoardGeometry {
  final double cellSize;
  final Offset offset;

  const BoardGeometry(this.cellSize, this.offset);

  factory BoardGeometry.of(Size size) {
    final cellSize = math.min(size.width / Board.columns, size.height / Board.visibleRows);
    final boardWidth = cellSize * Board.columns;
    final boardHeight = cellSize * Board.visibleRows;
    final offset = Offset(
      (size.width - boardWidth) / 2,
      (size.height - boardHeight) / 2,
    );
    return BoardGeometry(cellSize, offset);
  }

  double columnCenterX(int col) => offset.dx + (col + 0.5) * cellSize;

  double rowCenterY(int visibleRow) => offset.dy + (visibleRow + 0.5) * cellSize;
}
