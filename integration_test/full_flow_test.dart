import 'package:extreme_focus_tetris/app.dart';
import 'package:extreme_focus_tetris/core/constants/hive_box_names.dart';
import 'package:extreme_focus_tetris/core/l10n/generated/app_localizations.dart';
import 'package:extreme_focus_tetris/features/game/data/models/game_session_model.dart';
import 'package:extreme_focus_tetris/features/settings/data/models/settings_model.dart';
import 'package:extreme_focus_tetris/features/statistics/data/models/statistics_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

// Mirrors lib/main.dart's setup (real Hive on the device's real storage,
// via real platform channels) without calling its `runApp` — the test
// pumps `ExtremeFocusTetrisApp` itself instead. Requires a connected
// device/emulator (`flutter test integration_test/full_flow_test.dart`).
Future<void> _initHive() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SettingsModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(StatisticsModelAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(GameSessionModelAdapter());
  await Future.wait([
    Hive.openBox<SettingsModel>(HiveBoxNames.settings),
    Hive.openBox<StatisticsModel>(HiveBoxNames.stats),
    Hive.openBox<GameSessionModel>(HiveBoxNames.session),
  ]);
}

Future<AppLocalizations> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: ExtremeFocusTetrisApp()));
  await tester.pump(const Duration(seconds: 1)); // splash's minimum display time
  await tester.pumpAndSettle();
  return AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Home -> Play -> move/rotate/drop -> pause -> resume -> exit to Home',
    (tester) async {
      await _initHive();
      await Hive.box<GameSessionModel>(HiveBoxNames.session).clear();

      final l10n = await _pumpApp(tester);

      await tester.tap(find.text(l10n.homePlayButton));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.pause), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.rotate_right));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.vertical_align_bottom));
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(l10n.gamePauseTitle), findsOneWidget);

      await tester.tap(find.text(l10n.gameResume));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(l10n.gamePauseTitle), findsNothing);

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text(l10n.gameExitToMenu));
      await tester.pumpAndSettle();
      // Not asserting Continue vs. Play here: HomeScreen reads
      // `hasSavedSession()` once in `build()`, not reactively, so whether
      // it already reflects the fire-and-forget save that just fired is a
      // real timing race, not something this flow test should assert on
      // — see resume_test.dart for that verification, done directly
      // against the repository/controller instead of the button label.
      expect(find.text(l10n.homeSettingsButton), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
