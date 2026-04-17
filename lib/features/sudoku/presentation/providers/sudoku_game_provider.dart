import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_settings_provider.dart';
import '../../data/models/saved_sudoku_game.dart';
import '../../data/sudoku_game_storage.dart';
import '../../domain/models/game_mode.dart';
import '../../domain/models/sudoku_board.dart';
import '../../domain/sudoku_generator.dart';
import '../../domain/sudoku_validator.dart';

const _selectedCellUnset = Object();

class GameSessionConfig {
  final int cluesCount;
  final bool resumeSavedGame;
  final GameMode gameMode;
  final String? dailyChallengeKey;
  final int? seed;
  final bool isZenMode;

  const GameSessionConfig({
    required this.cluesCount,
    this.resumeSavedGame = false,
    this.gameMode = GameMode.classic,
    this.dailyChallengeKey,
    this.seed,
    this.isZenMode = false,
  });

  @override
  bool operator ==(Object other) {
    return other is GameSessionConfig &&
        other.cluesCount == cluesCount &&
        other.resumeSavedGame == resumeSavedGame &&
        other.gameMode == gameMode &&
        other.dailyChallengeKey == dailyChallengeKey &&
        other.seed == seed &&
        other.isZenMode == isZenMode;
  }

  @override
  int get hashCode => Object.hash(
        cluesCount,
        resumeSavedGame,
        gameMode,
        dailyChallengeKey,
        seed,
        isZenMode,
      );
}

class SudokuGameState {
  final int cluesCount;
  final GameMode gameMode;
  final String? dailyChallengeKey;
  final bool isZenMode;
  final SudokuBoard puzzle;
  final SudokuBoard solution;
  final SudokuBoard currentBoard;
  final Set<(int, int)> givenCells;
  final Map<(int, int), Set<int>> notes;
  final bool isNoteMode;
  final (int, int)? selectedCell;
  final bool isComplete;
  final DateTime startTime;
  final int mistakes;

  const SudokuGameState({
    required this.cluesCount,
    required this.gameMode,
    required this.dailyChallengeKey,
    required this.isZenMode,
    required this.puzzle,
    required this.solution,
    required this.currentBoard,
    required this.givenCells,
    required this.notes,
    this.isNoteMode = false,
    this.selectedCell,
    this.isComplete = false,
    required this.startTime,
    this.mistakes = 0,
  });

  bool get isDailyChallenge => gameMode == GameMode.daily;

  Duration get elapsed => DateTime.now().difference(startTime);

  SudokuGameState copyWith({
    int? cluesCount,
    GameMode? gameMode,
    Object? dailyChallengeKey = _selectedCellUnset,
    bool? isZenMode,
    SudokuBoard? puzzle,
    SudokuBoard? solution,
    SudokuBoard? currentBoard,
    Set<(int, int)>? givenCells,
    Map<(int, int), Set<int>>? notes,
    bool? isNoteMode,
    Object? selectedCell = _selectedCellUnset,
    bool? isComplete,
    DateTime? startTime,
    int? mistakes,
  }) {
    return SudokuGameState(
      cluesCount: cluesCount ?? this.cluesCount,
      gameMode: gameMode ?? this.gameMode,
      dailyChallengeKey: identical(dailyChallengeKey, _selectedCellUnset)
          ? this.dailyChallengeKey
          : dailyChallengeKey as String?,
      isZenMode: isZenMode ?? this.isZenMode,
      puzzle: puzzle ?? this.puzzle,
      solution: solution ?? this.solution,
      currentBoard: currentBoard ?? this.currentBoard,
      givenCells: givenCells ?? this.givenCells,
      notes: notes ?? this.notes,
      isNoteMode: isNoteMode ?? this.isNoteMode,
      selectedCell: identical(selectedCell, _selectedCellUnset)
          ? this.selectedCell
          : selectedCell as (int, int)?,
      isComplete: isComplete ?? this.isComplete,
      startTime: startTime ?? this.startTime,
      mistakes: mistakes ?? this.mistakes,
    );
  }
}

class _GameSnapshot {
  final SudokuBoard board;
  final Map<(int, int), Set<int>> notes;
  final (int, int)? selectedCell;
  final int mistakes;
  final bool isComplete;

  const _GameSnapshot({
    required this.board,
    required this.notes,
    required this.selectedCell,
    required this.mistakes,
    required this.isComplete,
  });
}

class SudokuGameNotifier extends StateNotifier<SudokuGameState> {
  SudokuGameNotifier({
    required this.config,
    required this.settingsRef,
  }) : super(_initialize(config)) {
    final didResume = config.resumeSavedGame && SudokuGameStorage.hasSavedGame();
    if (!didResume) {
      SudokuGameStorage.recordGameStarted();
    }

    if (state.isComplete) {
      SudokuGameStorage.clearSavedGame();
    } else {
      _persistProgress();
    }
  }

  final GameSessionConfig config;
  final Ref settingsRef;
  final List<_GameSnapshot> _history = [];

  static SudokuGameState _initialize(GameSessionConfig config) {
    if (config.resumeSavedGame) {
      final savedGame = SudokuGameStorage.loadSavedGame();
      if (savedGame != null && !savedGame.isComplete) {
        return _fromSavedGame(savedGame);
      }
    }

    return _createNewGame(config);
  }

  static SudokuGameState _createNewGame(GameSessionConfig config) {
    final (puzzle, solution) = SudokuGenerator.generatePuzzle(
      config.cluesCount,
      seed: config.seed,
    );

    return SudokuGameState(
      cluesCount: config.cluesCount,
      gameMode: config.gameMode,
      dailyChallengeKey: config.dailyChallengeKey,
      isZenMode: config.isZenMode,
      puzzle: puzzle,
      solution: solution,
      currentBoard: puzzle.clone(),
      givenCells: _deriveGivenCells(puzzle),
      notes: const {},
      startTime: DateTime.now(),
    );
  }

  static SudokuGameState _fromSavedGame(SavedSudokuGame savedGame) {
    return SudokuGameState(
      cluesCount: savedGame.cluesCount,
      gameMode: savedGame.gameMode,
      dailyChallengeKey: savedGame.dailyChallengeKey,
      isZenMode: savedGame.isZenMode,
      puzzle: savedGame.puzzle,
      solution: savedGame.solution,
      currentBoard: savedGame.currentBoard,
      givenCells: _deriveGivenCells(savedGame.puzzle),
      notes: savedGame.notes,
      isNoteMode: savedGame.isNoteMode,
      selectedCell: savedGame.selectedCell,
      isComplete: savedGame.isComplete,
      startTime: savedGame.startTime,
      mistakes: savedGame.mistakes,
    );
  }

  static Set<(int, int)> _deriveGivenCells(SudokuBoard puzzle) {
    final givenCells = <(int, int)>{};
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (puzzle[row][col] != null) {
          givenCells.add((row, col));
        }
      }
    }
    return givenCells;
  }

  void selectCell(int row, int col) {
    if (state.isComplete) return;
    state = state.copyWith(selectedCell: (row, col));
  }

  bool enterNumber(int number) {
    if (state.isComplete || number < 1 || number > 9) return false;

    final selected = state.selectedCell;
    if (selected == null) return false;

    final (row, col) = selected;
    if (state.givenCells.contains((row, col))) return false;

    if (state.isNoteMode) {
      _toggleNote(row, col, number);
      return false;
    }

    return _placeNumber(row, col, number);
  }

  void clearCell() {
    if (state.isComplete) return;

    final selected = state.selectedCell;
    if (selected == null) return;

    final (row, col) = selected;
    if (state.givenCells.contains((row, col))) return;

    final hasValue = state.currentBoard[row][col] != null;
    final hasNotes = state.notes.containsKey((row, col));
    if (!hasValue && !hasNotes) return;

    _pushHistory();

    final newBoard = state.currentBoard.clone();
    newBoard[row][col] = null;

    final notes = _cloneNotes(state.notes);
    notes.remove((row, col));

    _setBoardState(newBoard, notes: notes, mistakes: state.mistakes);
  }

  void toggleNoteMode() {
    state = state.copyWith(isNoteMode: !state.isNoteMode);
    _persistProgress();
  }

  void undo() {
    if (_history.isEmpty) return;

    final wasComplete = state.isComplete;
    final previous = _history.removeLast();
    state = state.copyWith(
      currentBoard: previous.board.clone(),
      notes: _cloneNotes(previous.notes),
      selectedCell: previous.selectedCell,
      mistakes: previous.mistakes,
      isComplete: previous.isComplete,
    );

    _syncPersistence(previouslyComplete: wasComplete);
  }

  void hint() {
    if (state.isComplete) return;

    final selected = state.selectedCell;
    if (selected == null) return;

    final (row, col) = selected;
    if (state.givenCells.contains((row, col))) return;

    final solutionValue = state.solution[row][col];
    if (solutionValue == null || state.currentBoard[row][col] == solutionValue) {
      return;
    }

    _pushHistory();

    final newBoard = state.currentBoard.clone();
    newBoard[row][col] = solutionValue;

    final notes = _cloneNotes(state.notes);
    _clearRelatedNotes(notes, row, col, solutionValue);

    _setBoardState(newBoard, notes: notes, mistakes: state.mistakes);
  }

  void resetGame() {
    _history.clear();
    final isDaily = config.gameMode == GameMode.daily;
    final newSeed = isDaily ? config.seed : Random().nextInt(2147483647);
    state = _createNewGame(
      config.copyWith(
        isZenMode: settingsRef.read(appSettingsProvider).zenModeEnabled,
        seed: newSeed,
      ),
    );
    SudokuGameStorage.recordGameStarted();
    _persistProgress();
  }

  void _toggleNote(int row, int col, int number) {
    if (state.currentBoard[row][col] != null) return;

    _pushHistory();

    final notes = _cloneNotes(state.notes);
    final key = (row, col);

    final cellNotes = notes.putIfAbsent(key, () => <int>{});
    if (cellNotes.contains(number)) {
      cellNotes.remove(number);
      if (cellNotes.isEmpty) {
        notes.remove(key);
      }
    } else {
      cellNotes.add(number);
    }

    state = state.copyWith(notes: notes);
    _persistProgress();
  }

  bool _placeNumber(int row, int col, int number) {
    final currentValue = state.currentBoard[row][col];
    if (currentValue == number) return false;

    _pushHistory();

    final newBoard = state.currentBoard.clone();
    newBoard[row][col] = number;

    final notes = _cloneNotes(state.notes);
    _clearRelatedNotes(notes, row, col, number);

    final isCorrect = state.solution[row][col] == number;
    final mistakes = state.isZenMode || isCorrect
        ? state.mistakes
        : state.mistakes + 1;

    _setBoardState(newBoard, notes: notes, mistakes: mistakes);
    return !isCorrect && !state.isZenMode;
  }

  void _pushHistory() {
    _history.add(
      _GameSnapshot(
        board: state.currentBoard.clone(),
        notes: _cloneNotes(state.notes),
        selectedCell: state.selectedCell,
        mistakes: state.mistakes,
        isComplete: state.isComplete,
      ),
    );
  }

  void _setBoardState(
    SudokuBoard newBoard, {
    required Map<(int, int), Set<int>> notes,
    required int mistakes,
  }) {
    final wasComplete = state.isComplete;
    state = state.copyWith(
      currentBoard: newBoard,
      notes: notes,
      mistakes: mistakes,
      isComplete: SudokuValidator.isBoardSolved(newBoard),
    );

    _syncPersistence(previouslyComplete: wasComplete);
  }

  void _syncPersistence({required bool previouslyComplete}) {
    if (!previouslyComplete && state.isComplete) {
      final completionDay = DateTime.now().toIso8601String().split('T').first;
      SudokuGameStorage.recordGameCompleted(
        cluesCount: state.cluesCount,
        elapsed: state.elapsed,
        mistakes: state.mistakes,
        gameMode: state.gameMode,
        completedDayKey: completionDay,
      );
      SudokuGameStorage.clearSavedGame();
      return;
    }

    if (!state.isComplete) {
      _persistProgress();
    }
  }

  void _persistProgress() {
    SudokuGameStorage.saveGame(
      SavedSudokuGame(
        cluesCount: state.cluesCount,
        gameMode: state.gameMode,
        dailyChallengeKey: state.dailyChallengeKey,
        puzzle: state.puzzle,
        solution: state.solution,
        currentBoard: state.currentBoard,
        notes: state.notes,
        isNoteMode: state.isNoteMode,
        isZenMode: state.isZenMode,
        selectedCell: state.selectedCell,
        isComplete: state.isComplete,
        startTime: state.startTime,
        mistakes: state.mistakes,
      ),
    );
  }

  void _clearRelatedNotes(
    Map<(int, int), Set<int>> notes,
    int row,
    int col,
    int number,
  ) {
    notes.remove((row, col));

    for (int index = 0; index < 9; index++) {
      _removeNote(notes, row, index, number);
      _removeNote(notes, index, col, number);
    }

    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        _removeNote(notes, r, c, number);
      }
    }
  }

  void _removeNote(
    Map<(int, int), Set<int>> notes,
    int row,
    int col,
    int number,
  ) {
    final key = (row, col);
    final cellNotes = notes[key];
    if (cellNotes == null) return;

    cellNotes.remove(number);
    if (cellNotes.isEmpty) {
      notes.remove(key);
    }
  }

  Map<(int, int), Set<int>> _cloneNotes(Map<(int, int), Set<int>> source) {
    return {
      for (final entry in source.entries) entry.key: Set<int>.from(entry.value),
    };
  }
}

extension on GameSessionConfig {
  GameSessionConfig copyWith({
    int? cluesCount,
    bool? resumeSavedGame,
    GameMode? gameMode,
    Object? dailyChallengeKey = _selectedCellUnset,
    Object? seed = _selectedCellUnset,
    bool? isZenMode,
  }) {
    return GameSessionConfig(
      cluesCount: cluesCount ?? this.cluesCount,
      resumeSavedGame: resumeSavedGame ?? this.resumeSavedGame,
      gameMode: gameMode ?? this.gameMode,
      dailyChallengeKey: identical(dailyChallengeKey, _selectedCellUnset)
          ? this.dailyChallengeKey
          : dailyChallengeKey as String?,
      seed: identical(seed, _selectedCellUnset) ? this.seed : seed as int?,
      isZenMode: isZenMode ?? this.isZenMode,
    );
  }
}

final sudokuGameProvider = StateNotifierProvider.autoDispose
    .family<SudokuGameNotifier, SudokuGameState, GameSessionConfig>(
  (ref, config) => SudokuGameNotifier(
    config: config,
    settingsRef: ref,
  ),
);
