/// Accumulated statistics — spec.md section 8.9 / 10.2 (Statistics screen).
/// Always zero for now: there is no persistence yet (roadmap Phase 5 wires
/// this to Hive's `stats_box`), so nothing survives between games.
class StatisticsState {
  final int highScore;
  final int gamesPlayed;
  final int totalLinesCleared;
  final int tetrises;
  final int tSpins;
  final int perfectClears;
  final Duration timePlayed;

  const StatisticsState({
    required this.highScore,
    required this.gamesPlayed,
    required this.totalLinesCleared,
    required this.tetrises,
    required this.tSpins,
    required this.perfectClears,
    required this.timePlayed,
  });

  factory StatisticsState.empty() => const StatisticsState(
    highScore: 0,
    gamesPlayed: 0,
    totalLinesCleared: 0,
    tetrises: 0,
    tSpins: 0,
    perfectClears: 0,
    timePlayed: Duration.zero,
  );
}
