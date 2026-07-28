import 'package:extreme_focus_tetris/features/game/domain/entities/board.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/grid_position.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/rotation_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Board dimensions', () {
    test('is 10 columns by 22 total rows (20 visible + 2 hidden)', () {
      expect(Board.columns, 10);
      expect(Board.visibleRows, 20);
      expect(Board.hiddenRows, 2);
      expect(Board.totalRows, 22);
    });

    test('a fresh board is empty', () {
      expect(Board.empty().isEmpty, isTrue);
    });
  });

  group('serialization', () {
    test('toCellList/fromCellList round-trips a board exactly', () {
      final board = Board.empty().lockPiece(
        const Tetromino(type: TetrominoType.t, rotation: RotationState.spawn, origin: GridPosition(5, 3)),
      );

      final restored = Board.fromCellList(board.toCellList());

      expect(restored.cellAt(const GridPosition(6, 4)), TetrominoType.t);
      expect(restored.toCellList(), board.toCellList());
    });
  });

  group('canPlace', () {
    test('rejects a piece that would go out of the left bound', () {
      final board = Board.empty();
      final piece = const Tetromino(
        type: TetrominoType.o,
        rotation: RotationState.spawn,
        origin: GridPosition(0, -1),
      );
      expect(board.canPlace(piece), isFalse);
    });

    test('rejects a piece that would go out of the right bound', () {
      final board = Board.empty();
      final piece = const Tetromino(
        type: TetrominoType.o,
        rotation: RotationState.spawn,
        origin: GridPosition(0, 9),
      );
      expect(board.canPlace(piece), isFalse);
    });

    test('rejects a piece overlapping an occupied cell', () {
      final board = Board.empty().lockPiece(
        const Tetromino(
          type: TetrominoType.o,
          rotation: RotationState.spawn,
          origin: GridPosition(5, 4),
        ),
      );
      final overlapping = const Tetromino(
        type: TetrominoType.o,
        rotation: RotationState.spawn,
        origin: GridPosition(5, 4),
      );
      expect(board.canPlace(overlapping), isFalse);
    });

    test('accepts a piece fully inside empty bounds', () {
      final board = Board.empty();
      final piece = const Tetromino(
        type: TetrominoType.o,
        rotation: RotationState.spawn,
        origin: GridPosition(0, 4),
      );
      expect(board.canPlace(piece), isTrue);
    });
  });

  group('clearFullLines', () {
    test('does nothing when no row is full', () {
      final board = Board.empty().lockPiece(
        const Tetromino(
          type: TetrominoType.o,
          rotation: RotationState.spawn,
          origin: GridPosition(20, 4),
        ),
      );
      final result = board.clearFullLines();
      expect(result.clearedRows, isEmpty);
    });

    test('cells keep their type when no line is cleared', () {
      final board = Board.empty().lockPiece(
        const Tetromino(
          type: TetrominoType.t,
          rotation: RotationState.spawn,
          origin: GridPosition(5, 3),
        ),
      );
      final result = board.clearFullLines();
      expect(result.clearedRows, isEmpty);
      // T spawn shape occupies (0,1),(1,0),(1,1),(1,2) relative to origin.
      expect(result.board.cellAt(const GridPosition(6, 4)), TetrominoType.t);
    });

    test('removes every full row and the resulting board is empty', () {
      var board = Board.empty();
      // Five 2x2 O pieces side by side span all 10 columns across both
      // row 20 and row 21, completing them simultaneously.
      for (var col = 0; col < Board.columns; col += 2) {
        board = board.lockPiece(
          Tetromino(
            type: TetrominoType.o,
            rotation: RotationState.spawn,
            origin: GridPosition(20, col),
          ),
        );
      }

      final result = board.clearFullLines();

      expect(result.clearedRows, [20, 21]);
      expect(result.board.isEmpty, isTrue);
    });

    test('rows above a cleared row shift down by the number cleared', () {
      var board = Board.empty();
      // I-piece spawn cells sit at relative row 1, so origin row 20 places
      // a horizontal 4-cell segment on board row 21 only (row 20 stays
      // untouched). Three overlapping segments cover all 10 columns.
      for (final col in [0, 4, 6]) {
        board = board.lockPiece(
          Tetromino(
            type: TetrominoType.i,
            rotation: RotationState.spawn,
            origin: GridPosition(20, col),
          ),
        );
      }

      // Marker piece sitting two rows above the row that's about to clear.
      board = board.lockPiece(
        const Tetromino(
          type: TetrominoType.j,
          rotation: RotationState.spawn,
          origin: GridPosition(18, 4),
        ),
      );

      final result = board.clearFullLines();

      expect(result.clearedRows, [21]);
      // The marker's cells (row 18 col 4; row 19 cols 4,5,6) must each
      // shift down by exactly one row.
      expect(result.board.cellAt(const GridPosition(19, 4)), TetrominoType.j);
      expect(result.board.cellAt(const GridPosition(20, 4)), TetrominoType.j);
      expect(result.board.cellAt(const GridPosition(20, 5)), TetrominoType.j);
      expect(result.board.cellAt(const GridPosition(20, 6)), TetrominoType.j);
    });
  });
}
