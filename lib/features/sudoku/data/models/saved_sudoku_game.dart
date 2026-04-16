import '../../domain/models/sudoku_board.dart';
import '../../domain/models/game_mode.dart';

class SavedSudokuGame {
  final int cluesCount;
  final GameMode gameMode;
  final String? dailyChallengeKey;
  final SudokuBoard puzzle;
  final SudokuBoard solution;
  final SudokuBoard currentBoard;
  final Map<(int, int), Set<int>> notes;
  final bool isNoteMode;
  final bool isZenMode;
  final (int, int)? selectedCell;
  final bool isComplete;
  final DateTime startTime;
  final int mistakes;

  const SavedSudokuGame({
    required this.cluesCount,
    required this.gameMode,
    required this.dailyChallengeKey,
    required this.puzzle,
    required this.solution,
    required this.currentBoard,
    required this.notes,
    required this.isNoteMode,
    required this.isZenMode,
    required this.selectedCell,
    required this.isComplete,
    required this.startTime,
    required this.mistakes,
  });

  factory SavedSudokuGame.fromMap(Map<dynamic, dynamic> rawMap) {
    final map = Map<dynamic, dynamic>.from(rawMap);
    final selectedCell = map['selectedCell'];

    return SavedSudokuGame(
      cluesCount: map['cluesCount'] as int? ?? 32,
      gameMode: GameMode.values.firstWhere(
        (mode) => mode.name == map['gameMode'],
        orElse: () => GameMode.classic,
      ),
      dailyChallengeKey: map['dailyChallengeKey'] as String?,
      puzzle: _boardFromDynamic(map['puzzle']),
      solution: _boardFromDynamic(map['solution']),
      currentBoard: _boardFromDynamic(map['currentBoard']),
      notes: _notesFromDynamic(map['notes']),
      isNoteMode: map['isNoteMode'] as bool? ?? false,
      isZenMode: map['isZenMode'] as bool? ?? false,
      selectedCell: selectedCell is List && selectedCell.length == 2
          ? (selectedCell[0] as int, selectedCell[1] as int)
          : null,
      isComplete: map['isComplete'] as bool? ?? false,
      startTime: DateTime.fromMillisecondsSinceEpoch(
        map['startTime'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      mistakes: map['mistakes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cluesCount': cluesCount,
      'gameMode': gameMode.name,
      'dailyChallengeKey': dailyChallengeKey,
      'puzzle': _boardToDynamic(puzzle),
      'solution': _boardToDynamic(solution),
      'currentBoard': _boardToDynamic(currentBoard),
      'notes': _notesToDynamic(notes),
      'isNoteMode': isNoteMode,
      'isZenMode': isZenMode,
      'selectedCell': selectedCell == null
          ? null
          : [selectedCell!.$1, selectedCell!.$2],
      'isComplete': isComplete,
      'startTime': startTime.millisecondsSinceEpoch,
      'mistakes': mistakes,
    };
  }

  static SudokuBoard _boardFromDynamic(dynamic rawBoard) {
    final boardRows = rawBoard is List ? rawBoard : const [];

    return List.generate(9, (row) {
      final sourceRow = row < boardRows.length && boardRows[row] is List
          ? boardRows[row] as List
          : const [];

      return List<int?>.generate(9, (col) {
        if (col >= sourceRow.length) return null;
        final value = sourceRow[col];
        return value is int ? value : null;
      });
    });
  }

  static List<List<int?>> _boardToDynamic(SudokuBoard board) {
    return [
      for (final row in board) [for (final value in row) value],
    ];
  }

  static Map<(int, int), Set<int>> _notesFromDynamic(dynamic rawNotes) {
    if (rawNotes is! Map) return {};

    final notes = <(int, int), Set<int>>{};
    for (final entry in rawNotes.entries) {
      final key = entry.key.toString();
      final parts = key.split(':');
      if (parts.length != 2) continue;

      final row = int.tryParse(parts[0]);
      final col = int.tryParse(parts[1]);
      if (row == null || col == null) continue;

      final values = entry.value is List
          ? (entry.value as List).whereType<int>().toSet()
          : <int>{};

      if (values.isNotEmpty) {
        notes[(row, col)] = values;
      }
    }

    return notes;
  }

  static Map<String, List<int>> _notesToDynamic(
    Map<(int, int), Set<int>> notes,
  ) {
    return {
      for (final entry in notes.entries)
        '${entry.key.$1}:${entry.key.$2}': entry.value.toList()..sort(),
    };
  }
}
