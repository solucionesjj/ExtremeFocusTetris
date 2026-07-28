import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/services/audio_service.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/game_status.dart';
import '../../domain/entities/t_spin_type.dart';
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
/// decides *when* to call them, and which sound/haptic (spec.md section 6)
/// each outcome deserves.
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

  void startNewGame({bool? focusMode}) {
    if (focusMode != null) this.focusMode = focusMode;
    _fallAccumulator = Duration.zero;
    _lockDelayAccumulator = Duration.zero;
    _softDropHeld = false;
    state = StartNewGame.call(_random);
    ref.read(audioServiceProvider).startAmbient();
  }

  void moveLeft() => _applyPlayerAction(MovePiece.left, sfx: SfxEvent.move, haptic: _HapticKind.move);

  void moveRight() => _applyPlayerAction(MovePiece.right, sfx: SfxEvent.move, haptic: _HapticKind.move);

  void rotateClockwise() =>
      _applyPlayerAction(RotatePiece.clockwise, sfx: SfxEvent.rotate, haptic: _HapticKind.rotate);

  void rotateCounterClockwise() =>
      _applyPlayerAction(RotatePiece.counterClockwise, sfx: SfxEvent.rotate, haptic: _HapticKind.rotate);

  /// Soft drop is a held button, not a discrete step: while [held] is true,
  /// [onTick] accelerates gravity x20 and scores 1 point per cell it
  /// actually falls — spec.md section 8.4. The SFX plays once, when the
  /// hold begins, not on every accelerated cell.
  void setSoftDropHeld(bool held) {
    if (held && !_softDropHeld) {
      ref.read(audioServiceProvider).playSfx(SfxEvent.softDrop);
    }
    _softDropHeld = held;
  }

  void hardDrop() {
    final current = state;
    if (current == null || current.status == GameStatus.gameOver) return;

    _fallAccumulator = Duration.zero;
    _lockDelayAccumulator = Duration.zero;

    ref.read(audioServiceProvider).playSfx(SfxEvent.hardDrop);
    ref.read(hapticServiceProvider).onLock();

    final result = HardDrop.call(current, _random);
    _reactToLockOutcome(result, current);
    state = result.state;
  }

  void hold() {
    final current = state;
    if (current == null || current.status == GameStatus.gameOver) return;

    final result = HoldPiece.call(current, _random);
    if (!identical(result, current)) {
      _lockDelayAccumulator = Duration.zero;
      ref.read(audioServiceProvider).playSfx(SfxEvent.hold);
      if (result.status == GameStatus.gameOver) {
        ref.read(audioServiceProvider).playSfx(SfxEvent.gameOver);
        ref.read(hapticServiceProvider).onGameOver();
      }
    }
    state = result;
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
        final result = LockActivePiece.call(working, _random);
        _reactToLockOutcome(result, current);
        working = result.state;
      }
    }

    if (!identical(working, current)) {
      state = working;
    }
  }

  void _reactToLockOutcome(LockResult result, GameState previousState) {
    final audio = ref.read(audioServiceProvider);
    final haptics = ref.read(hapticServiceProvider);
    final outcome = result.outcome;

    if (outcome.tSpinType != TSpinType.none) {
      audio.playSfx(SfxEvent.tSpin);
      haptics.onLineClear();
    } else if (outcome.linesCleared > 0) {
      final sfx = switch (outcome.linesCleared) {
        1 => SfxEvent.lineClear1,
        2 => SfxEvent.lineClear2,
        3 => SfxEvent.lineClear3,
        _ => SfxEvent.lineClearTetris,
      };
      audio.playSfx(sfx);
      haptics.onLineClear();
    }

    if (result.state.level > previousState.level) {
      audio.playSfx(SfxEvent.levelUp);
    }

    if (result.state.status == GameStatus.gameOver) {
      audio.playSfx(SfxEvent.gameOver);
      haptics.onGameOver();
    }
  }

  void _applyPlayerAction(
    GameState Function(GameState) action, {
    required SfxEvent sfx,
    required _HapticKind haptic,
  }) {
    final current = state;
    if (current == null || current.status == GameStatus.gameOver) return;

    final result = action(current);
    if (!identical(result, current)) {
      ref.read(audioServiceProvider).playSfx(sfx);
      switch (haptic) {
        case _HapticKind.move:
          ref.read(hapticServiceProvider).onMove();
        case _HapticKind.rotate:
          ref.read(hapticServiceProvider).onRotate();
      }
    }
    if (result.lockResetCount > current.lockResetCount) {
      _lockDelayAccumulator = Duration.zero;
    }
    state = result;
  }
}

enum _HapticKind { move, rotate }
