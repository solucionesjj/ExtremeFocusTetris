import 'package:extreme_focus_tetris/features/game/domain/entities/board.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/game_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/game_status.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/grid_position.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/rotation_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/game/domain/usecases/move_piece.dart';
import 'package:flutter_test/flutter_test.dart';

GameState _stateWith(Tetromino piece, {Board? board, int lockResetCount = 0}) => GameState(
  board: board ?? Board.empty(),
  activePiece: piece,
  nextQueue: const [TetrominoType.i, TetrominoType.o, TetrominoType.s],
  holdPiece: null,
  holdUsed: false,
  score: 0,
  level: 1,
  totalLinesCleared: 0,
  combo: -1,
  backToBack: false,
  status: GameStatus.playing,
  lastActionWasRotation: false,
  lockResetCount: lockResetCount,
);

void main() {
  group('left / right', () {
    test('moves one column when the destination is free', () {
      final piece = const Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(0, 4));
      final state = _stateWith(piece);

      final moved = MovePiece.right(state);

      expect(moved.activePiece.origin, const GridPosition(0, 5));
    });

    test('is a no-op against the left wall', () {
      final piece = const Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(0, 0));
      final state = _stateWith(piece);

      final moved = MovePiece.left(state);

      expect(moved.activePiece.origin, piece.origin);
    });
  });

  group('softDrop', () {
    test('moves down one row and awards 1 point when the cell below is free', () {
      final piece = const Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(0, 4));
      final state = _stateWith(piece);

      final moved = MovePiece.softDrop(state);

      expect(moved.activePiece.origin, const GridPosition(1, 4));
      expect(moved.score, 1);
    });

    test('is a scoreless no-op once the piece is resting on the floor', () {
      final piece = const Tetromino(
        type: TetrominoType.o,
        rotation: RotationState.spawn,
        origin: GridPosition(Board.totalRows - 2, 4),
      );
      final state = _stateWith(piece);

      final moved = MovePiece.softDrop(state);

      expect(moved.activePiece.origin, piece.origin);
      expect(moved.score, 0);
    });
  });

  group('gravityStep', () {
    test('moves down one row and never awards points, unlike softDrop', () {
      final piece = const Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(0, 4));
      final state = _stateWith(piece);

      final moved = MovePiece.gravityStep(state);

      expect(moved.activePiece.origin, const GridPosition(1, 4));
      expect(moved.score, 0);
    });

    test('is a no-op once the piece is resting on the floor', () {
      final piece = const Tetromino(
        type: TetrominoType.o,
        rotation: RotationState.spawn,
        origin: GridPosition(Board.totalRows - 2, 4),
      );
      final state = _stateWith(piece);

      final moved = MovePiece.gravityStep(state);

      expect(moved.activePiece.origin, piece.origin);
    });
  });

  group('canMoveDown', () {
    test('is false when resting on the floor', () {
      final piece = const Tetromino(
        type: TetrominoType.o,
        rotation: RotationState.spawn,
        origin: GridPosition(Board.totalRows - 2, 4),
      );
      expect(MovePiece.canMoveDown(_stateWith(piece)), isFalse);
    });

    test('is true with open space below', () {
      final piece = const Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(0, 4));
      expect(MovePiece.canMoveDown(_stateWith(piece)), isTrue);
    });
  });

  group('lock-delay reset budget', () {
    test('a grounded lateral move increments the reset counter', () {
      final piece = const Tetromino(
        type: TetrominoType.o,
        rotation: RotationState.spawn,
        origin: GridPosition(Board.totalRows - 2, 4),
      );
      final state = _stateWith(piece);

      final moved = MovePiece.right(state);

      expect(moved.lockResetCount, 1);
    });

    test('the reset counter never exceeds the 15-reset cap', () {
      final piece = const Tetromino(
        type: TetrominoType.o,
        rotation: RotationState.spawn,
        origin: GridPosition(Board.totalRows - 2, 4),
      );
      final state = _stateWith(piece, lockResetCount: GameState.maxLockResets);

      final moved = MovePiece.left(state);

      expect(moved.lockResetCount, GameState.maxLockResets);
    });

    test('a mid-air move does not consume the reset budget', () {
      final piece = const Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(0, 4));
      final state = _stateWith(piece);

      final moved = MovePiece.right(state);

      expect(moved.lockResetCount, 0);
    });
  });
}
