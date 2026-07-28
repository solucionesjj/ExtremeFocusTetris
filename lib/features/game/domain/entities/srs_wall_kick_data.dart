import 'grid_position.dart';
import 'rotation_state.dart';
import 'tetromino_type.dart';

/// SRS wall-kick offset tests — spec.md section 8.2. The spec's tables are
/// written in the Tetris Guideline's (x, y) convention where +y is *up*;
/// this board's [GridPosition] uses (row, col) with row increasing
/// *downward*, so every offset here is the spec value converted via
/// row = -y, col = x. Tests are tried in order; the first one that yields a
/// legal placement wins.
abstract final class SrsWallKickData {
  static const Map<(RotationState, RotationState), List<GridPosition>> _jlstz = {
    (RotationState.spawn, RotationState.right): [
      GridPosition(0, 0), GridPosition(0, -1), GridPosition(-1, -1), GridPosition(2, 0), GridPosition(2, -1),
    ],
    (RotationState.right, RotationState.spawn): [
      GridPosition(0, 0), GridPosition(0, 1), GridPosition(1, 1), GridPosition(-2, 0), GridPosition(-2, 1),
    ],
    (RotationState.right, RotationState.flip): [
      GridPosition(0, 0), GridPosition(0, 1), GridPosition(1, 1), GridPosition(-2, 0), GridPosition(-2, 1),
    ],
    (RotationState.flip, RotationState.right): [
      GridPosition(0, 0), GridPosition(0, -1), GridPosition(-1, -1), GridPosition(2, 0), GridPosition(2, -1),
    ],
    (RotationState.flip, RotationState.left): [
      GridPosition(0, 0), GridPosition(0, 1), GridPosition(-1, 1), GridPosition(2, 0), GridPosition(2, 1),
    ],
    (RotationState.left, RotationState.flip): [
      GridPosition(0, 0), GridPosition(0, -1), GridPosition(1, -1), GridPosition(-2, 0), GridPosition(-2, -1),
    ],
    (RotationState.left, RotationState.spawn): [
      GridPosition(0, 0), GridPosition(0, -1), GridPosition(1, -1), GridPosition(-2, 0), GridPosition(-2, -1),
    ],
    (RotationState.spawn, RotationState.left): [
      GridPosition(0, 0), GridPosition(0, 1), GridPosition(-1, 1), GridPosition(2, 0), GridPosition(2, 1),
    ],
  };

  static const Map<(RotationState, RotationState), List<GridPosition>> _i = {
    (RotationState.spawn, RotationState.right): [
      GridPosition(0, 0), GridPosition(0, -2), GridPosition(0, 1), GridPosition(1, -2), GridPosition(-2, 1),
    ],
    (RotationState.right, RotationState.spawn): [
      GridPosition(0, 0), GridPosition(0, 2), GridPosition(0, -1), GridPosition(-1, 2), GridPosition(2, -1),
    ],
    (RotationState.right, RotationState.flip): [
      GridPosition(0, 0), GridPosition(0, -1), GridPosition(0, 2), GridPosition(-2, -1), GridPosition(1, 2),
    ],
    (RotationState.flip, RotationState.right): [
      GridPosition(0, 0), GridPosition(0, 1), GridPosition(0, -2), GridPosition(2, 1), GridPosition(-1, -2),
    ],
    (RotationState.flip, RotationState.left): [
      GridPosition(0, 0), GridPosition(0, 2), GridPosition(0, -1), GridPosition(-1, 2), GridPosition(2, -1),
    ],
    (RotationState.left, RotationState.flip): [
      GridPosition(0, 0), GridPosition(0, -2), GridPosition(0, 1), GridPosition(1, -2), GridPosition(-2, 1),
    ],
    (RotationState.left, RotationState.spawn): [
      GridPosition(0, 0), GridPosition(0, 1), GridPosition(0, -2), GridPosition(2, 1), GridPosition(-1, -2),
    ],
    (RotationState.spawn, RotationState.left): [
      GridPosition(0, 0), GridPosition(0, -1), GridPosition(0, 2), GridPosition(-2, -1), GridPosition(1, 2),
    ],
  };

  static List<GridPosition> testsFor(
    TetrominoType type, {
    required RotationState from,
    required RotationState to,
  }) {
    final table = type == TetrominoType.i ? _i : _jlstz;
    return table[(from, to)] ?? const [GridPosition(0, 0)];
  }
}
