import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/hold_widget.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/next_queue_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Deterministic HUD sub-widget goldens — spec.md section 21's "HUD
// clásico, HUD focus" scope, at the widget level rather than through a
// live GameScreen: GameController's 7-bag draws from an unseeded Random(),
// so a full GameScreen screenshot would show a different piece (and
// therefore different pixels) on every run — not a meaningful golden.
// These widgets take their pieces as explicit props instead, so they're
// fully reproducible.
const _upcoming = [TetrominoType.i, TetrominoType.o, TetrominoType.t, TetrominoType.s];
const _goldenKey = Key('golden-target');

Future<void> _pumpGolden(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: RepaintBoundary(key: _goldenKey, child: child))),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('next queue — Classic (3 pieces)', (tester) async {
    await _pumpGolden(tester, const NextQueueWidget(upcoming: _upcoming));
    await expectLater(find.byKey(_goldenKey), matchesGoldenFile('goldens/next_queue_classic.png'));
  });

  testWidgets('next queue — Focus Mode (1 piece, desaturated)', (tester) async {
    await _pumpGolden(
      tester,
      const NextQueueWidget(upcoming: _upcoming, visibleCount: 1, focusMode: true),
    );
    await expectLater(find.byKey(_goldenKey), matchesGoldenFile('goldens/next_queue_focus.png'));
  });

  testWidgets('next queue — colorblind palette + textures', (tester) async {
    await _pumpGolden(
      tester,
      const NextQueueWidget(upcoming: _upcoming, colorblindMode: true),
    );
    await expectLater(find.byKey(_goldenKey), matchesGoldenFile('goldens/next_queue_colorblind.png'));
  });

  testWidgets('hold widget — available', (tester) async {
    await _pumpGolden(tester, const HoldWidget(holdPiece: TetrominoType.t, isUsed: false));
    await expectLater(find.byKey(_goldenKey), matchesGoldenFile('goldens/hold_available.png'));
  });

  testWidgets('hold widget — used this piece (dimmed)', (tester) async {
    await _pumpGolden(tester, const HoldWidget(holdPiece: TetrominoType.t, isUsed: true));
    await expectLater(find.byKey(_goldenKey), matchesGoldenFile('goldens/hold_used.png'));
  });

  testWidgets('hold widget — empty slot', (tester) async {
    await _pumpGolden(tester, const HoldWidget(holdPiece: null, isUsed: false));
    await expectLater(find.byKey(_goldenKey), matchesGoldenFile('goldens/hold_empty.png'));
  });
}
