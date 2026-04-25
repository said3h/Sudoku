import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/features/sudoku/domain/models/sudoku_board.dart';

SudokuBoard _empty() => List.generate(9, (_) => List<int?>.filled(9, null));

void main() {
  group('BoardExtension.getRow', () {
    test('returns the correct row', () {
      final board = _empty();
      board[3][7] = 5;
      final row = board.getRow(3);
      expect(row[7], 5);
      expect(row.length, 9);
    });
  });

  group('BoardExtension.getColumn', () {
    test('returns the correct column', () {
      final board = _empty();
      board[4][2] = 8;
      final col = board.getColumn(2);
      expect(col[4], 8);
      expect(col.length, 9);
    });
  });

  group('BoardExtension.getBox', () {
    test('returns the 9 cells of the 3x3 box', () {
      final board = _empty();
      board[3][3] = 1;
      board[4][4] = 2;
      board[5][5] = 3;
      final box = board.getBox(1, 1); // middle box: rows 3-5, cols 3-5
      expect(box, containsAll([1, 2, 3]));
      expect(box.length, 9);
    });
  });

  group('BoardExtension.isValidMove', () {
    test('returns true on empty board', () {
      expect(_empty().isValidMove(0, 0, 5), isTrue);
    });

    test('returns false when value exists in same row', () {
      final board = _empty();
      board[0][8] = 3;
      expect(board.isValidMove(0, 0, 3), isFalse);
    });

    test('returns false when value exists in same column', () {
      final board = _empty();
      board[8][0] = 7;
      expect(board.isValidMove(0, 0, 7), isFalse);
    });

    test('returns false when value exists in same 3x3 box (different row & col)', () {
      final board = _empty();
      board[2][2] = 4; // top-left box
      expect(board.isValidMove(0, 0, 4), isFalse);
    });

    test('returns true when value only appears in a different box', () {
      final board = _empty();
      board[5][5] = 4; // centre box
      expect(board.isValidMove(0, 0, 4), isTrue);
    });

    test('returns true when checking existing value at its own position', () {
      // Used by isValidBoard to validate placed numbers — must exclude itself.
      final board = _empty();
      board[0][0] = 5;
      expect(board.isValidMove(0, 0, 5), isTrue);
    });

    test('returns false when value in same row inside same box', () {
      final board = _empty();
      board[0][1] = 6; // top-left box, same row as (0,0)
      expect(board.isValidMove(0, 0, 6), isFalse);
    });

    test('returns false when value in same column inside same box', () {
      final board = _empty();
      board[1][0] = 9; // top-left box, same col as (0,0)
      expect(board.isValidMove(0, 0, 9), isFalse);
    });
  });

  group('BoardExtension.isComplete', () {
    test('returns false for an empty board', () {
      expect(_empty().isComplete(), isFalse);
    });

    test('returns false when one cell is null', () {
      final board = List.generate(9, (r) => List<int?>.generate(9, (c) => 1));
      board[8][8] = null;
      expect(board.isComplete(), isFalse);
    });

    test('returns true when every cell is filled', () {
      final board = List.generate(9, (r) => List<int?>.generate(9, (c) => 1));
      expect(board.isComplete(), isTrue);
    });
  });

  group('BoardExtension.isValidBoard', () {
    test('returns true for an empty board', () {
      expect(_empty().isValidBoard(), isTrue);
    });

    test('returns false when a row has duplicate values', () {
      final board = _empty();
      board[0][0] = 5;
      board[0][8] = 5;
      expect(board.isValidBoard(), isFalse);
    });

    test('returns false when a column has duplicate values', () {
      final board = _empty();
      board[0][0] = 3;
      board[8][0] = 3;
      expect(board.isValidBoard(), isFalse);
    });

    test('returns false when a box has duplicate values', () {
      final board = _empty();
      board[0][0] = 7;
      board[2][2] = 7;
      expect(board.isValidBoard(), isFalse);
    });
  });

  group('BoardExtension.countConflicts', () {
    test('returns 0 for an empty board', () {
      expect(_empty().countConflicts(), 0);
    });

    test('returns 2 for one row conflict', () {
      final board = _empty();
      board[0][0] = 5;
      board[0][8] = 5;
      expect(board.countConflicts(), 2);
    });

    test('counts each conflicting cell individually', () {
      final board = _empty();
      board[4][0] = 9;
      board[4][4] = 9;
      board[4][8] = 9; // three cells all 9 in row 4
      expect(board.countConflicts(), 3);
    });
  });

  group('BoardExtension.clone', () {
    test('produces an independent copy', () {
      final board = _empty();
      board[0][0] = 3;
      final clone = board.clone();
      clone[0][0] = 9;
      expect(board[0][0], 3);
    });

    test('cloned board has same values', () {
      final board = _empty();
      board[5][5] = 7;
      final clone = board.clone();
      expect(clone[5][5], 7);
    });
  });
}
