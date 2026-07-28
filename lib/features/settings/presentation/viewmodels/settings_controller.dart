import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../domain/entities/settings_state.dart';

part 'settings_controller.g.dart';

/// Owns user preferences (spec.md section 12) and immediately applies the
/// audio/haptic ones to [AudioService]/[HapticService]. In-memory for now —
/// becomes Hive-backed in roadmap Phase 5, without changing this API.
@riverpod
class SettingsController extends _$SettingsController {
  @override
  SettingsState build() => SettingsState.initial();

  void setSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
    ref.read(audioServiceProvider).setSoundEnabled(value);
  }

  void setAmbientVolume(double value) {
    state = state.copyWith(ambientVolume: value);
    ref.read(audioServiceProvider).setAmbientVolume(value);
  }

  void setSfxVolume(double value) {
    state = state.copyWith(sfxVolume: value);
    ref.read(audioServiceProvider).setSfxVolume(value);
  }

  void setHapticsEnabled(bool value) {
    state = state.copyWith(hapticsEnabled: value);
    ref.read(hapticServiceProvider).setHapticsEnabled(value);
  }

  void setGhostPieceEnabled(bool value) => state = state.copyWith(ghostPieceEnabled: value);

  void setFocusModeDefault(bool value) => state = state.copyWith(focusModeDefault: value);
}
