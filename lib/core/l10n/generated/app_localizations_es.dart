// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Extreme Focus Tetris';

  @override
  String homeHighScore(int score) {
    return 'Récord: $score';
  }

  @override
  String get homeFocusModeToggle => 'Modo Concentración';

  @override
  String get homePlayButton => 'JUGAR';

  @override
  String get homeContinueButton => 'CONTINUAR';

  @override
  String get homeStatisticsButton => 'Estadísticas';

  @override
  String get homeSettingsButton => 'Configuración';

  @override
  String get homeAboutButton => 'Acerca de';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsSound => 'Sonido';

  @override
  String get settingsAmbientVolume => 'Volumen ambiente';

  @override
  String get settingsSfxVolume => 'Volumen efectos';

  @override
  String get settingsHaptics => 'Vibración';

  @override
  String get settingsFocusModeDefault => 'Modo Concentración por defecto';

  @override
  String get settingsGhostPiece => 'Ghost piece';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSystem => 'Sistema';

  @override
  String get settingsResetStatistics => 'Reiniciar estadísticas';

  @override
  String get settingsResetStatisticsConfirmTitle => '¿Reiniciar estadísticas?';

  @override
  String get settingsResetStatisticsConfirmBody =>
      'Esta acción no se puede deshacer.';

  @override
  String get settingsAccessibilitySection => 'Accesibilidad';

  @override
  String get settingsColorblindMode => 'Modo daltónico';

  @override
  String get settingsTextScale => 'Tamaño de texto';

  @override
  String get settingsHighContrast => 'Alto contraste';

  @override
  String get settingsReduceMotion => 'Reducir movimiento';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get statisticsTitle => 'Estadísticas';

  @override
  String get statisticsHighScore => 'Récord';

  @override
  String get statisticsGamesPlayed => 'Partidas';

  @override
  String get statisticsTotalLines => 'Líneas totales';

  @override
  String get statisticsTetrises => 'Tetrises';

  @override
  String get statisticsTSpins => 'T-Spins';

  @override
  String get statisticsPerfectClears => 'Perfect Clears';

  @override
  String get statisticsTimePlayed => 'Tiempo jugado';

  @override
  String aboutVersion(String version, String build) {
    return 'Versión $version (build $build)';
  }

  @override
  String get aboutDescription =>
      'Uso personal. Sin anuncios, sin compras, sin conexión.';

  @override
  String get gameOverTitle => 'GAME OVER';

  @override
  String gameScoreLabel(int score) {
    return 'Puntaje: $score';
  }

  @override
  String get gamePauseTitle => 'PAUSA';

  @override
  String get gameResume => 'Reanudar';

  @override
  String get gameRestart => 'Reiniciar partida';

  @override
  String get gameExitToMenu => 'Salir al menú';

  @override
  String get gamePlayAgain => 'Jugar de nuevo';

  @override
  String get gameMainMenu => 'Menú principal';
}
