import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/tetromino_type.dart';

/// One of 7 simple, distinct patterns reinforcing a tetromino's color for
/// colorblind users — spec.md section 14: "no solo color". Each piece type
/// gets exactly one, so shape alone (independent of hue) tells pieces apart.
enum CellTexture { horizontalStripes, verticalStripes, diagonalUp, diagonalDown, dots, crossHatch, checkerboard }

CellTexture textureForTetromino(TetrominoType type) => switch (type) {
  TetrominoType.i => CellTexture.horizontalStripes,
  TetrominoType.o => CellTexture.dots,
  TetrominoType.t => CellTexture.diagonalUp,
  TetrominoType.s => CellTexture.diagonalDown,
  TetrominoType.z => CellTexture.crossHatch,
  TetrominoType.j => CellTexture.verticalStripes,
  TetrominoType.l => CellTexture.checkerboard,
};

/// Draws [texture] inside [rect], clipped to it. The overlay is a
/// semi-transparent near-black — every colorblind-safe palette color (see
/// `tetromino_colors.dart`) is mid-brightness, so this reads on all of them
/// without needing a per-color overlay tone.
void paintCellTexture(Canvas canvas, Rect rect, CellTexture texture) {
  final strokePaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.32)
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1, rect.shortestSide * 0.05);
  final fillPaint = Paint()..color = Colors.black.withValues(alpha: 0.24);
  final step = rect.shortestSide * 0.34;

  canvas.save();
  canvas.clipRect(rect);
  switch (texture) {
    case CellTexture.horizontalStripes:
      for (var y = rect.top + rect.height * 0.25; y < rect.bottom; y += step) {
        canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), strokePaint);
      }
    case CellTexture.verticalStripes:
      for (var x = rect.left + rect.width * 0.25; x < rect.right; x += step) {
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), strokePaint);
      }
    case CellTexture.diagonalUp:
      _paintDiagonals(canvas, rect, strokePaint, step, reversed: false);
    case CellTexture.diagonalDown:
      _paintDiagonals(canvas, rect, strokePaint, step, reversed: true);
    case CellTexture.crossHatch:
      _paintDiagonals(canvas, rect, strokePaint, step, reversed: false);
      _paintDiagonals(canvas, rect, strokePaint, step, reversed: true);
    case CellTexture.dots:
      for (final fx in [0.3, 0.7]) {
        for (final fy in [0.3, 0.7]) {
          canvas.drawCircle(
            Offset(rect.left + rect.width * fx, rect.top + rect.height * fy),
            rect.shortestSide * 0.09,
            fillPaint,
          );
        }
      }
    case CellTexture.checkerboard:
      final halfW = rect.width / 2;
      final halfH = rect.height / 2;
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, halfW, halfH), fillPaint);
      canvas.drawRect(Rect.fromLTWH(rect.left + halfW, rect.top + halfH, halfW, halfH), fillPaint);
  }
  canvas.restore();
}

void _paintDiagonals(Canvas canvas, Rect rect, Paint paint, double step, {required bool reversed}) {
  for (var offset = -rect.height; offset < rect.width + rect.height; offset += step) {
    final x0 = rect.left + offset;
    final x1 = x0 + (reversed ? -rect.height : rect.height);
    canvas.drawLine(Offset(x0, rect.top), Offset(x1, rect.bottom), paint);
  }
}

/// Repaints [texture] onto a fixed-size surface — for the small piece
/// swatches (`NextQueueWidget`/`HoldWidget`) that don't otherwise need a
/// `CustomPainter`.
class CellTexturePainter extends CustomPainter {
  final CellTexture texture;

  const CellTexturePainter(this.texture);

  @override
  void paint(Canvas canvas, Size size) => paintCellTexture(canvas, Offset.zero & size, texture);

  @override
  bool shouldRepaint(covariant CellTexturePainter oldDelegate) => oldDelegate.texture != texture;
}
