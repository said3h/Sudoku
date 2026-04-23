import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/features/sudoku/domain/sudoku_generator.dart';
import 'package:sudoku_app/features/sudoku/domain/sudoku_validator.dart';

void main() {
  test('daily seed generates deterministic puzzle and solution', () {
    final first = SudokuGenerator.generatePuzzle(26, seed: 20260416);
    final second = SudokuGenerator.generatePuzzle(26, seed: 20260416);

    expect(first.$1, second.$1);
    expect(first.$2, second.$2);
  });

  test('generated solution is valid and puzzle starts incomplete', () {
    final (puzzle, solution) = SudokuGenerator.generatePuzzle(32, seed: 42);

    expect(SudokuValidator.isBoardSolved(solution), isTrue);
    expect(SudokuValidator.isBoardSolved(puzzle), isFalse);
  });

  test('easy puzzle (40 clues) has exactly 40 filled cells', () {
    final (puzzle, _) = SudokuGenerator.generatePuzzle(40, seed: 7);
    final filled = puzzle.expand((row) => row).whereType<int>().length;
    expect(filled, 40);
  });

  test('expert puzzle (20 clues) has exactly 20 filled cells', () {
    final (puzzle, _) = SudokuGenerator.generatePuzzle(20, seed: 99);
    final filled = puzzle.expand((row) => row).whereType<int>().length;
    expect(filled, 20);
  });

  test('puzzle cells are a subset of solution cells', () {
    final (puzzle, solution) = SudokuGenerator.generatePuzzle(32, seed: 123);
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (puzzle[r][c] != null) {
          expect(puzzle[r][c], solution[r][c]);
        }
      }
    }
  });

  test('solution is a fully filled board', () {
    final (_, solution) = SudokuGenerator.generatePuzzle(26, seed: 55);
    final nulls = solution.expand((row) => row).where((v) => v == null).length;
    expect(nulls, 0);
  });

  test('different seeds produce different puzzles', () {
    final (puzzleA, _) = SudokuGenerator.generatePuzzle(32, seed: 1);
    final (puzzleB, _) = SudokuGenerator.generatePuzzle(32, seed: 2);
    expect(puzzleA, isNot(equals(puzzleB)));
  });

  test('generateFullBoard returns a valid solved board', () {
    final board = SudokuGenerator.generateFullBoard(seed: 77);
    expect(SudokuValidator.isBoardSolved(board), isTrue);
  });
}
