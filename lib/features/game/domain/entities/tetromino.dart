import 'grid_position.dart';
import 'rotation_state.dart';
import 'tetromino_shapes.dart';
import 'tetromino_type.dart';

/// The currently active, falling piece: its type, rotation state, and the
/// board position of its bounding-box origin (top-left corner).
class Tetromino {
  final TetrominoType type;
  final RotationState rotation;
  final GridPosition origin;

  const Tetromino({
    required this.type,
    required this.rotation,
    required this.origin,
  });

  factory Tetromino.spawn(TetrominoType type) => Tetromino(
    type: type,
    rotation: RotationState.spawn,
    origin: TetrominoShapes.spawnOrigin(type),
  );

  Tetromino copyWith({RotationState? rotation, GridPosition? origin}) => Tetromino(
    type: type,
    rotation: rotation ?? this.rotation,
    origin: origin ?? this.origin,
  );

  List<GridPosition> get occupiedCells => TetrominoShapes.cellsFor(
    type,
    rotation,
  ).map((offset) => origin + offset).toList(growable: false);
}
