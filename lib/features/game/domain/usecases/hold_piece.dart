import 'dart:math';

import '../entities/game_state.dart';
import '../entities/game_status.dart';
import '../entities/seven_bag_generator.dart';
import '../entities/tetromino.dart';
import '../entities/tetromino_type.dart';

/// Hold/swap the active piece — spec.md section 8.4. Locked to one use per
/// piece via [GameState.holdUsed], which [LockActivePiece] resets whenever
/// a new piece spawns.
abstract final class HoldPiece {
  static GameState call(GameState state, Random random) {
    if (state.status == GameStatus.gameOver || state.holdUsed) return state;

    if (state.holdPiece == null) {
      final refilledQueue = SevenBagGenerator.ensureLookahead(state.nextQueue, random);
      final nextType = refilledQueue.first;
      final remainingQueue = SevenBagGenerator.ensureLookahead(
        refilledQueue.skip(1).toList(),
        random,
      );
      return _swap(state, incomingType: nextType, updatedQueue: remainingQueue);
    }

    return _swap(state, incomingType: state.holdPiece!, updatedQueue: state.nextQueue);
  }

  static GameState _swap(
    GameState state, {
    required TetrominoType incomingType,
    required List<TetrominoType> updatedQueue,
  }) {
    final spawned = Tetromino.spawn(incomingType);
    final canSpawn = state.board.canPlace(spawned);

    return state.copyWith(
      holdPiece: state.activePiece.type,
      activePiece: spawned,
      nextQueue: updatedQueue,
      holdUsed: true,
      lastActionWasRotation: false,
      lockResetCount: 0,
      status: canSpawn ? state.status : GameStatus.gameOver,
    );
  }
}
