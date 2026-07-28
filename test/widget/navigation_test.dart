import 'package:extreme_focus_tetris/app.dart';
import 'package:extreme_focus_tetris/core/l10n/generated/app_localizations.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/hold_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers/hive_test_setup.dart';

Future<AppLocalizations> _pumpToHome(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: ExtremeFocusTetrisApp()));
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
  return AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;
}

void main() {
  setUpHiveForTesting();

  testWidgets('Home -> Settings -> back returns to Home', (tester) async {
    final l10n = await _pumpToHome(tester);

    await tester.tap(find.text(l10n.homeSettingsButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.settingsSound), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.homePlayButton), findsOneWidget);
  });

  testWidgets('Home -> Statistics shows the zeroed placeholder stats', (tester) async {
    final l10n = await _pumpToHome(tester);

    await tester.tap(find.text(l10n.homeStatisticsButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.statisticsHighScore), findsOneWidget);
    expect(find.text('0'), findsWidgets);
  });

  testWidgets('Home -> About shows the app name', (tester) async {
    final l10n = await _pumpToHome(tester);

    await tester.tap(find.text(l10n.homeAboutButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.appTitle), findsOneWidget);
  });

  testWidgets('Home -> Jugar reaches the Game screen', (tester) async {
    final l10n = await _pumpToHome(tester);

    await tester.tap(find.text(l10n.homePlayButton));
    // GameScreen runs a real-time Ticker, so avoid pumpAndSettle (it would
    // never settle) — a couple of bounded pumps are enough to let the
    // pushed route and the deferred startNewGame() microtask resolve.
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.pause), findsOneWidget);
    // Classic mode shows the Hold panel.
    expect(find.byType(HoldWidget), findsOneWidget);

    // GameScreen's Ticker keeps requesting frames indefinitely; unmount the
    // tree so its dispose() stops it before the test binding tears down.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Home -> Jugar with Focus Mode on hides the Hold panel', (tester) async {
    final l10n = await _pumpToHome(tester);

    await tester.tap(find.text(l10n.homeFocusModeToggle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.homePlayButton));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(HoldWidget), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
