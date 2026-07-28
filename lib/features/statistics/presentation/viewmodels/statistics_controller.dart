import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/statistics_state.dart';

part 'statistics_controller.g.dart';

/// Placeholder until roadmap Phase 5 wires this to Hive's `stats_box`.
/// `resetStatistics` is already wired for that future state — right now
/// there's nothing accumulated to reset.
@riverpod
class StatisticsController extends _$StatisticsController {
  @override
  StatisticsState build() => StatisticsState.empty();

  void resetStatistics() => state = StatisticsState.empty();
}
