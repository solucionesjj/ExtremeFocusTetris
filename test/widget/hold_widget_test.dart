import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/game/presentation/widgets/hold_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders an empty transparent slot when there is no held piece', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HoldWidget(holdPiece: null, isUsed: false)),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.transparent);
  });

  testWidgets('renders full opacity when the held piece is available', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HoldWidget(holdPiece: TetrominoType.t, isUsed: false)),
    );

    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 1);
  });

  testWidgets('dims the slot once the hold has already been used this piece', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HoldWidget(holdPiece: TetrominoType.t, isUsed: true)),
    );

    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, lessThan(1));
  });
}
