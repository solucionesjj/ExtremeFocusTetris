import 'dart:math';

import '../entities/game_state.dart';
import '../entities/game_status.dart';
import '../entities/line_clear_outcome.dart';
import '../entities/seven_bag_generator.dart';
import '../entities/tetromino.dart';
import 'calculate_score.dart';
import 'detect_tspin.dart';
import 'level_curve.dart';
import 'resolve_line_clears.dart';

/// The new [GameState] after a lock, plus what the lock produced — the
/// presentation layer needs [outcome] to pick the right sound/haptic (line
/// clear, T-Spin, Perfect Clear) instead of re-deriving it from a state diff.
typedef LockResult = ({GameState state, LineClearOutcome outcome});

/// The Locking → Resolving → LineClear → Spawning pipeline from the game
/// state machine (spec.md section 8.10): fixes the active piece onto the
/// board, clears completed rows, scores the result, advances the level,
/// and spawns the next piece — or ends the game if it can't fit.
abstract final class LockActivePiece {
  static LockResult call(GameState state, Random random) {
    final tSpinType = DetectTSpin.call(
      board: state.board,
      piece: state.activePiece,
      wasLastActionRotation: state.lastActionWasRotation,
    );

    final lockedBoard = state.board.lockPiece(state.activePiece);
    final resolved = ResolveLineClears.call(lockedBoard);

    final outcome = LineClearOutcome(
      linesCleared: resolved.clearedRows.length,
      tSpinType: tSpinType,
      isPerfectClear: resolved.board.isEmpty,
      clearedRowIndices: resolved.clearedRows,
    );

    final scoreResult = CalculateScore.call(
      outcome: outcome,
      level: state.level,
      currentCombo: state.combo,
      currentBackToBack: state.backToBack,
    );

    final totalLines = state.totalLinesCleared + outcome.linesCleared;
    final newLevel = LevelCurve.levelForLines(totalLines);

    final refilledQueue = SevenBagGenerator.ensureLookahead(state.nextQueue, random);
    final nextType = refilledQueue.first;
    final spawned = Tetromino.spawn(nextType);
    final canSpawn = resolved.board.canPlace(spawned);
    final remainingQueue = SevenBagGenerator.ensureLookahead(
      refilledQueue.skip(1).toList(),
      random,
    );

    final newState = state.copyWith(
      board: resolved.board,
      activePiece: canSpawn ? spawned : state.activePiece,
      nextQueue: remainingQueue,
      holdUsed: false,
      score: state.score + scoreResult.pointsAwarded,
      level: newLevel,
      totalLinesCleared: totalLines,
      combo: scoreResult.newCombo,
      backToBack: scoreResult.newBackToBack,
      status: canSpawn ? GameStatus.playing : GameStatus.gameOver,
      lastActionWasRotation: false,
      lockResetCount: 0,
    );

    return (state: newState, outcome: outcome);
  }
}
