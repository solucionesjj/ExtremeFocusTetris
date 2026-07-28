import 't_spin_type.dart';

/// Describes what a single piece lock produced, as input to scoring —
/// spec.md section 8.5.
class LineClearOutcome {
  final int linesCleared;
  final TSpinType tSpinType;
  final bool isPerfectClear;

  /// Board row indices that were cleared — lets the presentation layer
  /// emit line-clear particles/flash at the right place (spec.md section
  /// 18) without the domain knowing anything about rendering.
  final List<int> clearedRowIndices;

  const LineClearOutcome({
    required this.linesCleared,
    required this.tSpinType,
    required this.isPerfectClear,
    this.clearedRowIndices = const [],
  });

  /// A "difficult" clear (Tetris or any T-Spin that clears at least one
  /// line) is what keeps a Back-to-Back streak alive — spec.md section 8.5.
  bool get isDifficult =>
      linesCleared == 4 || (tSpinType != TSpinType.none && linesCleared > 0);
}
