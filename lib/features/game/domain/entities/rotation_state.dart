/// SRS rotation states — spec.md section 8.2. Named after the Tetris
/// Guideline notation (0, R, 2, L) used throughout the wall-kick tables.
enum RotationState {
  spawn,
  right,
  flip,
  left;

  RotationState get clockwise => switch (this) {
    RotationState.spawn => RotationState.right,
    RotationState.right => RotationState.flip,
    RotationState.flip => RotationState.left,
    RotationState.left => RotationState.spawn,
  };

  RotationState get counterClockwise => switch (this) {
    RotationState.spawn => RotationState.left,
    RotationState.left => RotationState.flip,
    RotationState.flip => RotationState.right,
    RotationState.right => RotationState.spawn,
  };
}
