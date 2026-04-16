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
}
