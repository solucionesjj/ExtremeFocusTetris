import 'package:extreme_focus_tetris/features/game/domain/entities/board.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/game_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/game_status.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/grid_position.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/rotation_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/game/domain/usecases/rotate_piece.dart';
import 'package:flutter_test/flutter_test.dart';

GameState _stateWith(Tetromino piece, {Board? board}) => GameState(
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
  lockResetCount: 0,
);

void main() {
  test('the O piece never rotates', () {
    final piece = const Tetromino(
      type: TetrominoType.o,
      rotation: RotationState.spawn,
      origin: GridPosition(5, 4),
    );
    final state = _stateWith(piece);

    final rotated = RotatePiece.clockwise(state);

    expect(rotated.activePiece.rotation, RotationState.spawn);
    expect(rotated.activePiece.origin, piece.origin);
  });

  test('a T piece rotates freely with no kick needed in open space', () {
    final piece = const Tetromino(
      type: TetrominoType.t,
      rotation: RotationState.spawn,
      origin: GridPosition(5, 4),
    );
    final state = _stateWith(piece);

    final rotated = RotatePiece.clockwise(state);

    expect(rotated.activePiece.rotation, RotationState.right);
    expect(rotated.lastActionWasRotation, isTrue);
  });

  test('four clockwise rotations return the piece to spawn', () {
    final piece = const Tetromino(
      type: TetrominoType.t,
      rotation: RotationState.spawn,
      origin: GridPosition(5, 4),
    );
    var state = _stateWith(piece);

    for (var i = 0; i < 4; i++) {
      state = RotatePiece.clockwise(state);
    }

    expect(state.activePiece.rotation, RotationState.spawn);
  });

  test('an I piece flush against the left wall applies a wall kick', () {
    // Vertical I piece (rotation `right`) occupies only relative column 2
    // of its 4-wide box, so origin col -2 is a legal position with its
    // single occupied column sitting exactly at board column 0. Rotating
    // back to `spawn` (a horizontal 4-cell row) at that same origin would
    // reach columns -2..1 — illegal — so the SRS table's second test
    // (which shifts the origin right by 2) must be the one that succeeds.
    final piece = const Tetromino(
      type: TetrominoType.i,
      rotation: RotationState.right,
      origin: GridPosition(5, -2),
    );
    expect(piece.occupiedCells.every((c) => c.col == 0), isTrue);
    final state = _stateWith(piece);

    final rotated = RotatePiece.counterClockwise(state);

    expect(rotated.activePiece.rotation, RotationState.spawn);
    expect(rotated.activePiece.origin, const GridPosition(5, 0));
    for (final cell in rotated.activePiece.occupiedCells) {
      expect(cell.col, greaterThanOrEqualTo(0));
      expect(cell.col, lessThan(Board.columns));
    }
  });

  test('rotation fails and the state is unchanged when every cell is occupied', () {
    // A solid board leaves no legal spot for any of the 5 SRS kick tests,
    // so this is an unambiguous way to force rotation to fail.
    var board = Board.empty();
    for (var row = 0; row < Board.totalRows; row += 2) {
      for (var col = 0; col < Board.columns; col += 2) {
        board = board.lockPiece(
          Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(row, col)),
        );
      }
    }
    final piece = const Tetromino(
      type: TetrominoType.t,
      rotation: RotationState.spawn,
      origin: GridPosition(10, 4),
    );
    final state = _stateWith(piece, board: board);

    final rotated = RotatePiece.clockwise(state);

    expect(rotated.activePiece.rotation, RotationState.spawn);
    expect(rotated.activePiece.origin, piece.origin);
    expect(rotated.lastActionWasRotation, isFalse);
  });
}
