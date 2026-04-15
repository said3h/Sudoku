import 'models/sudoku_board.dart';

class SudokuValidator {
  /// Checks if placing `value` at (row, col) is valid.
  static bool isValidPlacement(SudokuBoard board, int row, int col, int value) {
    return board.isValidMove(row, col, value);
  }

  /// Checks if the board is completely and correctly solved.
  static bool isBoardSolved(SudokuBoard board) {
    if (!board.isComplete()) return false;
    return board.isValidBoard();
  }

  /// Returns a list of conflicting cell positions.
  static List<(int, int)> getConflicts(SudokuBoard board) {
    final conflicts = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != null && !board.isValidMove(r, c, board[r][c]!)) {
          conflicts.add((r, c));
        }
      }
    }
    return conflicts;
  }

  /// Checks a single cell for conflicts.
  static bool hasConflict(SudokuBoard board, int row, int col) {
    if (board[row][col] == null) return false;
    return !board.isValidMove(row, col, board[row][col]!);
  }
}
