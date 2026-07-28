import 't_spin_type.dart';

/// Describes what a single piece lock produced, as input to scoring —
/// spec.md section 8.5.
class LineClearOutcome {
  final int linesCleared;
  final TSpinType tSpinType;
  final bool isPerfectClear;

  const LineClearOutcome({
    required this.linesCleared,
    required this.tSpinType,
    required this.isPerfectClear,
  });

  /// A "difficult" clear (Tetris or any T-Spin that clears at least one
  /// line) is what keeps a Back-to-Back streak alive — spec.md section 8.5.
  bool get isDifficult =>
      linesCleared == 4 || (tSpinType != TSpinType.none && linesCleared > 0);
}
