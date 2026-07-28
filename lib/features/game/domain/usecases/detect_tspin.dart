import '../entities/board.dart';
import '../entities/grid_position.dart';
import '../entities/rotation_state.dart';
import '../entities/t_spin_type.dart';
import '../entities/tetromino.dart';
import '../entities/tetromino_type.dart';

/// 3-corner T-Spin detection — spec.md section 8.7. Only ever called right
/// before a piece locks; the caller is responsible for knowing whether the
/// piece's last successful action was a rotation (translations never grant
/// a T-Spin, no matter how the piece ends up wedged).
abstract final class DetectTSpin {
  static TSpinType call({
    required Board board,
    required Tetromino piece,
    required bool wasLastActionRotation,
  }) {
    if (!wasLastActionRotation || piece.type != TetrominoType.t) {
      return TSpinType.none;
    }

    final corners = _cornersFor(
      piece.rotation,
    ).map((offset) => piece.origin + offset).toList(growable: false);

    bool isOccupied(GridPosition p) =>
        !board.isInsideBounds(p) || !board.isCellEmpty(p);

    final frontOccupied = corners
        .take(2)
        .where(isOccupied)
        .length;
    final backOccupied = corners
        .skip(2)
        .where(isOccupied)
        .length;

    if (frontOccupied + backOccupied < 3) return TSpinType.none;
    return frontOccupied == 2 ? TSpinType.full : TSpinType.mini;
  }

  /// Corners in [frontLeft, frontRight, backLeft, backRight] order, where
  /// "front" is the side the T piece's point faces after rotation.
  static List<GridPosition> _cornersFor(RotationState rotation) => switch (rotation) {
    RotationState.spawn => const [
      GridPosition(0, 0), GridPosition(0, 2), GridPosition(2, 0), GridPosition(2, 2),
    ],
    RotationState.right => const [
      GridPosition(0, 2), GridPosition(2, 2), GridPosition(0, 0), GridPosition(2, 0),
    ],
    RotationState.flip => const [
      GridPosition(2, 0), GridPosition(2, 2), GridPosition(0, 0), GridPosition(0, 2),
    ],
    RotationState.left => const [
      GridPosition(0, 0), GridPosition(2, 0), GridPosition(0, 2), GridPosition(2, 2),
    ],
  };
}
