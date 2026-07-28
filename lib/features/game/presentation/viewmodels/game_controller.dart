import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/game_state.dart';
import '../../domain/entities/game_status.dart';
import '../../domain/usecases/calculate_score.dart';
import '../../domain/usecases/hard_drop.dart';
import '../../domain/usecases/hold_piece.dart';
import '../../domain/usecases/level_curve.dart';
import '../../domain/usecases/lock_active_piece.dart';
import '../../domain/usecases/move_piece.dart';
import '../../domain/usecases/rotate_piece.dart';
import '../../domain/usecases/start_new_game.dart';

part 'game_controller.g.dart';

/// Owns the in-progress [GameState] and the gravity / lock-delay bookkeeping
/// that a real-time ticker (see `GameTickerService`) drives via [onTick].
/// Every mutation is delegated to a pure domain use case; this class only
/// decides *when* to call them.
@riverpod
class GameController extends _$GameController {
  final Random _random = Random();

  Duration _fallAccumulator = Duration.zero;
  Duration _lockDelayAccumulator = Duration.zero;
  static const Duration _lockDelayDuration = Duration(milliseconds: 500);
  static const int _softDropSpeedMultiplier = 20;

  bool _softDropHeld = false;
  bool focusMode = false;

  @override
  GameState? build() => null;

  void startNewGame() {
    _fallAccumulator = Duration.zero;
    _lockDelayAccumulator = Duration.zero;
    _softDropHeld = false;
    state = StartNewGame.call(_random);
  }

  void moveLeft() => _applyPlayerAction(MovePiece.left);

  void moveRight() => _applyPlayerAction(MovePiece.right);

  void rotateClockwise() => _applyPlayerAction(RotatePiece.clockwise);

  void rotateCounterClockwise() => _applyPlayerAction(RotatePiece.counterClockwise);

  /// Soft drop is a held button, not a discrete step: while [held] is true,
  /// [onTick] accelerates gravity x20 and scores 1 point per cell it
  /// actually falls — spec.md section 8.4.
  void setSoftDropHeld(bool held) => _softDropHeld = held;

  void hardDrop() {
    final current = state;
    if (current == null || current.status == GameStatus.gameOver) return;
    _fallAccumulator = Duration.zero;
    _lockDelayAccumulator = Duration.zero;
    state = HardDrop.call(current, _random);
  }

  void hold() {
    final current = state;
    if (current == null || current.status == GameStatus.gameOver) return;
    _lockDelayAccumulator = Duration.zero;
    state = HoldPiece.call(current, _random);
  }

  /// Called once per frame by the widget-owned ticker.
  void onTick(Duration delta) {
    final current = state;
    if (current == null || current.status == GameStatus.gameOver) return;

    var working = current;

    _fallAccumulator += delta;
    final baseInterval = LevelCurve.dropInterval(working.level, focusMode: focusMode);
    final interval = _softDropHeld
        ? Duration(
            milliseconds: (baseInterval.inMilliseconds / _softDropSpeedMultiplier)
                .clamp(1, baseInterval.inMilliseconds)
                .round(),
          )
        : baseInterval;

    if (_fallAccumulator >= interval) {
      _fallAccumulator = Duration.zero;
      final beforeFall = working;
      working = MovePiece.gravityStep(working);
      if (_softDropHeld && !identical(working, beforeFall)) {
        working = working.copyWith(score: working.score + CalculateScore.softDropPoints(1));
      }
    }

    if (MovePiece.canMoveDown(working)) {
      _lockDelayAccumulator = Duration.zero;
    } else {
      _lockDelayAccumulator += delta;
      if (_lockDelayAccumulator >= _lockDelayDuration) {
        _lockDelayAccumulator = Duration.zero;
        working = LockActivePiece.call(working, _random);
      }
    }

    if (!identical(working, current)) {
      state = working;
    }
  }

  void _applyPlayerAction(GameState Function(GameState) action) {
    final current = state;
    if (current == null || current.status == GameStatus.gameOver) return;

    final result = action(current);
    if (result.lockResetCount > current.lockResetCount) {
      _lockDelayAccumulator = Duration.zero;
    }
    state = result;
  }
}
