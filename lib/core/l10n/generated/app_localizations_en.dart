// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Extreme Focus Tetris';

  @override
  String homeHighScore(int score) {
    return 'High score: $score';
  }

  @override
  String get homeFocusModeToggle => 'Focus Mode';

  @override
  String get homePlayButton => 'PLAY';

  @override
  String get homeContinueButton => 'CONTINUE';

  @override
  String get homeStatisticsButton => 'Statistics';

  @override
  String get homeSettingsButton => 'Settings';

  @override
  String get homeAboutButton => 'About';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsAmbientVolume => 'Ambient volume';

  @override
  String get settingsSfxVolume => 'Effects volume';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsFocusModeDefault => 'Focus Mode by default';

  @override
  String get settingsGhostPiece => 'Ghost piece';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsResetStatistics => 'Reset statistics';

  @override
  String get settingsResetStatisticsConfirmTitle => 'Reset statistics?';

  @override
  String get settingsResetStatisticsConfirmBody => 'This cannot be undone.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsHighScore => 'High score';

  @override
  String get statisticsGamesPlayed => 'Games played';

  @override
  String get statisticsTotalLines => 'Total lines';

  @override
  String get statisticsTetrises => 'Tetrises';

  @override
  String get statisticsTSpins => 'T-Spins';

  @override
  String get statisticsPerfectClears => 'Perfect Clears';

  @override
  String get statisticsTimePlayed => 'Time played';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version (build $build)';
  }

  @override
  String get aboutDescription =>
      'Personal use. No ads, no purchases, no network connection.';

  @override
  String get gameOverTitle => 'GAME OVER';

  @override
  String gameScoreLabel(int score) {
    return 'Score: $score';
  }

  @override
  String get gamePauseTitle => 'PAUSED';

  @override
  String get gameResume => 'Resume';

  @override
  String get gameRestart => 'Restart';

  @override
  String get gameExitToMenu => 'Exit to menu';

  @override
  String get gamePlayAgain => 'Play again';

  @override
  String get gameMainMenu => 'Main menu';
}
