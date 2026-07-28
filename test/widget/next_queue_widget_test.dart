import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/next_queue_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const allFour = [TetrominoType.i, TetrominoType.o, TetrominoType.t, TetrominoType.s];

  testWidgets('Classic mode (visibleCount 3) shows exactly 3 swatches', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NextQueueWidget(upcoming: allFour)),
    );

    expect(find.byType(Container), findsNWidgets(3));
  });

  testWidgets('Focus Mode (visibleCount 1) shows exactly 1 swatch', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NextQueueWidget(upcoming: allFour, visibleCount: 1, focusMode: true),
      ),
    );

    expect(find.byType(Container), findsNWidgets(1));
  });
}
