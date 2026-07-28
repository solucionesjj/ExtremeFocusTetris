import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/game/data/repositories/game_repository_impl.dart';
import '../../features/game/domain/repositories/game_repository.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/statistics/data/repositories/statistics_repository_impl.dart';
import '../../features/statistics/domain/repositories/statistics_repository.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

part 'providers.g.dart';

/// A single, app-lifetime [AudioService] instance — spec.md section 6.
/// `keepAlive` because it owns real player resources that must survive
/// even when nothing is currently watching it.
@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// A single, app-lifetime [HapticService] instance — spec.md section 6.4.
@Riverpod(keepAlive: true)
HapticService hapticService(Ref ref) => HapticService();

/// spec.md section 13 (`settings_box`). The Hive box must already be open
/// (see `main.dart`) by the time anything reads this provider.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => SettingsRepositoryImpl();

/// spec.md section 13 (`stats_box`).
@Riverpod(keepAlive: true)
StatisticsRepository statisticsRepository(Ref ref) => StatisticsRepositoryImpl();

/// spec.md section 13 (`session_box`).
@Riverpod(keepAlive: true)
GameRepository gameRepository(Ref ref) => GameRepositoryImpl();
