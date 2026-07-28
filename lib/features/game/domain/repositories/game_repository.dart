import '../entities/game_state.dart';

/// A saved session plus how long the player had been in it — spec.md
/// section 13 (`session_box`).
typedef SavedSession = ({GameState state, Duration elapsed});

/// Persists an in-progress game so it can be resumed — spec.md section 13.
/// Saved on pause / backgrounding; cleared on Game Over or an explicit new
/// game.
abstract class GameRepository {
  bool hasSavedSession();

  SavedSession? loadSession();

  Future<void> saveSession(GameState state, {required Duration elapsed});

  Future<void> clearSession();
}
