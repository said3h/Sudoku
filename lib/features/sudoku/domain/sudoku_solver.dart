import 'models/sudoku_board.dart';

class SudokuSolver {
  /// Solves the board in-place using backtracking with MRV optimization.
  /// Returns true if solvable, false otherwise.
  static bool solve(SudokuBoard board) {
    return _solveWithMRV(board);
  }

  /// Backtracking with Minimum Remaining Values heuristic.
  static bool _solveWithMRV(SudokuBoard board) {
    final empty = _findBestCell(board);
    if (empty == null) return true; // Board complete

    final (row, col) = empty;

    for (int num = 1; num <= 9; num++) {
      if (board.isValidMove(row, col, num)) {
        board[row][col] = num;
        if (_solveWithMRV(board)) return true;
        board[row][col] = null; // Backtrack
      }
    }
    return false;
  }

  /// Finds the empty cell with the fewest valid candidates (MRV).
  static (int, int)? _findBestCell(SudokuBoard board) {
    (int, int)? bestCell;
    int minOptions = 10;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == null) {
          int count = 0;
          for (int n = 1; n <= 9; n++) {
            if (board.isValidMove(r, c, n)) count++;
          }
          if (count < minOptions) {
            minOptions = count;
            bestCell = (r, c);
            if (count == 1) return bestCell; // Can't do better
          }
        }
      }
    }
    return bestCell;
  }

  /// Counts number of unique solutions (stops at 2 for efficiency).
  static int countSolutions(SudokuBoard board, {int maxSolutions = 2}) {
    return _countSolutions(board, 0, maxSolutions);
  }

  static int _countSolutions(SudokuBoard board, int count, int maxSolutions) {
    if (count >= maxSolutions) return count;

    final empty = _findBestCell(board);
    if (empty == null) return count + 1; // Found a solution

    final (row, col) = empty;

    for (int num = 1; num <= 9; num++) {
      if (board.isValidMove(row, col, num)) {
        board[row][col] = num;
        count = _countSolutions(board, count, maxSolutions);
        board[row][col] = null;
        if (count >= maxSolutions) return count;
      }
    }
    return count;
  }

  /// Returns true if the board has a unique solution.
  static bool hasUniqueSolution(SudokuBoard board) {
    return countSolutions(board.clone(), maxSolutions: 2) == 1;
  }
}
