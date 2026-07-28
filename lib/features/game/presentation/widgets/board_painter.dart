import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/board.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/grid_position.dart';
import '../../domain/entities/tetromino.dart';
import '../../domain/usecases/hard_drop.dart';
import 'tetromino_colors.dart';

/// Renders the 10x20 visible playfield in a single [Canvas] pass — spec.md
/// section 15: a widget-per-cell approach would rebuild ~200 widgets every
/// tick, which this avoids entirely.
class BoardPainter extends CustomPainter {
  final GameState gameState;
  final Color gridLineColor;
  final Color emptyCellColor;
  final bool showGhost;

  BoardPainter({
    required this.gameState,
    required this.gridLineColor,
    required this.emptyCellColor,
    this.showGhost = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = math.min(
      size.width / Board.columns,
      size.height / Board.visibleRows,
    );
    final boardWidth = cellSize * Board.columns;
    final boardHeight = cellSize * Board.visibleRows;
    final offset = Offset(
      (size.width - boardWidth) / 2,
      (size.height - boardHeight) / 2,
    );

    _paintEmptyGrid(canvas, offset, cellSize);
    _paintLockedCells(canvas, offset, cellSize);
    if (showGhost) _paintGhost(canvas, offset, cellSize);
    _paintPiece(canvas, offset, cellSize, gameState.activePiece, opacity: 1);
  }

  void _paintEmptyGrid(Canvas canvas, Offset offset, double cellSize) {
    final backgroundPaint = Paint()..color = emptyCellColor;
    final linePaint = Paint()
      ..color = gridLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final boardRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      cellSize * Board.columns,
      cellSize * Board.visibleRows,
    );
    canvas.drawRect(boardRect, backgroundPaint);

    for (var col = 0; col <= Board.columns; col++) {
      final x = offset.dx + col * cellSize;
      canvas.drawLine(Offset(x, offset.dy), Offset(x, offset.dy + boardRect.height), linePaint);
    }
    for (var row = 0; row <= Board.visibleRows; row++) {
      final y = offset.dy + row * cellSize;
      canvas.drawLine(Offset(offset.dx, y), Offset(offset.dx + boardRect.width, y), linePaint);
    }
  }

  void _paintLockedCells(Canvas canvas, Offset offset, double cellSize) {
    for (var row = Board.hiddenRows; row < Board.totalRows; row++) {
      for (var col = 0; col < Board.columns; col++) {
        final type = gameState.board.cellAt(GridPosition(row, col));
        if (type == null) continue;
        _paintCell(canvas, offset, cellSize, row - Board.hiddenRows, col, colorForTetromino(type), opacity: 1);
      }
    }
  }

  void _paintGhost(Canvas canvas, Offset offset, double cellSize) {
    final ghost = HardDrop.ghostPiece(gameState);
    if (ghost.origin == gameState.activePiece.origin) return;
    _paintPiece(canvas, offset, cellSize, ghost, opacity: 0.25);
  }

  void _paintPiece(
    Canvas canvas,
    Offset offset,
    double cellSize,
    Tetromino piece, {
    required double opacity,
  }) {
    final color = colorForTetromino(piece.type);
    for (final cell in piece.occupiedCells) {
      if (cell.row < Board.hiddenRows) continue;
      _paintCell(canvas, offset, cellSize, cell.row - Board.hiddenRows, cell.col, color, opacity: opacity);
    }
  }

  void _paintCell(
    Canvas canvas,
    Offset offset,
    double cellSize,
    int visibleRow,
    int col,
    Color color, {
    required double opacity,
  }) {
    final rect = Rect.fromLTWH(
      offset.dx + col * cellSize,
      offset.dy + visibleRow * cellSize,
      cellSize,
      cellSize,
    );
    final inset = rect.deflate(cellSize * 0.04);
    final rrect = RRect.fromRectAndRadius(inset, Radius.circular(cellSize * 0.12));

    canvas.drawRRect(rrect, Paint()..color = color.withValues(alpha: opacity));
    if (opacity == 1) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, cellSize * 0.06),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) =>
      !identical(oldDelegate.gameState, gameState) || oldDelegate.showGhost != showGhost;
}
