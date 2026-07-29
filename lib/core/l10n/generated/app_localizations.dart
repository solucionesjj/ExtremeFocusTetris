import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Application name, shown in the OS task switcher and splash screen
  ///
  /// In en, this message translates to:
  /// **'Extreme Focus Tetris'**
  String get appTitle;

  /// High score shown on the Home screen
  ///
  /// In en, this message translates to:
  /// **'High score: {score}'**
  String homeHighScore(int score);

  /// No description provided for @homeFocusModeToggle.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get homeFocusModeToggle;

  /// No description provided for @homePlayButton.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get homePlayButton;

  /// No description provided for @homeContinueButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get homeContinueButton;

  /// No description provided for @homeStatisticsButton.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get homeStatisticsButton;

  /// No description provided for @homeSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsButton;

  /// No description provided for @homeAboutButton.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get homeAboutButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// No description provided for @settingsAmbientVolume.
  ///
  /// In en, this message translates to:
  /// **'Ambient volume'**
  String get settingsAmbientVolume;

  /// No description provided for @settingsSfxVolume.
  ///
  /// In en, this message translates to:
  /// **'Effects volume'**
  String get settingsSfxVolume;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsHaptics;

  /// No description provided for @settingsFocusModeDefault.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode by default'**
  String get settingsFocusModeDefault;

  /// No description provided for @settingsGhostPiece.
  ///
  /// In en, this message translates to:
  /// **'Ghost piece'**
  String get settingsGhostPiece;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsResetStatistics.
  ///
  /// In en, this message translates to:
  /// **'Reset statistics'**
  String get settingsResetStatistics;

  /// No description provided for @settingsResetStatisticsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset statistics?'**
  String get settingsResetStatisticsConfirmTitle;

  /// No description provided for @settingsResetStatisticsConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get settingsResetStatisticsConfirmBody;

  /// No description provided for @settingsAccessibilitySection.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsAccessibilitySection;

  /// No description provided for @settingsColorblindMode.
  ///
  /// In en, this message translates to:
  /// **'Colorblind mode'**
  String get settingsColorblindMode;

  /// No description provided for @settingsTextScale.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsTextScale;

  /// No description provided for @settingsHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get settingsHighContrast;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @statisticsHighScore.
  ///
  /// In en, this message translates to:
  /// **'High score'**
  String get statisticsHighScore;

  /// No description provided for @statisticsGamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games played'**
  String get statisticsGamesPlayed;

  /// No description provided for @statisticsTotalLines.
  ///
  /// In en, this message translates to:
  /// **'Total lines'**
  String get statisticsTotalLines;

  /// No description provided for @statisticsTetrises.
  ///
  /// In en, this message translates to:
  /// **'Tetrises'**
  String get statisticsTetrises;

  /// No description provided for @statisticsTSpins.
  ///
  /// In en, this message translates to:
  /// **'T-Spins'**
  String get statisticsTSpins;

  /// No description provided for @statisticsPerfectClears.
  ///
  /// In en, this message translates to:
  /// **'Perfect Clears'**
  String get statisticsPerfectClears;

  /// No description provided for @statisticsTimePlayed.
  ///
  /// In en, this message translates to:
  /// **'Time played'**
  String get statisticsTimePlayed;

  /// App version shown on the About screen
  ///
  /// In en, this message translates to:
  /// **'Version {version} (build {build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Personal use. No ads, no purchases, no network connection.'**
  String get aboutDescription;

  /// No description provided for @gameOverTitle.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get gameOverTitle;

  /// Final score shown on the Game Over overlay
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String gameScoreLabel(int score);

  /// No description provided for @gamePauseTitle.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get gamePauseTitle;

  /// No description provided for @gameResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get gameResume;

  /// No description provided for @gameRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get gameRestart;

  /// No description provided for @gameExitToMenu.
  ///
  /// In en, this message translates to:
  /// **'Exit to menu'**
  String get gameExitToMenu;

  /// No description provided for @gamePlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get gamePlayAgain;

  /// No description provided for @gameMainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main menu'**
  String get gameMainMenu;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
