import 'dart:math';

import 'tetromino_type.dart';

/// 7-bag randomizer — spec.md section 8.3: each bag is a shuffled
/// permutation of all 7 pieces, guaranteeing no more than 12 pieces ever
/// pass between two occurrences of the same type.
abstract final class SevenBagGenerator {
  static List<TetrominoType> shuffledBag(Random random) {
    final bag = List<TetrominoType>.of(TetrominoType.values);
    bag.shuffle(random);
    return bag;
  }

  /// Appends freshly shuffled bags until [queue] has at least 7 upcoming
  /// pieces, so the next/hold pipeline never runs dry.
  static List<TetrominoType> ensureLookahead(
    List<TetrominoType> queue,
    Random random,
  ) {
    var result = queue;
    while (result.length < TetrominoType.values.length) {
      result = [...result, ...shuffledBag(random)];
    }
    return result;
  }
}
