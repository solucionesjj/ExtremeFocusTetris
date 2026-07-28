import '../entities/game_state.dart';
import '../entities/game_status.dart';
import '../entities/grid_position.dart';
import 'calculate_score.dart';

/// Lateral movement and soft drop — spec.md section 8.4.
abstract final class MovePiece {
  static GameState left(GameState state) =>
      _translate(state, const GridPosition(0, -1));

  static GameState right(GameState state) =>
      _translate(state, const GridPosition(0, 1));

  /// A player-initiated downward step. Awards 1 point per cell actually
  /// travelled; a no-op (piece already grounded) awards nothing.
  static GameState softDrop(GameState state) {
    final moved = _translate(state, const GridPosition(1, 0));
    if (identical(moved, state)) return state;
    return moved.copyWith(score: moved.score + CalculateScore.softDropPoints(1));
  }

  /// The automatic, ticker-driven downward step — unlike [softDrop], this
  /// never awards points (only a player-initiated soft drop scores).
  static GameState gravityStep(GameState state) =>
      _translate(state, const GridPosition(1, 0));

  static bool canMoveDown(GameState state) {
    final candidate = state.activePiece.copyWith(
      origin: state.activePiece.origin + const GridPosition(1, 0),
    );
    return state.board.canPlace(candidate);
  }

  static GameState _translate(GameState state, GridPosition delta) {
    if (state.status == GameStatus.gameOver) return state;

    final candidate = state.activePiece.copyWith(
      origin: state.activePiece.origin + delta,
    );
    if (!state.board.canPlace(candidate)) return state;

    final wasGrounded = !canMoveDown(state);
    final canStillReset = wasGrounded && state.lockResetCount < GameState.maxLockResets;

    return state.copyWith(
      activePiece: candidate,
      lastActionWasRotation: false,
      lockResetCount: canStillReset ? state.lockResetCount + 1 : state.lockResetCount,
    );
  }
}
