import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../statistics/presentation/viewmodels/statistics_controller.dart';
import 'viewmodels/settings_controller.dart';

/// spec.md section 12. Every control applies immediately (no "Save"
/// button); in-memory only until roadmap Phase 5 backs it with Hive.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsControllerProvider);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final themeMode = ref.watch(themeModeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.spacingLg),
        children: [
          SwitchListTile(
            title: Text(l10n.settingsSound),
            value: settings.soundEnabled,
            onChanged: settingsController.setSoundEnabled,
          ),
          ListTile(
            title: Text(l10n.settingsAmbientVolume),
            subtitle: Slider(
              value: settings.ambientVolume,
              onChanged: settings.soundEnabled ? settingsController.setAmbientVolume : null,
            ),
          ),
          ListTile(
            title: Text(l10n.settingsSfxVolume),
            subtitle: Slider(
              value: settings.sfxVolume,
              onChanged: settings.soundEnabled ? settingsController.setSfxVolume : null,
            ),
          ),
          SwitchListTile(
            title: Text(l10n.settingsHaptics),
            value: settings.hapticsEnabled,
            onChanged: settingsController.setHapticsEnabled,
          ),
          SwitchListTile(
            title: Text(l10n.settingsFocusModeDefault),
            value: settings.focusModeDefault,
            onChanged: settingsController.setFocusModeDefault,
          ),
          SwitchListTile(
            title: Text(l10n.settingsGhostPiece),
            value: settings.ghostPieceEnabled,
            onChanged: settingsController.setGhostPieceEnabled,
          ),
          const SizedBox(height: AppDimens.spacingMd),
          ListTile(
            title: Text(l10n.settingsTheme),
            trailing: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.light, label: Text(l10n.settingsThemeLight)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l10n.settingsThemeDark)),
                ButtonSegment(value: ThemeMode.system, label: Text(l10n.settingsThemeSystem)),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) =>
                  ref.read(themeModeControllerProvider.notifier).set(selection.first),
            ),
          ),
          ListTile(
            title: Text(l10n.settingsLanguage),
            trailing: DropdownButton<Locale?>(
              value: locale,
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.settingsLanguageSystem)),
                DropdownMenuItem(value: const Locale('es'), child: Text(l10n.settingsLanguageSpanish)),
                DropdownMenuItem(value: const Locale('en'), child: Text(l10n.settingsLanguageEnglish)),
              ],
              onChanged: (value) => ref.read(localeControllerProvider.notifier).set(value),
            ),
          ),
          const SizedBox(height: AppDimens.spacingXl),
          OutlinedButton(
            onPressed: () => _confirmResetStatistics(context, ref, l10n),
            child: Text(l10n.settingsResetStatistics),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmResetStatistics(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsResetStatisticsConfirmTitle),
        content: Text(l10n.settingsResetStatisticsConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(statisticsControllerProvider.notifier).resetStatistics();
    }
  }
}
