import '../entities/settings_state.dart';

/// Persists [SettingsState] — spec.md section 13 (`settings_box`). The
/// domain never imports Hive; only the `data` implementation does.
abstract class SettingsRepository {
  SettingsState load();

  Future<void> save(SettingsState settings);
}
