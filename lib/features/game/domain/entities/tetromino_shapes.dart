import 'grid_position.dart';
import 'rotation_state.dart';
import 'tetromino_type.dart';

/// Standard SRS shape data: occupied cells per (type, rotation) relative to
/// the piece's bounding-box origin (top-left corner), and the spawn origin
/// on a 10-column board. Bounding boxes: I = 4x4, O = 2x2, T/S/Z/J/L = 3x3.
abstract final class TetrominoShapes {
  static const Map<TetrominoType, Map<RotationState, List<GridPosition>>> _cells = {
    TetrominoType.i: {
      RotationState.spawn: [GridPosition(1, 0), GridPosition(1, 1), GridPosition(1, 2), GridPosition(1, 3)],
      RotationState.right: [GridPosition(0, 2), GridPosition(1, 2), GridPosition(2, 2), GridPosition(3, 2)],
      RotationState.flip: [GridPosition(2, 0), GridPosition(2, 1), GridPosition(2, 2), GridPosition(2, 3)],
      RotationState.left: [GridPosition(0, 1), GridPosition(1, 1), GridPosition(2, 1), GridPosition(3, 1)],
    },
    TetrominoType.o: {
      RotationState.spawn: [GridPosition(0, 0), GridPosition(0, 1), GridPosition(1, 0), GridPosition(1, 1)],
      RotationState.right: [GridPosition(0, 0), GridPosition(0, 1), GridPosition(1, 0), GridPosition(1, 1)],
      RotationState.flip: [GridPosition(0, 0), GridPosition(0, 1), GridPosition(1, 0), GridPosition(1, 1)],
      RotationState.left: [GridPosition(0, 0), GridPosition(0, 1), GridPosition(1, 0), GridPosition(1, 1)],
    },
    TetrominoType.t: {
      RotationState.spawn: [GridPosition(0, 1), GridPosition(1, 0), GridPosition(1, 1), GridPosition(1, 2)],
      RotationState.right: [GridPosition(0, 1), GridPosition(1, 1), GridPosition(1, 2), GridPosition(2, 1)],
      RotationState.flip: [GridPosition(1, 0), GridPosition(1, 1), GridPosition(1, 2), GridPosition(2, 1)],
      RotationState.left: [GridPosition(0, 1), GridPosition(1, 0), GridPosition(1, 1), GridPosition(2, 1)],
    },
    TetrominoType.s: {
      RotationState.spawn: [GridPosition(0, 1), GridPosition(0, 2), GridPosition(1, 0), GridPosition(1, 1)],
      RotationState.right: [GridPosition(0, 1), GridPosition(1, 1), GridPosition(1, 2), GridPosition(2, 2)],
      RotationState.flip: [GridPosition(1, 1), GridPosition(1, 2), GridPosition(2, 0), GridPosition(2, 1)],
      RotationState.left: [GridPosition(0, 0), GridPosition(1, 0), GridPosition(1, 1), GridPosition(2, 1)],
    },
    TetrominoType.z: {
      RotationState.spawn: [GridPosition(0, 0), GridPosition(0, 1), GridPosition(1, 1), GridPosition(1, 2)],
      RotationState.right: [GridPosition(0, 2), GridPosition(1, 1), GridPosition(1, 2), GridPosition(2, 1)],
      RotationState.flip: [GridPosition(1, 0), GridPosition(1, 1), GridPosition(2, 1), GridPosition(2, 2)],
      RotationState.left: [GridPosition(0, 1), GridPosition(1, 0), GridPosition(1, 1), GridPosition(2, 0)],
    },
    TetrominoType.j: {
      RotationState.spawn: [GridPosition(0, 0), GridPosition(1, 0), GridPosition(1, 1), GridPosition(1, 2)],
      RotationState.right: [GridPosition(0, 1), GridPosition(0, 2), GridPosition(1, 1), GridPosition(2, 1)],
      RotationState.flip: [GridPosition(1, 0), GridPosition(1, 1), GridPosition(1, 2), GridPosition(2, 2)],
      RotationState.left: [GridPosition(0, 1), GridPosition(1, 1), GridPosition(2, 0), GridPosition(2, 1)],
    },
    TetrominoType.l: {
      RotationState.spawn: [GridPosition(0, 2), GridPosition(1, 0), GridPosition(1, 1), GridPosition(1, 2)],
      RotationState.right: [GridPosition(0, 1), GridPosition(1, 1), GridPosition(2, 1), GridPosition(2, 2)],
      RotationState.flip: [GridPosition(1, 0), GridPosition(1, 1), GridPosition(1, 2), GridPosition(2, 0)],
      RotationState.left: [GridPosition(0, 0), GridPosition(0, 1), GridPosition(1, 1), GridPosition(2, 1)],
    },
  };

  static List<GridPosition> cellsFor(TetrominoType type, RotationState rotation) =>
      _cells[type]![rotation]!;

  /// Spawn origin (top-left of the bounding box) centered on a 10-column
  /// board, row 0 so every piece's populated cells stay within the 2 hidden
  /// spawn rows until gravity moves them into the visible field.
  static GridPosition spawnOrigin(TetrominoType type) => switch (type) {
    TetrominoType.i => const GridPosition(0, 3),
    TetrominoType.o => const GridPosition(0, 4),
    _ => const GridPosition(0, 3),
  };
}
