import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../settings/presentation/viewmodels/settings_controller.dart';
import '../../statistics/presentation/viewmodels/statistics_controller.dart';

/// spec.md section 10.2. Shows "Continuar" instead of "Jugar" when a saved
/// session exists (spec.md section 13).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late bool _focusModeForThisGame;

  @override
  void initState() {
    super.initState();
    _focusModeForThisGame = ref.read(settingsControllerProvider).focusModeDefault;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final highScore = ref.watch(statisticsControllerProvider).highScore;
    final hasSavedSession = ref.read(gameRepositoryProvider).hasSavedSession();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimens.spacingLg),
                Text(
                  l10n.homeHighScore(highScore),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppDimens.spacingXl),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.homeFocusModeToggle),
                  value: _focusModeForThisGame,
                  onChanged: (value) => setState(() => _focusModeForThisGame = value),
                ),
                const SizedBox(height: AppDimens.spacingMd),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push(
                      Routes.game,
                      extra: (focusMode: _focusModeForThisGame, resume: hasSavedSession),
                    ),
                    child: Text(hasSavedSession ? l10n.homeContinueButton : l10n.homePlayButton),
                  ),
                ),
                const SizedBox(height: AppDimens.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push(Routes.statistics),
                        child: Text(l10n.homeStatisticsButton),
                      ),
                    ),
                    const SizedBox(width: AppDimens.spacingMd),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push(Routes.settings),
                        child: Text(l10n.homeSettingsButton),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.spacingMd),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push(Routes.about),
                    child: Text(l10n.homeAboutButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
