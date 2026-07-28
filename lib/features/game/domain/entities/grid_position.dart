/// A (row, column) cell on the board grid. Row increases downward from the
/// top of the hidden spawn area; column increases rightward.
class GridPosition {
  final int row;
  final int col;

  const GridPosition(this.row, this.col);

  GridPosition operator +(GridPosition other) =>
      GridPosition(row + other.row, col + other.col);

  @override
  bool operator ==(Object other) =>
      other is GridPosition && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'GridPosition($row, $col)';
}
