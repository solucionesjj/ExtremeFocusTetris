import 'dart:math';

import 'package:extreme_focus_tetris/features/game/domain/entities/game_status.dart';
import 'package:extreme_focus_tetris/features/game/domain/usecases/start_new_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts with an empty board, score 0, level 1, and no active combo', () {
    final state = StartNewGame.call(Random(1));

    expect(state.board.isEmpty, isTrue);
    expect(state.score, 0);
    expect(state.level, 1);
    expect(state.totalLinesCleared, 0);
    expect(state.combo, -1);
    expect(state.backToBack, isFalse);
    expect(state.status, GameStatus.playing);
    expect(state.holdPiece, isNull);
    expect(state.holdUsed, isFalse);
  });

  test('provides a lookahead queue of at least 7 pieces', () {
    final state = StartNewGame.call(Random(1));
    expect(state.nextQueue.length, greaterThanOrEqualTo(7));
  });

  test('the active piece is placed at its board spawn position', () {
    final state = StartNewGame.call(Random(1));
    expect(state.board.canPlace(state.activePiece), isTrue);
  });
}
