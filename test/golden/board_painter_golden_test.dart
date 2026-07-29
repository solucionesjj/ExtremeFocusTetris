import 'dart:math';

import 'package:extreme_focus_tetris/features/game/domain/entities/board.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/game_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/usecases/start_new_game.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/board_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fixed, deterministic partially-filled board — spec.md section 21's
/// golden testing scope ("tablero en estado fijo conocido"). Row 21 is one
/// cell short of a clear (a visually meaningful, reproducible state);
/// row 20 mixes a couple of piece types for color/texture variety.
GameState _fixedGameState() {
  final cells = List<int>.filled(Board.columns * Board.totalRows, 0);
  void fill(int row, int col, int typeIndex) => cells[row * Board.columns + col] = typeIndex + 1;

  for (var col = 0; col < Board.columns - 1; col++) {
    fill(21, col, col % 2 == 0 ? 4 : 6); // alternating S/L
  }
  for (var col = 2; col < 7; col++) {
    fill(20, col, 2); // T
  }

  final base = StartNewGame.call(Random(42));
  return base.copyWith(board: Board.fromCellList(cells));
}

const _goldenKey = Key('golden-target');

Future<void> _pumpBoard(WidgetTester tester, {bool colorblindMode = false, bool highContrast = false}) async {
  final gameState = _fixedGameState();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: highContrast ? Colors.white : const Color(0xFFFFF8ED),
        body: RepaintBoundary(
          key: _goldenKey,
          child: SizedBox(
            width: 300,
            height: 600,
            child: CustomPaint(
              painter: BoardPainter(
                gameState: gameState,
                gridLineColor: Colors.black12,
                emptyCellColor: highContrast ? Colors.white : const Color(0xFFFFFFFF),
                colorblindMode: colorblindMode,
                highContrast: highContrast,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('board in a fixed, known state (standard palette)', (tester) async {
    await _pumpBoard(tester);
    await expectLater(find.byKey(_goldenKey), matchesGoldenFile('goldens/board_standard.png'));
  });

  testWidgets('board in a fixed, known state (colorblind palette + textures)', (tester) async {
    await _pumpBoard(tester, colorblindMode: true);
    await expectLater(find.byKey(_goldenKey), matchesGoldenFile('goldens/board_colorblind.png'));
  });

  testWidgets('board in a fixed, known state (high contrast)', (tester) async {
    await _pumpBoard(tester, highContrast: true);
    await expectLater(find.byKey(_goldenKey), matchesGoldenFile('goldens/board_high_contrast.png'));
  });
}
