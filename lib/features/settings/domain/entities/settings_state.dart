import 'package:flutter/material.dart';

const _unset = Object();

/// User-configurable preferences — spec.md section 12, persisted as a
/// single record in Hive's `settings_box` (spec.md section 13).
class SettingsState {
  final bool soundEnabled;
  final double ambientVolume;
  final double sfxVolume;
  final bool hapticsEnabled;
  final bool ghostPieceEnabled;
  final bool focusModeDefault;
  final ThemeMode themeMode;

  /// `null` means "follow the system locale".
  final Locale? locale;

  // Accessibility (spec.md section 14).
  final bool colorblindModeEnabled;

  /// Applied via `MediaQuery.textScaler` app-wide — spec.md section 14
  /// bounds this to 0.85x-1.3x so the board's HUD layout never breaks.
  final double textScale;
  final bool highContrast;
  final bool reduceMotion;

  const SettingsState({
    required this.soundEnabled,
    required this.ambientVolume,
    required this.sfxVolume,
    required this.hapticsEnabled,
    required this.ghostPieceEnabled,
    required this.focusModeDefault,
    required this.themeMode,
    required this.locale,
    required this.colorblindModeEnabled,
    required this.textScale,
    required this.highContrast,
    required this.reduceMotion,
  });

  factory SettingsState.initial() => const SettingsState(
    soundEnabled: true,
    ambientVolume: 0.6,
    sfxVolume: 0.8,
    hapticsEnabled: true,
    ghostPieceEnabled: true,
    focusModeDefault: false,
    themeMode: ThemeMode.system,
    locale: null,
    colorblindModeEnabled: false,
    textScale: 1.0,
    highContrast: false,
    reduceMotion: false,
  );

  SettingsState copyWith({
    bool? soundEnabled,
    double? ambientVolume,
    double? sfxVolume,
    bool? hapticsEnabled,
    bool? ghostPieceEnabled,
    bool? focusModeDefault,
    ThemeMode? themeMode,
    // Distinguishes "not passed" from "explicitly set to null" (system
    // locale), which a plain `Locale? locale` parameter can't do with `??`.
    Object? locale = _unset,
    bool? colorblindModeEnabled,
    double? textScale,
    bool? highContrast,
    bool? reduceMotion,
  }) => SettingsState(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    ambientVolume: ambientVolume ?? this.ambientVolume,
    sfxVolume: sfxVolume ?? this.sfxVolume,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    ghostPieceEnabled: ghostPieceEnabled ?? this.ghostPieceEnabled,
    focusModeDefault: focusModeDefault ?? this.focusModeDefault,
    themeMode: themeMode ?? this.themeMode,
    locale: identical(locale, _unset) ? this.locale : locale as Locale?,
    colorblindModeEnabled: colorblindModeEnabled ?? this.colorblindModeEnabled,
    textScale: textScale ?? this.textScale,
    highContrast: highContrast ?? this.highContrast,
    reduceMotion: reduceMotion ?? this.reduceMotion,
  );
}
