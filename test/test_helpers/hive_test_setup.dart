import 'dart:io';

import 'package:extreme_focus_tetris/core/constants/hive_box_names.dart';
import 'package:extreme_focus_tetris/features/game/data/models/game_session_model.dart';
import 'package:extreme_focus_tetris/features/settings/data/models/settings_model.dart';
import 'package:extreme_focus_tetris/features/statistics/data/models/statistics_model.dart';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests pump `ExtremeFocusTetrisApp` directly (never through
/// `main()`), so the Hive boxes it expects to already be open must be set
/// up manually. Call [setUpHiveForTesting] once per test file (in a
/// top-level `setUpAll`/`tearDown` pair) before pumping anything that
/// reads `settingsControllerProvider`, `statisticsControllerProvider`, or
/// `gameRepositoryProvider`.
void setUpHiveForTesting() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('extreme_focus_tetris_hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SettingsModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(StatisticsModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(GameSessionModelAdapter());
    await Future.wait([
      Hive.openBox<SettingsModel>(HiveBoxNames.settings),
      Hive.openBox<StatisticsModel>(HiveBoxNames.stats),
      Hive.openBox<GameSessionModel>(HiveBoxNames.session),
    ]);
  });

  // Prevents one test's writes from leaking into the next within the same
  // file — the same class of bug that hit `createAppRouter()` in Phase 4.
  tearDown(() async {
    await Hive.box<SettingsModel>(HiveBoxNames.settings).clear();
    await Hive.box<StatisticsModel>(HiveBoxNames.stats).clear();
    await Hive.box<GameSessionModel>(HiveBoxNames.session).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });
}
