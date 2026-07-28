/// A single line-clear occurrence, for the presentation layer to react to
/// (particles, flash, shake, glow — spec.md section 18). [sequence] is
/// strictly increasing so `ref.listen` can tell two clears with the same
/// row indices apart.
class LineClearEvent {
  final List<int> clearedRowIndices;
  final int linesCleared;
  final int sequence;

  const LineClearEvent({
    required this.clearedRowIndices,
    required this.linesCleared,
    required this.sequence,
  });
}
