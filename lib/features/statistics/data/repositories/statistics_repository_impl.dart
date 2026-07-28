import 'package:hive/hive.dart';

import '../../../../core/constants/hive_box_names.dart';
import '../../domain/entities/statistics_state.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../models/statistics_model.dart';

/// Hive-backed [StatisticsRepository] — spec.md section 13 (`stats_box`).
class StatisticsRepositoryImpl implements StatisticsRepository {
  static const _key = 'current';

  Box<StatisticsModel> get _box => Hive.box<StatisticsModel>(HiveBoxNames.stats);

  @override
  StatisticsState load() {
    try {
      final model = _box.get(_key);
      if (model == null) return StatisticsState.empty();
      return _toDomain(model);
    } catch (_) {
      return StatisticsState.empty();
    }
  }

  @override
  Future<void> recordFinishedGame({
    required int finalScore,
    required int linesCleared,
    required int tetrises,
    required int tSpins,
    required int perfectClears,
    required Duration playTime,
  }) {
    final current = load();
    final updated = StatisticsModel(
      highScore: finalScore > current.highScore ? finalScore : current.highScore,
      gamesPlayed: current.gamesPlayed + 1,
      totalLinesCleared: current.totalLinesCleared + linesCleared,
      tetrises: current.tetrises + tetrises,
      tSpins: current.tSpins + tSpins,
      perfectClears: current.perfectClears + perfectClears,
      timePlayedSeconds: current.timePlayed.inSeconds + playTime.inSeconds,
    );
    return _box.put(_key, updated);
  }

  @override
  Future<void> reset() => _box.delete(_key);

  StatisticsState _toDomain(StatisticsModel model) => StatisticsState(
    highScore: model.highScore,
    gamesPlayed: model.gamesPlayed,
    totalLinesCleared: model.totalLinesCleared,
    tetrises: model.tetrises,
    tSpins: model.tSpins,
    perfectClears: model.perfectClears,
    timePlayed: Duration(seconds: model.timePlayedSeconds),
  );
}
