import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import 'viewmodels/statistics_controller.dart';

/// spec.md section 10.2. All zero until roadmap Phase 5 wires this to
/// Hive's `stats_box`.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(statisticsControllerProvider);
    final hours = stats.timePlayed.inHours;
    final minutes = stats.timePlayed.inMinutes.remainder(60);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.spacingLg),
        children: [
          _StatRow(label: l10n.statisticsHighScore, value: '${stats.highScore}'),
          _StatRow(label: l10n.statisticsGamesPlayed, value: '${stats.gamesPlayed}'),
          _StatRow(label: l10n.statisticsTotalLines, value: '${stats.totalLinesCleared}'),
          _StatRow(label: l10n.statisticsTetrises, value: '${stats.tetrises}'),
          _StatRow(label: l10n.statisticsTSpins, value: '${stats.tSpins}'),
          _StatRow(label: l10n.statisticsPerfectClears, value: '${stats.perfectClears}'),
          _StatRow(label: l10n.statisticsTimePlayed, value: '${hours}h ${minutes}m'),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingLg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
