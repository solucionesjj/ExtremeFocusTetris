import '../entities/game_state.dart';
import '../entities/game_status.dart';
import '../entities/srs_wall_kick_data.dart';
import '../entities/tetromino_type.dart';
import 'move_piece.dart';

/// SRS rotation with wall-kick resolution — spec.md section 8.2.
abstract final class RotatePiece {
  static GameState clockwise(GameState state) => _rotate(state, clockwise: true);

  static GameState counterClockwise(GameState state) =>
      _rotate(state, clockwise: false);

  static GameState _rotate(GameState state, {required bool clockwise}) {
    if (state.status == GameStatus.gameOver) return state;

    final piece = state.activePiece;
    if (piece.type == TetrominoType.o) return state;

    final targetRotation = clockwise
        ? piece.rotation.clockwise
        : piece.rotation.counterClockwise;
    final tests = SrsWallKickData.testsFor(
      piece.type,
      from: piece.rotation,
      to: targetRotation,
    );

    for (final kick in tests) {
      final candidate = piece.copyWith(
        rotation: targetRotation,
        origin: piece.origin + kick,
      );
      if (state.board.canPlace(candidate)) {
        final wasGrounded = !MovePiece.canMoveDown(state);
        final canStillReset =
            wasGrounded && state.lockResetCount < GameState.maxLockResets;

        return state.copyWith(
          activePiece: candidate,
          lastActionWasRotation: true,
          lockResetCount: canStillReset ? state.lockResetCount + 1 : state.lockResetCount,
        );
      }
    }

    return state;
  }
}
