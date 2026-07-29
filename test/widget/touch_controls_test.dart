import 'package:extreme_focus_tetris/core/l10n/generated/app_localizations.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/game/presentation/game_screen.dart';
import 'package:extreme_focus_tetris/features/game/presentation/viewmodels/game_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers/hive_test_setup.dart';

// TouchControls acts directly on the real GameController, so these tests
// pump the full GameScreen (a live game is required) rather than the
// widget in isolation — same Ticker-safety conventions as
// game_screen_hud_test.dart (bounded pumps, unmount at the end).
Future<ProviderContainer> _pumpRunningGame(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  return ProviderScope.containerOf(tester.element(find.byType(GameScreen)));
}

void main() {
  setUpHiveForTesting();

  testWidgets('holding the left button moves the piece repeatedly via DAS then ARR', (tester) async {
    final container = await _pumpRunningGame(tester);
    final startCol = container.read(gameControllerProvider)!.activePiece.origin.col;

    final gesture = await tester.startGesture(tester.getCenter(find.byIcon(Icons.chevron_left)));
    // 170ms DAS delay, then a few 30ms ARR ticks — well under level 1's
    // gravity interval, so this isolates lateral movement from gravity.
    await tester.pump(const Duration(milliseconds: 170));
    await tester.pump(const Duration(milliseconds: 30));
    await tester.pump(const Duration(milliseconds: 30));
    await tester.pump(const Duration(milliseconds: 30));
    await gesture.up();

    final endCol = container.read(gameControllerProvider)!.activePiece.origin.col;
    expect(endCol, lessThan(startCol));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a single tap on the right button moves exactly one column', (tester) async {
    final container = await _pumpRunningGame(tester);
    final startCol = container.read(gameControllerProvider)!.activePiece.origin.col;

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();

    final endCol = container.read(gameControllerProvider)!.activePiece.origin.col;
    expect(endCol, startCol + 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping rotate changes the rotation state (except for the O piece)', (tester) async {
    final container = await _pumpRunningGame(tester);
    final before = container.read(gameControllerProvider)!.activePiece;

    await tester.tap(find.byIcon(Icons.rotate_right));
    await tester.pump();

    final after = container.read(gameControllerProvider)!.activePiece;
    if (before.type == TetrominoType.o) {
      expect(after.rotation, before.rotation);
    } else {
      expect(after.rotation, isNot(before.rotation));
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping hold swaps in the held piece and marks hold as used', (tester) async {
    final container = await _pumpRunningGame(tester);
    expect(container.read(gameControllerProvider)!.holdPiece, isNull);

    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pump();

    final state = container.read(gameControllerProvider)!;
    expect(state.holdPiece, isNotNull);
    expect(state.holdUsed, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping hard drop locks the piece and increases the score', (tester) async {
    final container = await _pumpRunningGame(tester);
    final startScore = container.read(gameControllerProvider)!.score;

    await tester.tap(find.byIcon(Icons.vertical_align_bottom));
    await tester.pump();

    final endScore = container.read(gameControllerProvider)!.score;
    expect(endScore, greaterThan(startScore));

    // The score pulse (AppDurations.scalePulseUp) schedules a Timer that
    // must fire before the tree unmounts, or the test binding complains
    // about a pending timer.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
