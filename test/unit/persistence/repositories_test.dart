import 'package:extreme_focus_tetris/features/game/data/repositories/game_repository_impl.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/board.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/game_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/game_status.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/grid_position.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/rotation_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:extreme_focus_tetris/features/settings/domain/entities/settings_state.dart';
import 'package:extreme_focus_tetris/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helpers/hive_test_setup.dart';

void main() {
  setUpHiveForTesting();

  group('SettingsRepositoryImpl', () {
    test('load() returns defaults when nothing was ever saved', () {
      final repo = SettingsRepositoryImpl();
      final loaded = repo.load();
      expect(loaded.soundEnabled, SettingsState.initial().soundEnabled);
      expect(loaded.themeMode, ThemeMode.system);
      expect(loaded.locale, isNull);
    });

    test('save() then load() round-trips every field, including a non-system locale', () async {
      final repo = SettingsRepositoryImpl();
      final saved = const SettingsState(
        soundEnabled: false,
        ambientVolume: 0.25,
        sfxVolume: 0.75,
        hapticsEnabled: false,
        ghostPieceEnabled: false,
        focusModeDefault: true,
        themeMode: ThemeMode.dark,
        locale: Locale('es'),
      );

      await repo.save(saved);
      final loaded = repo.load();

      expect(loaded.soundEnabled, isFalse);
      expect(loaded.ambientVolume, 0.25);
      expect(loaded.sfxVolume, 0.75);
      expect(loaded.hapticsEnabled, isFalse);
      expect(loaded.ghostPieceEnabled, isFalse);
      expect(loaded.focusModeDefault, isTrue);
      expect(loaded.themeMode, ThemeMode.dark);
      expect(loaded.locale, const Locale('es'));
    });
  });

  group('StatisticsRepositoryImpl', () {
    test('recordFinishedGame accumulates totals and keeps the highest score', () async {
      final repo = StatisticsRepositoryImpl();

      await repo.recordFinishedGame(
        finalScore: 500,
        linesCleared: 4,
        tetrises: 1,
        tSpins: 0,
        perfectClears: 0,
        playTime: const Duration(minutes: 2),
      );
      await repo.recordFinishedGame(
        finalScore: 300,
        linesCleared: 2,
        tetrises: 0,
        tSpins: 1,
        perfectClears: 1,
        playTime: const Duration(minutes: 1),
      );

      final stats = repo.load();
      expect(stats.gamesPlayed, 2);
      expect(stats.highScore, 500); // the lower second score doesn't overwrite it
      expect(stats.totalLinesCleared, 6);
      expect(stats.tetrises, 1);
      expect(stats.tSpins, 1);
      expect(stats.perfectClears, 1);
      expect(stats.timePlayed, const Duration(minutes: 3));
    });

    test('reset() clears everything back to zero', () async {
      final repo = StatisticsRepositoryImpl();
      await repo.recordFinishedGame(
        finalScore: 999,
        linesCleared: 10,
        tetrises: 2,
        tSpins: 2,
        perfectClears: 1,
        playTime: const Duration(minutes: 5),
      );

      await repo.reset();

      final stats = repo.load();
      expect(stats.highScore, 0);
      expect(stats.gamesPlayed, 0);
    });
  });

  group('GameRepositoryImpl', () {
    test('hasSavedSession is false until a session is saved, true after', () async {
      final repo = GameRepositoryImpl();
      expect(repo.hasSavedSession(), isFalse);

      await repo.saveSession(_sampleGameState(), elapsed: const Duration(seconds: 42));

      expect(repo.hasSavedSession(), isTrue);
    });

    test('saveSession then loadSession round-trips the board, piece, and score', () async {
      final repo = GameRepositoryImpl();
      final original = _sampleGameState();

      await repo.saveSession(original, elapsed: const Duration(seconds: 90));
      final restored = repo.loadSession();

      expect(restored, isNotNull);
      expect(restored!.elapsed, const Duration(seconds: 90));
      expect(restored.state.score, original.score);
      expect(restored.state.level, original.level);
      expect(restored.state.activePiece.type, original.activePiece.type);
      expect(restored.state.activePiece.origin, original.activePiece.origin);
      expect(restored.state.nextQueue, original.nextQueue);
      expect(restored.state.status, GameStatus.playing);
      expect(
        restored.state.board.cellAt(const GridPosition(6, 4)),
        original.board.cellAt(const GridPosition(6, 4)),
      );
    });

    test('clearSession removes the saved session', () async {
      final repo = GameRepositoryImpl();
      await repo.saveSession(_sampleGameState(), elapsed: Duration.zero);
      expect(repo.hasSavedSession(), isTrue);

      await repo.clearSession();

      expect(repo.hasSavedSession(), isFalse);
      expect(repo.loadSession(), isNull);
    });
  });
}

GameState _sampleGameState() {
  final board = Board.empty().lockPiece(
    const Tetromino(type: TetrominoType.t, rotation: RotationState.spawn, origin: GridPosition(5, 3)),
  );
  return GameState(
    board: board,
    activePiece: const Tetromino(
      type: TetrominoType.i,
      rotation: RotationState.spawn,
      origin: GridPosition(0, 3),
    ),
    nextQueue: const [TetrominoType.o, TetrominoType.s, TetrominoType.z],
    holdPiece: TetrominoType.l,
    holdUsed: false,
    score: 1234,
    level: 3,
    totalLinesCleared: 25,
    combo: 2,
    backToBack: true,
    status: GameStatus.playing,
    lastActionWasRotation: false,
    lockResetCount: 0,
  );
}
