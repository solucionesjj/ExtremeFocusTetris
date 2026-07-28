import 'package:extreme_focus_tetris/features/game/domain/entities/board.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/grid_position.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/rotation_state.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/t_spin_type.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino.dart';
import 'package:extreme_focus_tetris/features/game/domain/entities/tetromino_type.dart';
import 'package:extreme_focus_tetris/features/game/domain/usecases/detect_tspin.dart';
import 'package:flutter_test/flutter_test.dart';

Board _boardWithMarkersAt(List<GridPosition> corners) {
  var board = Board.empty();
  for (final corner in corners) {
    // A 2x2 filler placed one row/column before the target corner covers
    // exactly that corner cell without touching the T piece's own cells
    // (spawn origin (10,4), occupied cells (10,5),(11,4),(11,5),(11,6)).
    board = board.lockPiece(
      Tetromino(type: TetrominoType.o, rotation: RotationState.spawn, origin: corner),
    );
  }
  return board;
}

void main() {
  // T piece spawn (point up) at origin (10,4): corners are
  // front-left (10,4), front-right (10,6), back-left (12,4), back-right (12,6).
  final piece = const Tetromino(
    type: TetrominoType.t,
    rotation: RotationState.spawn,
    origin: GridPosition(10, 4),
  );

  test('both front corners + one back corner occupied is a full T-Spin', () {
    final board = _boardWithMarkersAt([
      const GridPosition(9, 3), // covers front-left (10,4)
      const GridPosition(9, 6), // covers front-right (10,6)
      const GridPosition(12, 4), // covers back-left (12,4)
    ]);

    final result = DetectTSpin.call(board: board, piece: piece, wasLastActionRotation: true);

    expect(result, TSpinType.full);
  });

  test('one front corner + both back corners occupied is a T-Spin Mini', () {
    final board = _boardWithMarkersAt([
      const GridPosition(9, 3), // covers front-left (10,4)
      const GridPosition(12, 4), // covers back-left (12,4)
      const GridPosition(12, 6), // covers back-right (12,6)
    ]);

    final result = DetectTSpin.call(board: board, piece: piece, wasLastActionRotation: true);

    expect(result, TSpinType.mini);
  });

  test('fewer than 3 occupied corners is not a T-Spin', () {
    final board = _boardWithMarkersAt([
      const GridPosition(9, 3), // front-left only
      const GridPosition(12, 4), // back-left only
    ]);

    final result = DetectTSpin.call(board: board, piece: piece, wasLastActionRotation: true);

    expect(result, TSpinType.none);
  });

  test('a translation (not a rotation) never grants a T-Spin', () {
    final board = _boardWithMarkersAt([
      const GridPosition(9, 3),
      const GridPosition(9, 6),
      const GridPosition(12, 4),
      const GridPosition(12, 6),
    ]);

    final result = DetectTSpin.call(board: board, piece: piece, wasLastActionRotation: false);

    expect(result, TSpinType.none);
  });

  test('only the T piece can T-Spin', () {
    final board = _boardWithMarkersAt([
      const GridPosition(9, 3),
      const GridPosition(9, 6),
      const GridPosition(12, 4),
      const GridPosition(12, 6),
    ]);
    final jPiece = const Tetromino(
      type: TetrominoType.j,
      rotation: RotationState.spawn,
      origin: GridPosition(10, 4),
    );

    final result = DetectTSpin.call(board: board, piece: jPiece, wasLastActionRotation: true);

    expect(result, TSpinType.none);
  });
}
