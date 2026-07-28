import 'dart:math';

import '../entities/board.dart';
import '../entities/game_state.dart';
import '../entities/game_status.dart';
import '../entities/grid_position.dart';
import '../entities/line_clear_outcome.dart';
import '../entities/t_spin_type.dart';
import '../entities/tetromino.dart';
import 'calculate_score.dart';
import 'lock_active_piece.dart';

/// Instant drop to the lowest valid position, then locks immediately —
/// spec.md section 8.4.
abstract final class HardDrop {
  static LockResult call(GameState state, Random random) {
    if (state.status == GameStatus.gameOver) {
      return (
        state: state,
        outcome: const LineClearOutcome(
          linesCleared: 0,
          tSpinType: TSpinType.none,
          isPerfectClear: false,
        ),
      );
    }

    final landing = _lowestValidPosition(state.board, state.activePiece);
    final cellsTravelled = landing.origin.row - state.activePiece.origin.row;

    final droppedState = state.copyWith(
      activePiece: landing,
      score: state.score + CalculateScore.hardDropPoints(cellsTravelled),
      lastActionWasRotation: false,
    );

    return LockActivePiece.call(droppedState, random);
  }

  /// The silhouette position the active piece would land on right now,
  /// without mutating any state — used to render the ghost piece.
  static Tetromino ghostPiece(GameState state) =>
      _lowestValidPosition(state.board, state.activePiece);

  static Tetromino _lowestValidPosition(Board board, Tetromino piece) {
    var current = piece;
    while (true) {
      final candidate = current.copyWith(
        origin: current.origin + const GridPosition(1, 0),
      );
      if (!board.canPlace(candidate)) return current;
      current = candidate;
    }
  }
}
