import 'dart:math';

import 'package:extreme_focus_tetris/features/game/domain/entities/board.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/game_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/game_status.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/grid_position.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/rotation_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/game/domain/usecases/hold_piece.dart';
import 'package:flutter_test/flutter_test.dart';

GameState _stateWith({
  TetrominoType active = TetrominoType.t,
  TetrominoType? hold,
  bool holdUsed = false,
  List<TetrominoType> queue = const [TetrominoType.i, TetrominoType.s, TetrominoType.z],
}) => GameState(
  board: Board.empty(),
  activePiece: Tetromino.spawn(active),
  nextQueue: queue,
  holdPiece: hold,
  holdUsed: holdUsed,
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
  test('holding for the first time stores the active piece and pulls the next one', () {
    final state = _stateWith(active: TetrominoType.t, hold: null);

    final result = HoldPiece.call(state, Random(1));

    expect(result.holdPiece, TetrominoType.t);
    expect(result.activePiece.type, TetrominoType.i);
    expect(result.holdUsed, isTrue);
  });

  test('holding a second time before locking is a no-op', () {
    final state = _stateWith(active: TetrominoType.i, hold: TetrominoType.t, holdUsed: true);

    final result = HoldPiece.call(state, Random(1));

    expect(result.activePiece.type, TetrominoType.i);
    expect(result.holdPiece, TetrominoType.t);
  });

  test('holding when a piece is already stored swaps the two', () {
    final state = _stateWith(active: TetrominoType.s, hold: TetrominoType.l, holdUsed: false);

    final result = HoldPiece.call(state, Random(1));

    expect(result.holdPiece, TetrominoType.s);
    expect(result.activePiece.type, TetrominoType.l);
    expect(result.holdUsed, isTrue);
  });

  test('a hold that cannot spawn on a blocked board ends the game', () {
    var board = Board.empty();
    // Occupy every spawn cell of the L piece (spawn shape at origin (0,3)).
    for (final cell in Tetromino.spawn(TetrominoType.l).occupiedCells) {
      board = board.lockPiece(
        Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(cell.row, cell.col)),
      );
    }
    final state = GameState(
      board: board,
      activePiece: Tetromino.spawn(TetrominoType.s),
      nextQueue: const [TetrominoType.l],
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

    final result = HoldPiece.call(state, Random(1));

    expect(result.status, GameStatus.gameOver);
  });
}
