import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/hive_box_names.dart';
import 'features/game/data/models/game_session_model.dart';
import 'features/settings/data/models/settings_model.dart';
import 'features/statistics/data/models/statistics_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(SettingsModelAdapter())
    ..registerAdapter(StatisticsModelAdapter())
    ..registerAdapter(GameSessionModelAdapter());
  await Future.wait([
    Hive.openBox<SettingsModel>(HiveBoxNames.settings),
    Hive.openBox<StatisticsModel>(HiveBoxNames.stats),
    Hive.openBox<GameSessionModel>(HiveBoxNames.session),
  ]);

  runApp(const ProviderScope(child: ExtremeFocusTetrisApp()));
}
