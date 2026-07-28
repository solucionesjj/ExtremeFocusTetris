import 'board.dart';
import 'game_status.dart';
import 'tetromino.dart';
import 'tetromino_type.dart';

/// The full, immutable snapshot of an in-progress (or finished) game.
class GameState {
  final Board board;
  final Tetromino activePiece;
  final List<TetrominoType> nextQueue;
  final TetrominoType? holdPiece;
  final bool holdUsed;
  final int score;
  final int level;
  final int totalLinesCleared;

  /// -1 means "no active combo"; each consecutive clearing lock increments
  /// it, any non-clearing lock resets it — spec.md section 8.5.
  final int combo;
  final bool backToBack;
  final GameStatus status;
  final bool lastActionWasRotation;

  /// How many times the lock-delay timer has been reset for the current
  /// piece while grounded, capped at 15 — spec.md section 8.4. The actual
  /// timer lives in the Phase 2 presentation ticker; this is the pure,
  /// testable budget it must respect.
  final int lockResetCount;

  const GameState({
    required this.board,
    required this.activePiece,
    required this.nextQueue,
    required this.holdPiece,
    required this.holdUsed,
    required this.score,
    required this.level,
    required this.totalLinesCleared,
    required this.combo,
    required this.backToBack,
    required this.status,
    required this.lastActionWasRotation,
    required this.lockResetCount,
  });

  static const int maxLockResets = 15;

  GameState copyWith({
    Board? board,
    Tetromino? activePiece,
    List<TetrominoType>? nextQueue,
    TetrominoType? holdPiece,
    bool? holdUsed,
    int? score,
    int? level,
    int? totalLinesCleared,
    int? combo,
    bool? backToBack,
    GameStatus? status,
    bool? lastActionWasRotation,
    int? lockResetCount,
  }) => GameState(
    board: board ?? this.board,
    activePiece: activePiece ?? this.activePiece,
    nextQueue: nextQueue ?? this.nextQueue,
    holdPiece: holdPiece ?? this.holdPiece,
    holdUsed: holdUsed ?? this.holdUsed,
    score: score ?? this.score,
    level: level ?? this.level,
    totalLinesCleared: totalLinesCleared ?? this.totalLinesCleared,
    combo: combo ?? this.combo,
    backToBack: backToBack ?? this.backToBack,
    status: status ?? this.status,
    lastActionWasRotation: lastActionWasRotation ?? this.lastActionWasRotation,
    lockResetCount: lockResetCount ?? this.lockResetCount,
  );
}
