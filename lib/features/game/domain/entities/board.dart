import 'grid_position.dart';
import 'tetromino.dart';
import 'tetromino_type.dart';

/// The 10x22 playfield (20 visible rows + 2 hidden spawn rows — spec.md
/// section 8.1). Cells are stored as a flat typed-friendly int array (0 =
/// empty, 1..7 = [TetrominoType.index] + 1) rather than a grid of objects,
/// per the memory-management guidance in spec.md section 16.
class Board {
  static const int columns = 10;
  static const int visibleRows = 20;
  static const int hiddenRows = 2;
  static const int totalRows = visibleRows + hiddenRows;

  final List<int> _cells;

  const Board._(this._cells);

  factory Board.empty() => Board._(List<int>.filled(columns * totalRows, 0));

  int _indexOf(GridPosition p) => p.row * columns + p.col;

  bool isInsideBounds(GridPosition p) =>
      p.row >= 0 && p.row < totalRows && p.col >= 0 && p.col < columns;

  bool isCellEmpty(GridPosition p) => _cells[_indexOf(p)] == 0;

  TetrominoType? cellAt(GridPosition p) {
    final value = _cells[_indexOf(p)];
    return value == 0 ? null : TetrominoType.values[value - 1];
  }

  bool get isEmpty => _cells.every((cell) => cell == 0);

  bool canPlace(Tetromino piece) {
    for (final cell in piece.occupiedCells) {
      if (!isInsideBounds(cell) || !isCellEmpty(cell)) return false;
    }
    return true;
  }

  Board lockPiece(Tetromino piece) {
    final updated = List<int>.of(_cells);
    for (final cell in piece.occupiedCells) {
      updated[_indexOf(cell)] = piece.type.index + 1;
    }
    return Board._(updated);
  }

  /// Removes every full row, shifting the rows above it down, and returns
  /// the resulting board along with the indices that were cleared.
  ({Board board, List<int> clearedRows}) clearFullLines() {
    final clearedRows = <int>[];
    for (var row = 0; row < totalRows; row++) {
      var isFull = true;
      for (var col = 0; col < columns; col++) {
        if (_cells[row * columns + col] == 0) {
          isFull = false;
          break;
        }
      }
      if (isFull) clearedRows.add(row);
    }

    if (clearedRows.isEmpty) return (board: this, clearedRows: clearedRows);

    final clearedSet = clearedRows.toSet();
    final remainingRows = <List<int>>[
      for (var row = 0; row < totalRows; row++)
        if (!clearedSet.contains(row)) _cells.sublist(row * columns, row * columns + columns),
    ];

    final newCells = <int>[
      ...List<int>.filled(columns * clearedRows.length, 0),
      for (final row in remainingRows) ...row,
    ];

    return (board: Board._(newCells), clearedRows: clearedRows);
  }
}
