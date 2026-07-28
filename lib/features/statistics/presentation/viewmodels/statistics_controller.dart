import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../domain/entities/statistics_state.dart';

part 'statistics_controller.g.dart';

/// Accumulated statistics — spec.md section 8.9, persisted in Hive's
/// `stats_box` (spec.md section 13).
@riverpod
class StatisticsController extends _$StatisticsController {
  @override
  StatisticsState build() => ref.read(statisticsRepositoryProvider).load();

  Future<void> resetStatistics() async {
    await ref.read(statisticsRepositoryProvider).reset();
    state = StatisticsState.empty();
  }

  /// Called by [GameController] when a game ends — folds that game's
  /// tallies into the persisted totals and refreshes [state].
  Future<void> recordFinishedGame({
    required int finalScore,
    required int linesCleared,
    required int tetrises,
    required int tSpins,
    required int perfectClears,
    required Duration playTime,
  }) async {
    final repository = ref.read(statisticsRepositoryProvider);
    await repository.recordFinishedGame(
      finalScore: finalScore,
      linesCleared: linesCleared,
      tetrises: tetrises,
      tSpins: tSpins,
      perfectClears: perfectClears,
      playTime: playTime,
    );
    state = repository.load();
  }
}
