/// User-configurable preferences — spec.md section 12. In-memory only for
/// now; becomes Hive-backed in roadmap Phase 5 without changing this shape.
class SettingsState {
  final bool soundEnabled;
  final double ambientVolume;
  final double sfxVolume;
  final bool hapticsEnabled;
  final bool ghostPieceEnabled;
  final bool focusModeDefault;

  const SettingsState({
    required this.soundEnabled,
    required this.ambientVolume,
    required this.sfxVolume,
    required this.hapticsEnabled,
    required this.ghostPieceEnabled,
    required this.focusModeDefault,
  });

  factory SettingsState.initial() => const SettingsState(
    soundEnabled: true,
    ambientVolume: 0.6,
    sfxVolume: 0.8,
    hapticsEnabled: true,
    ghostPieceEnabled: true,
    focusModeDefault: false,
  );

  SettingsState copyWith({
    bool? soundEnabled,
    double? ambientVolume,
    double? sfxVolume,
    bool? hapticsEnabled,
    bool? ghostPieceEnabled,
    bool? focusModeDefault,
  }) => SettingsState(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    ambientVolume: ambientVolume ?? this.ambientVolume,
    sfxVolume: sfxVolume ?? this.sfxVolume,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    ghostPieceEnabled: ghostPieceEnabled ?? this.ghostPieceEnabled,
    focusModeDefault: focusModeDefault ?? this.focusModeDefault,
  );
}
