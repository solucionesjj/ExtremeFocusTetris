import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/services/audio_service.dart';
import '../../../statistics/presentation/viewmodels/statistics_controller.dart';
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
import 'line_clear_event_controller.dart';

part 'game_controller.g.dart';

/// Owns the in-progress [GameState] and the gravity / lock-delay bookkeeping
/// that a real-time ticker (see `GameTickerService`) drives via [onTick].
/// Every mutation is delegated to a pure domain use case; this class only
/// decides *when* to call them, which sound/haptic (spec.md section 6) each
/// outcome deserves, and when to persist a session snapshot or the final
/// tally for a finished game (spec.md section 13).
@riverpod
class GameController extends _$GameController {
  final Random _random = Random();

  Duration _fallAccumulator = Duration.zero;
  Duration _lockDelayAccumulator = Duration.zero;
  static const Duration _lockDelayDuration = Duration(milliseconds: 500);
  static const int _softDropSpeedMultiplier = 20;

  bool _softDropHeld = false;
  bool focusMode = false;

  /// Focus Mode attenuates UI SFX by roughly -6dB so the ambient tic-toc
  /// stays the dominant sound — spec.md section 9.2.
  static const double _focusModeSfxAttenuation = 0.5;

  void _playSfx(SfxEvent event) => ref
      .read(audioServiceProvider)
      .playSfx(event, volumeMultiplier: focusMode ? _focusModeSfxAttenuation : 1.0);

  // Per-game tallies for the Statistics screen (spec.md 8.9) — the
  // session snapshot itself doesn't carry these (spec.md 13 only lists
  // board/piece/score/level/time), so a resumed game's pre-pause tallies
  // aren't retroactively counted; only what happens from resume onward is.
  int _sessionTetrises = 0;
  int _sessionTSpins = 0;
  int _sessionPerfectClears = 0;
  Duration _sessionPlayTime = Duration.zero;

  @override
  GameState? build() => null;

  void startNewGame({bool? focusMode}) {
    if (focusMode != null) this.focusMode = focusMode;
    _resetSessionTracking();
    state = StartNewGame.call(_random);
    ref.read(audioServiceProvider).startAmbient();
    ref.read(gameRepositoryProvider).clearSession();
  }

  /// Restores the last saved session (spec.md section 13), or starts a
  /// fresh game if there's nothing to resume.
  void resumeSession() {
    final saved = ref.read(gameRepositoryProvider).loadSession();
    if (saved == null) {
      startNewGame();
      return;
    }
    _resetSessionTracking();
    _sessionPlayTime = saved.elapsed;
    state = saved.state;
    ref.read(audioServiceProvider).startAmbient();
  }

  void _resetSessionTracking() {
    _fallAccumulator = Duration.zero;
    _lockDelayAccumulator = Duration.zero;
    _softDropHeld = false;
    _sessionTetrises = 0;
    _sessionTSpins = 0;
    _sessionPerfectClears = 0;
    _sessionPlayTime = Duration.zero;
  }

  /// Saves the current session — called on pause and on backgrounding
  /// (spec.md section 13).
  void saveSessionNow() {
    final current = state;
    if (current == null || current.status == GameStatus.gameOver) return;
    ref.read(gameRepositoryProvider).saveSession(current, elapsed: _sessionPlayTime);
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
      _playSfx(SfxEvent.softDrop);
    }
    _softDropHeld = held;
  }

  void hardDrop() {
    final current = state;
    if (current == null || current.status == GameStatus.gameOver) return;

    _fallAccumulator = Duration.zero;
    _lockDelayAccumulator = Duration.zero;

    _playSfx(SfxEvent.hardDrop);
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
      _playSfx(SfxEvent.hold);
      if (result.status == GameStatus.gameOver) {
        _playSfx(SfxEvent.gameOver);
        ref.read(hapticServiceProvider).onGameOver();
        _onGameEnded(result);
      }
    }
    state = result;
  }

  /// Called once per frame by the widget-owned ticker.
  void onTick(Duration delta) {
    final current = state;
    if (current == null || current.status == GameStatus.gameOver) return;

    _sessionPlayTime += delta;
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
    final haptics = ref.read(hapticServiceProvider);
    final outcome = result.outcome;

    if (outcome.tSpinType != TSpinType.none) {
      _sessionTSpins++;
      _playSfx(SfxEvent.tSpin);
      haptics.onLineClear();
    } else if (outcome.linesCleared > 0) {
      final sfx = switch (outcome.linesCleared) {
        1 => SfxEvent.lineClear1,
        2 => SfxEvent.lineClear2,
        3 => SfxEvent.lineClear3,
        _ => SfxEvent.lineClearTetris,
      };
      if (outcome.linesCleared == 4) _sessionTetrises++;
      _playSfx(sfx);
      haptics.onLineClear();
    }
    if (outcome.isPerfectClear) _sessionPerfectClears++;

    if (outcome.linesCleared > 0) {
      ref.read(lineClearEventControllerProvider.notifier).emit(outcome.clearedRowIndices);
    }

    if (result.state.level > previousState.level) {
      _playSfx(SfxEvent.levelUp);
    }

    if (result.state.status == GameStatus.gameOver) {
      _playSfx(SfxEvent.gameOver);
      haptics.onGameOver();
      _onGameEnded(result.state);
    }
  }

  void _onGameEnded(GameState finalState) {
    ref
        .read(statisticsControllerProvider.notifier)
        .recordFinishedGame(
          finalScore: finalState.score,
          linesCleared: finalState.totalLinesCleared,
          tetrises: _sessionTetrises,
          tSpins: _sessionTSpins,
          perfectClears: _sessionPerfectClears,
          playTime: _sessionPlayTime,
        );
    ref.read(gameRepositoryProvider).clearSession();
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
      _playSfx(sfx);
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
