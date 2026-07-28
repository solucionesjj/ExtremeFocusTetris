import 'dart:math';

import '../entities/game_state.dart';
import '../entities/game_status.dart';
import '../entities/grid_position.dart';
import 'calculate_score.dart';
import 'lock_active_piece.dart';

/// Instant drop to the lowest valid position, then locks immediately —
/// spec.md section 8.4.
abstract final class HardDrop {
  static GameState call(GameState state, Random random) {
    if (state.status == GameStatus.gameOver) return state;

    var piece = state.activePiece;
    var cellsTravelled = 0;
    while (true) {
      final candidate = piece.copyWith(
        origin: piece.origin + const GridPosition(1, 0),
      );
      if (!state.board.canPlace(candidate)) break;
      piece = candidate;
      cellsTravelled++;
    }

    final droppedState = state.copyWith(
      activePiece: piece,
      score: state.score + CalculateScore.hardDropPoints(cellsTravelled),
      lastActionWasRotation: false,
    );

    return LockActivePiece.call(droppedState, random);
  }
}
