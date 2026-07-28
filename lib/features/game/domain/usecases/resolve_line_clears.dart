import '../entities/board.dart';

/// Detects and removes full rows — spec.md section 8.1. A thin, named
/// wrapper around [Board.clearFullLines] so the operation reads as its own
/// step in the lock → resolve → spawn pipeline ([LockActivePiece]).
abstract final class ResolveLineClears {
  static ({Board board, List<int> clearedRows}) call(Board board) =>
      board.clearFullLines();
}
