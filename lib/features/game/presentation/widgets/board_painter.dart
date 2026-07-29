import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/grid_position.dart';
import '../../domain/entities/tetromino.dart';
import '../../domain/entities/tetromino_type.dart';
import '../../domain/usecases/hard_drop.dart';
import '../effects/particle.dart';
import 'board_geometry.dart';
import 'cell_texture.dart';
import 'tetromino_colors.dart';

/// Renders the 10x20 visible playfield in a single [Canvas] pass — spec.md
/// section 15: a widget-per-cell approach would rebuild ~200 widgets every
/// tick, which this avoids entirely.
class BoardPainter extends CustomPainter {
  final GameState gameState;
  final Color gridLineColor;
  final Color emptyCellColor;
  final bool showGhost;
  final bool focusMode;

  /// Colorblind-safe palette + per-piece texture overlay — spec.md section 14.
  final bool colorblindMode;

  /// Thicker block borders for the high-contrast theme — spec.md section 14.
  final bool highContrast;

  /// Cleared-row flash (spec.md section 18: "flash de color... shake
  /// horizontal leve"), in visible-row coordinates (0..19). [flashOpacity]
  /// is driven by the line-clear effect controller and fades to 0.
  final List<int> flashRows;
  final double flashOpacity;

  /// A snapshot of currently-alive particles — see `ParticlePool`. Reading
  /// this list is the only per-frame cost paid for particles when none are
  /// alive, since [ParticlePool.activeParticles] is empty then.
  final List<Particle> particles;

  BoardPainter({
    required this.gameState,
    required this.gridLineColor,
    required this.emptyCellColor,
    this.showGhost = true,
    this.focusMode = false,
    this.colorblindMode = false,
    this.highContrast = false,
    this.flashRows = const [],
    this.flashOpacity = 0,
    this.particles = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = BoardGeometry.of(size);
    final cellSize = geometry.cellSize;
    final offset = geometry.offset;

    _paintEmptyGrid(canvas, offset, cellSize);
    _paintLockedCells(canvas, offset, cellSize);
    if (showGhost) _paintGhost(canvas, offset, cellSize);
    _paintPiece(canvas, offset, cellSize, gameState.activePiece, opacity: 1);
    if (flashOpacity > 0) _paintFlashRows(canvas, offset, cellSize);
    if (particles.isNotEmpty) _paintParticles(canvas, cellSize);
  }

  void _paintFlashRows(Canvas canvas, Offset offset, double cellSize) {
    final paint = Paint()..color = AppColors.fxSpecialStart.withValues(alpha: flashOpacity * 0.6);
    for (final row in flashRows) {
      canvas.drawRect(
        Rect.fromLTWH(offset.dx, offset.dy + row * cellSize, cellSize * Board.columns, cellSize),
        paint,
      );
    }
  }

  void _paintParticles(Canvas canvas, double cellSize) {
    final radius = math.max(1.5, cellSize * 0.08);
    for (final particle in particles) {
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        radius,
        Paint()..color = AppColors.particles.withValues(alpha: particle.life.clamp(0, 1)),
      );
    }
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
        _paintCell(
          canvas,
          offset,
          cellSize,
          row - Board.hiddenRows,
          col,
          colorForTetromino(type, focusMode: focusMode, colorblindMode: colorblindMode),
          opacity: 1,
          type: type,
        );
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
    final color = colorForTetromino(piece.type, focusMode: focusMode, colorblindMode: colorblindMode);
    for (final cell in piece.occupiedCells) {
      if (cell.row < Board.hiddenRows) continue;
      _paintCell(
        canvas,
        offset,
        cellSize,
        cell.row - Board.hiddenRows,
        cell.col,
        color,
        opacity: opacity,
        type: piece.type,
      );
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
    TetrominoType? type,
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
      // Diagonal top-light highlight — spec.md 18 "brillo... look caramelo".
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0)],
          ).createShader(rect),
      );
      if (colorblindMode && type != null) {
        paintCellTexture(canvas, inset, textureForTetromino(type));
      }
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, cellSize * (highContrast ? 0.12 : 0.06)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) =>
      !identical(oldDelegate.gameState, gameState) ||
      oldDelegate.showGhost != showGhost ||
      oldDelegate.focusMode != focusMode ||
      oldDelegate.colorblindMode != colorblindMode ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.flashOpacity != flashOpacity ||
      !listEquals(oldDelegate.flashRows, flashRows) ||
      particles.isNotEmpty ||
      oldDelegate.particles.isNotEmpty;
}
