import 'dart:math';
import 'models/sudoku_board.dart';
import 'sudoku_solver.dart';

class SudokuGenerator {
  static final Random _random = Random();

  /// Generates a complete solved board.
  static SudokuBoard generateFullBoard() {
    final board = List.generate(9, (_) => List<int?>.filled(9, null));

    _fillBoard(board);
    return board;
  }

  /// Generates a puzzle board by removing numbers from a solved board.
  /// Guaranteed to have a unique solution.
  static (SudokuBoard puzzle, SudokuBoard solution) generatePuzzle(int cluesCount) {
    // Generate full solved board
    final solution = generateFullBoard();

    // Clone for puzzle
    final puzzle = solution.clone();

    // Create list of all cell positions and shuffle
    final positions = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add((r, c));
      }
    }
    positions.shuffle(_random);

    // Remove cells while maintaining unique solution
    int removed = 0;
    final targetToRemove = 81 - cluesCount;

    for (final (row, col) in positions) {
      if (removed >= targetToRemove) break;

      final backup = puzzle[row][col];
      puzzle[row][col] = null;

      // Check if still unique solution
      if (SudokuSolver.hasUniqueSolution(puzzle)) {
        removed++;
      } else {
        puzzle[row][col] = backup; // Restore if breaks uniqueness
      }
    }

    return (puzzle, solution);
  }

  /// Fills an empty board with valid numbers using randomized backtracking.
  static bool _fillBoard(SudokuBoard board) {
    final empty = _findEmptyCell(board);
    if (empty == null) return true; // Board complete

    final (row, col) = empty;

    // Try numbers in random order
    final numbers = List.generate(9, (i) => i + 1)..shuffle(_random);

    for (final num in numbers) {
      if (board.isValidMove(row, col, num)) {
        board[row][col] = num;
        if (_fillBoard(board)) return true;
        board[row][col] = null; // Backtrack
      }
    }
    return false;
  }

  static (int, int)? _findEmptyCell(SudokuBoard board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == null) return (r, c);
      }
    }
    return null;
  }
}

// Extension to generate with initial values
extension SudokuBoardConstructor on SudokuBoard {
  static SudokuBoard generate(int rows, int cols, int? Function(int) generator) {
    return List.generate(rows, (r) => List.generate(cols, (c) => generator(r * cols + c)));
  }
}
