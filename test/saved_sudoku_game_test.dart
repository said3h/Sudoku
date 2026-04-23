import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/features/sudoku/data/models/saved_sudoku_game.dart';
import 'package:sudoku_app/features/sudoku/domain/models/game_mode.dart';
import 'package:sudoku_app/features/sudoku/domain/models/sudoku_board.dart';

SudokuBoard _empty() => List.generate(9, (_) => List<int?>.filled(9, null));

SavedSudokuGame _game({
  Map<(int, int), Set<int>> notes = const {},
  (int, int)? selectedCell,
  bool isZenMode = false,
  GameMode gameMode = GameMode.classic,
  String? dailyChallengeKey,
  int mistakes = 0,
}) {
  return SavedSudokuGame(
    cluesCount: 32,
    gameMode: gameMode,
    dailyChallengeKey: dailyChallengeKey,
    puzzle: _empty(),
    solution: _empty(),
    currentBoard: _empty(),
    notes: notes,
    isNoteMode: false,
    isZenMode: isZenMode,
    selectedCell: selectedCell,
    isComplete: false,
    startTime: DateTime.utc(2026, 4, 23, 10, 0),
    mistakes: mistakes,
  );
}

void main() {
  group('SavedSudokuGame.toMap / fromMap', () {
    test('roundtrip preserves notes for a single cell', () {
      final game = _game(notes: {(3, 5): {1, 4, 9}});
      final restored = SavedSudokuGame.fromMap(game.toMap());
      expect(restored.notes[(3, 5)], {1, 4, 9});
    });

    test('roundtrip preserves notes for multiple cells', () {
      final game = _game(notes: {
        (0, 0): {2, 5},
        (8, 8): {1, 3, 7},
      });
      final restored = SavedSudokuGame.fromMap(game.toMap());
      expect(restored.notes[(0, 0)], {2, 5});
      expect(restored.notes[(8, 8)], {1, 3, 7});
    });

    test('roundtrip with no notes returns empty map', () {
      final restored = SavedSudokuGame.fromMap(_game().toMap());
      expect(restored.notes, isEmpty);
    });

    test('roundtrip preserves selectedCell', () {
      final game = _game(selectedCell: (7, 2));
      final restored = SavedSudokuGame.fromMap(game.toMap());
      expect(restored.selectedCell, (7, 2));
    });

    test('roundtrip with null selectedCell stays null', () {
      final restored = SavedSudokuGame.fromMap(_game().toMap());
      expect(restored.selectedCell, isNull);
    });

    test('roundtrip preserves startTime (millisecond precision)', () {
      final game = _game();
      final restored = SavedSudokuGame.fromMap(game.toMap());
      expect(
        restored.startTime.millisecondsSinceEpoch,
        game.startTime.millisecondsSinceEpoch,
      );
    });

    test('roundtrip preserves gameMode and dailyChallengeKey', () {
      final game = _game(
        gameMode: GameMode.daily,
        dailyChallengeKey: '2026-04-23',
      );
      final restored = SavedSudokuGame.fromMap(game.toMap());
      expect(restored.gameMode, GameMode.daily);
      expect(restored.dailyChallengeKey, '2026-04-23');
    });

    test('roundtrip preserves mistakes count', () {
      final game = _game(mistakes: 5);
      final restored = SavedSudokuGame.fromMap(game.toMap());
      expect(restored.mistakes, 5);
    });

    test('roundtrip preserves isZenMode', () {
      final game = _game(isZenMode: true);
      final restored = SavedSudokuGame.fromMap(game.toMap());
      expect(restored.isZenMode, isTrue);
    });

    test('fromMap handles completely missing optional fields with defaults', () {
      final minimal = <String, dynamic>{};
      final game = SavedSudokuGame.fromMap(minimal);
      expect(game.cluesCount, 32);
      expect(game.gameMode, GameMode.classic);
      expect(game.notes, isEmpty);
      expect(game.selectedCell, isNull);
      expect(game.mistakes, 0);
    });

    test('board cells with null values survive roundtrip', () {
      final board = _empty();
      board[0][0] = 5;
      final game = SavedSudokuGame(
        cluesCount: 32,
        gameMode: GameMode.classic,
        dailyChallengeKey: null,
        puzzle: board,
        solution: _empty(),
        currentBoard: _empty(),
        notes: const {},
        isNoteMode: false,
        isZenMode: false,
        selectedCell: null,
        isComplete: false,
        startTime: DateTime.utc(2026, 4, 23),
        mistakes: 0,
      );
      final restored = SavedSudokuGame.fromMap(game.toMap());
      expect(restored.puzzle[0][0], 5);
      expect(restored.puzzle[0][1], isNull);
    });
  });
}
