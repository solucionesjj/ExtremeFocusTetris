import 'package:extreme_focus_tetris/core/l10n/generated/app_localizations.dart';
import 'package:extreme_focus_tetris/features/game/presentation/game_screen.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/hold_widget.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/next_queue_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers/hive_test_setup.dart';

// Pumps GameScreen directly (bypassing Home/go_router, same rationale as
// settings_screen_test.dart) — its Ticker runs indefinitely, so every test
// here uses bounded pumps and unmounts the tree at the end instead of
// pumpAndSettle(), per the convention already established for GameScreen
// tests in navigation_test.dart.
Future<void> _pumpGameScreen(WidgetTester tester, {required bool focusMode}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameScreen(focusMode: focusMode),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  setUpHiveForTesting();

  group('Classic mode HUD', () {
    testWidgets('shows level, lines, Hold panel, and a 3-piece next queue', (tester) async {
      await _pumpGameScreen(tester, focusMode: false);

      expect(find.textContaining('Nivel'), findsOneWidget);
      expect(find.textContaining('Líneas'), findsOneWidget);
      expect(find.byType(HoldWidget), findsOneWidget);

      final nextQueue = tester.widget<NextQueueWidget>(find.byType(NextQueueWidget));
      expect(nextQueue.visibleCount, 3);
      expect(nextQueue.focusMode, isFalse);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('Focus Mode HUD', () {
    testWidgets('hides level, lines/combo row, and Hold panel; next queue reduced to 1', (tester) async {
      await _pumpGameScreen(tester, focusMode: true);

      expect(find.textContaining('Nivel'), findsNothing);
      expect(find.textContaining('Líneas'), findsNothing);
      expect(find.byType(HoldWidget), findsNothing);

      final nextQueue = tester.widget<NextQueueWidget>(find.byType(NextQueueWidget));
      expect(nextQueue.visibleCount, 1);
      expect(nextQueue.focusMode, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('still shows the elapsed timer', (tester) async {
      await _pumpGameScreen(tester, focusMode: true);

      expect(find.textContaining(':'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
