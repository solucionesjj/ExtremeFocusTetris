import '../entities/statistics_state.dart';

/// Persists accumulated statistics — spec.md section 13 (`stats_box`) /
/// section 8.9.
abstract class StatisticsRepository {
  StatisticsState load();

  Future<void> recordFinishedGame({
    required int finalScore,
    required int linesCleared,
    required int tetrises,
    required int tSpins,
    required int perfectClears,
    required Duration playTime,
  });

  Future<void> reset();
}
