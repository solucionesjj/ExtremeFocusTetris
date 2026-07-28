import 'dart:math';

import '../entities/board.dart';
import '../entities/game_state.dart';
import '../entities/game_status.dart';
import '../entities/seven_bag_generator.dart';
import '../entities/tetromino.dart';

/// Builds the initial [GameState] for a fresh game — empty board, first
/// piece spawned, and a full lookahead queue.
abstract final class StartNewGame {
  static GameState call(Random random) {
    final queue = SevenBagGenerator.ensureLookahead(const [], random);
    final firstType = queue.first;
    final remainingQueue = SevenBagGenerator.ensureLookahead(
      queue.skip(1).toList(),
      random,
    );

    return GameState(
      board: Board.empty(),
      activePiece: Tetromino.spawn(firstType),
      nextQueue: remainingQueue,
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
  }
}
