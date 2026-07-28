import 'dart:math';

import 'package:extreme_focus_tetris/features/game/domain/entities/board.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/game_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/game_status.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/grid_position.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/rotation_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/game/domain/usecases/hard_drop.dart';
import 'package:flutter_test/flutter_test.dart';

GameState _emptyGameAt(Tetromino piece, {Board? board}) => GameState(
  board: board ?? Board.empty(),
  activePiece: piece,
  nextQueue: const [TetrominoType.o, TetrominoType.s, TetrominoType.z],
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
  test('drops straight to the floor, scores 2 points per cell, and spawns the next piece', () {
    final piece = const Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(0, 4));
    final state = _emptyGameAt(piece);
    final cellsToFloor = Board.totalRows - 2; // O piece is 2 rows tall

    final result = HardDrop.call(state, Random(1));

    expect(result.state.score, cellsToFloor * 2);
    expect(result.state.activePiece.type, TetrominoType.o); // next in queue
    expect(result.state.holdUsed, isFalse);
    expect(result.state.status, GameStatus.playing);
    expect(result.outcome.linesCleared, 0);
  });

  test('clearing a Single at level 1 awards 100 points and advances the line count', () {
    var board = Board.empty();
    // I-piece spawn cells sit at relative row 1, so origin row 20 fills
    // board row 21 only (row 20 stays untouched). Two segments cover
    // columns 0-3 and 6-9, leaving a 2-wide, all-the-way-down gap at
    // columns 4-5 for the falling O piece to complete the row.
    for (final col in [0, 6]) {
      board = board.lockPiece(
        Tetromino(type: TetrominoType.i, rotation: RotationState.spawn, origin: GridPosition(20, col)),
      );
    }
    final piece = const Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(0, 4));
    final state = _emptyGameAt(piece, board: board);

    final result = HardDrop.call(state, Random(1));

    // 100 (Single) + hard-drop travel points; travel is asserted loosely.
    expect(result.state.totalLinesCleared, 1);
    expect(result.state.combo, 0);
    expect(result.state.score, greaterThanOrEqualTo(100));
    expect(result.outcome.linesCleared, 1);
  });

  test('locking into a full spawn area ends the game', () {
    // A filler O piece placed exactly at the O spawn's own origin occupies
    // precisely the 4 cells the next O piece would need to spawn into.
    final board = Board.empty().lockPiece(Tetromino.spawn(TetrominoType.o));
    // Active piece sits well clear of the blocked spawn area; hard-dropping
    // it locks it in place, and the *next* piece (O) can no longer spawn.
    final piece = const Tetromino(type: TetrominoType.s, rotation: RotationState.spawn, origin: GridPosition(0, 6));
    final state = GameState(
      board: board,
      activePiece: piece,
      nextQueue: const [TetrominoType.o, TetrominoType.z, TetrominoType.i],
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

    final result = HardDrop.call(state, Random(1));

    expect(result.state.status, GameStatus.gameOver);
  });

  group('ghostPiece', () {
    test('reports the landing position without mutating the game state', () {
      final piece = const Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(0, 4));
      final state = _emptyGameAt(piece);

      final ghost = HardDrop.ghostPiece(state);

      expect(ghost.origin, const GridPosition(Board.totalRows - 2, 4));
      // The real active piece never moved.
      expect(state.activePiece.origin, piece.origin);
    });

    test('lands on top of existing stacked cells', () {
      var board = Board.empty();
      board = board.lockPiece(
        const Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(20, 4)),
      );
      final piece = const Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: GridPosition(0, 4));
      final state = _emptyGameAt(piece, board: board);

      final ghost = HardDrop.ghostPiece(state);

      expect(ghost.origin, const GridPosition(18, 4));
    });
  });
}
