import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/features/sudoku/domain/models/sudoku_board.dart';
import 'package:sudoku_app/features/sudoku/domain/sudoku_validator.dart';

SudokuBoard _empty() => List.generate(9, (_) => List<int?>.filled(9, null));

// Classic valid solved Sudoku.
SudokuBoard _solved() => [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, 5, 3, 7, 9, 1],
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ].map((r) => r.map<int?>((v) => v).toList()).toList();

void main() {
  group('SudokuValidator.isBoardSolved', () {
    test('returns true for a valid solved board', () {
      expect(SudokuValidator.isBoardSolved(_solved()), isTrue);
    });

    test('returns false for an empty board', () {
      expect(SudokuValidator.isBoardSolved(_empty()), isFalse);
    });

    test('returns false for a complete board with a conflict', () {
      final board = _solved();
      // Swap two cells in the same row to introduce a duplicate.
      final tmp = board[0][0];
      board[0][0] = board[0][1]!;
      board[0][1] = tmp;
      expect(SudokuValidator.isBoardSolved(board), isFalse);
    });

    test('returns false for a partially filled board', () {
      final board = _solved();
      board[8][8] = null;
      expect(SudokuValidator.isBoardSolved(board), isFalse);
    });
  });

  group('SudokuValidator.getConflicts', () {
    test('returns empty list for an empty board', () {
      expect(SudokuValidator.getConflicts(_empty()), isEmpty);
    });

    test('returns empty list for a valid solved board', () {
      expect(SudokuValidator.getConflicts(_solved()), isEmpty);
    });

    test('returns both cells for a row conflict', () {
      final board = _empty();
      board[0][0] = 5;
      board[0][8] = 5;
      final conflicts = SudokuValidator.getConflicts(board);
      expect(conflicts, containsAll([(0, 0), (0, 8)]));
    });

    test('returns both cells for a column conflict', () {
      final board = _empty();
      board[0][3] = 7;
      board[8][3] = 7;
      final conflicts = SudokuValidator.getConflicts(board);
      expect(conflicts, containsAll([(0, 3), (8, 3)]));
    });

    test('returns both cells for a box conflict (different row and col)', () {
      final board = _empty();
      board[0][0] = 4;
      board[2][2] = 4; // same top-left box, row≠col
      final conflicts = SudokuValidator.getConflicts(board);
      expect(conflicts, containsAll([(0, 0), (2, 2)]));
    });

    test('does not flag a value that only appears once', () {
      final board = _empty();
      board[4][4] = 6;
      expect(SudokuValidator.getConflicts(board), isEmpty);
    });
  });

  group('SudokuValidator.hasConflict', () {
    test('returns false for a null cell', () {
      expect(SudokuValidator.hasConflict(_empty(), 0, 0), isFalse);
    });

    test('returns false when the value is unique in its row, col and box', () {
      final board = _empty();
      board[0][0] = 3;
      expect(SudokuValidator.hasConflict(board, 0, 0), isFalse);
    });

    test('returns true when a row conflict exists', () {
      final board = _empty();
      board[0][0] = 3;
      board[0][5] = 3;
      expect(SudokuValidator.hasConflict(board, 0, 0), isTrue);
    });

    test('returns true when a column conflict exists', () {
      final board = _empty();
      board[0][0] = 8;
      board[7][0] = 8;
      expect(SudokuValidator.hasConflict(board, 0, 0), isTrue);
    });

    test('returns true when a box conflict exists', () {
      final board = _empty();
      board[6][6] = 2; // bottom-right box
      board[8][8] = 2;
      expect(SudokuValidator.hasConflict(board, 6, 6), isTrue);
    });
  });

  group('SudokuValidator.isValidPlacement', () {
    test('delegates correctly to isValidMove', () {
      final board = _empty();
      board[0][5] = 9;
      expect(SudokuValidator.isValidPlacement(board, 0, 0, 9), isFalse);
      expect(SudokuValidator.isValidPlacement(board, 0, 0, 1), isTrue);
    });
  });
}
