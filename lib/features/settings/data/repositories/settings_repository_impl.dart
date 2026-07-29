import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/hive_box_names.dart';
import '../../domain/entities/settings_state.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/settings_model.dart';

/// Hive-backed [SettingsRepository] — spec.md section 13 (`settings_box`).
class SettingsRepositoryImpl implements SettingsRepository {
  static const _key = 'current';

  Box<SettingsModel> get _box => Hive.box<SettingsModel>(HiveBoxNames.settings);

  @override
  SettingsState load() {
    try {
      final model = _box.get(_key);
      if (model == null) return SettingsState.initial();
      return SettingsState(
        soundEnabled: model.soundEnabled,
        ambientVolume: model.ambientVolume,
        sfxVolume: model.sfxVolume,
        hapticsEnabled: model.hapticsEnabled,
        ghostPieceEnabled: model.ghostPieceEnabled,
        focusModeDefault: model.focusModeDefault,
        themeMode: ThemeMode.values[model.themeModeIndex],
        locale: model.localeCode == null ? null : Locale(model.localeCode!),
        colorblindModeEnabled: model.colorblindModeEnabled,
        textScale: model.textScale,
        highContrast: model.highContrast,
        reduceMotion: model.reduceMotion,
      );
    } catch (_) {
      // Corrupt or unreadable record — spec.md section 22: fall back to
      // defaults rather than blocking app startup.
      return SettingsState.initial();
    }
  }

  @override
  Future<void> save(SettingsState settings) => _box.put(
    _key,
    SettingsModel(
      soundEnabled: settings.soundEnabled,
      ambientVolume: settings.ambientVolume,
      sfxVolume: settings.sfxVolume,
      hapticsEnabled: settings.hapticsEnabled,
      ghostPieceEnabled: settings.ghostPieceEnabled,
      focusModeDefault: settings.focusModeDefault,
      themeModeIndex: settings.themeMode.index,
      localeCode: settings.locale?.languageCode,
      colorblindModeEnabled: settings.colorblindModeEnabled,
      textScale: settings.textScale,
      highContrast: settings.highContrast,
      reduceMotion: settings.reduceMotion,
    ),
  );
}
