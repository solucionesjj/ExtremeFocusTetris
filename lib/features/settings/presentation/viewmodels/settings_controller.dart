import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../domain/entities/settings_state.dart';

part 'settings_controller.g.dart';

/// Owns user preferences (spec.md section 12), persists them to Hive's
/// `settings_box` (spec.md section 13) on every change, and immediately
/// applies the audio/haptic ones to [AudioService]/[HapticService].
@riverpod
class SettingsController extends _$SettingsController {
  @override
  SettingsState build() => ref.read(settingsRepositoryProvider).load();

  void _persist() => ref.read(settingsRepositoryProvider).save(state);

  void setSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
    ref.read(audioServiceProvider).setSoundEnabled(value);
    _persist();
  }

  void setAmbientVolume(double value) {
    state = state.copyWith(ambientVolume: value);
    ref.read(audioServiceProvider).setAmbientVolume(value);
    _persist();
  }

  void setSfxVolume(double value) {
    state = state.copyWith(sfxVolume: value);
    ref.read(audioServiceProvider).setSfxVolume(value);
    _persist();
  }

  void setHapticsEnabled(bool value) {
    state = state.copyWith(hapticsEnabled: value);
    ref.read(hapticServiceProvider).setHapticsEnabled(value);
    _persist();
  }

  void setGhostPieceEnabled(bool value) {
    state = state.copyWith(ghostPieceEnabled: value);
    _persist();
  }

  void setFocusModeDefault(bool value) {
    state = state.copyWith(focusModeDefault: value);
    _persist();
  }

  void setThemeMode(ThemeMode value) {
    state = state.copyWith(themeMode: value);
    _persist();
  }

  void setLocale(Locale? value) {
    state = state.copyWith(locale: value);
    _persist();
  }

  void setColorblindModeEnabled(bool value) {
    state = state.copyWith(colorblindModeEnabled: value);
    _persist();
  }

  void setTextScale(double value) {
    state = state.copyWith(textScale: value.clamp(0.85, 1.3));
    _persist();
  }

  void setHighContrast(bool value) {
    state = state.copyWith(highContrast: value);
    _persist();
  }

  void setReduceMotion(bool value) {
    state = state.copyWith(reduceMotion: value);
    _persist();
  }
}
