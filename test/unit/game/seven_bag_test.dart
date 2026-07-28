import 'dart:math';

import 'package:extreme_focus_tetris/features/game/domain/entities/seven_bag_generator.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a single bag contains all 7 types exactly once', () {
    final bag = SevenBagGenerator.shuffledBag(Random(42));

    expect(bag.length, 7);
    expect(bag.toSet(), TetrominoType.values.toSet());
  });

  test('consecutive bags from the same generator are each a full permutation', () {
    final random = Random(7);
    for (var i = 0; i < 20; i++) {
      final bag = SevenBagGenerator.shuffledBag(random);
      expect(bag.toSet(), TetrominoType.values.toSet());
    }
  });

  test('no piece type ever has more than 12 other pieces before its next occurrence', () {
    // Worst case: a piece is drawn first in one bag and last in the next,
    // e.g. index 0 then index 13 (7 + 6) — 12 *other* pieces in between,
    // i.e. an index gap of at most 13.
    final random = Random(123);
    final stream = <TetrominoType>[];
    for (var i = 0; i < 50; i++) {
      stream.addAll(SevenBagGenerator.shuffledBag(random));
    }

    for (final type in TetrominoType.values) {
      final indices = [
        for (var i = 0; i < stream.length; i++)
          if (stream[i] == type) i,
      ];
      for (var i = 1; i < indices.length; i++) {
        expect(indices[i] - indices[i - 1], lessThanOrEqualTo(13));
      }
    }
  });

  test('ensureLookahead always yields at least 7 upcoming pieces', () {
    final random = Random(1);
    final refilled = SevenBagGenerator.ensureLookahead(const [], random);
    expect(refilled.length, greaterThanOrEqualTo(7));

    final almostEmpty = SevenBagGenerator.ensureLookahead([
      TetrominoType.i,
      TetrominoType.o,
    ], random);
    expect(almostEmpty.length, greaterThanOrEqualTo(7));
    expect(almostEmpty[0], TetrominoType.i);
    expect(almostEmpty[1], TetrominoType.o);
  });
}
