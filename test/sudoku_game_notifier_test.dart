import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sudoku_app/core/constants/app_constants.dart';
import 'package:sudoku_app/features/sudoku/domain/models/game_mode.dart';
import 'package:sudoku_app/features/sudoku/presentation/providers/sudoku_game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDir;

  setUpAll(() async {
    hiveDir =
        await Directory.systemTemp.createTemp('sudoku_notifier_test');
    Hive.init(hiveDir.path);
    await Hive.openBox(AppConstants.hiveBoxSettings);
    await Hive.openBox(AppConstants.hiveBoxStats);
    await Hive.openBox(AppConstants.hiveBoxCurrentGame);
  });

  tearDown(() async {
    await Hive.box(AppConstants.hiveBoxStats).clear();
    await Hive.box(AppConstants.hiveBoxCurrentGame).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    if (hiveDir.existsSync()) await hiveDir.delete(recursive: true);
  });

  ProviderContainer _container() => ProviderContainer();

  GameSessionConfig get _config =>
      const GameSessionConfig(cluesCount: 32, seed: 42);

  // Returns the first non-given empty cell, or null if none exists.
  (int, int)? _firstEmpty(SudokuGameState state) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (!state.givenCells.contains((r, c))) return (r, c);
      }
    }
    return null;
  }

  test('initial state has no selected cell', () {
    final container = _container();
    addTearDown(container.dispose);
    final state = container.read(sudokuGameProvider(_config));
    expect(state.selectedCell, isNull);
  });

  test('initial state is not complete', () {
    final container = _container();
    addTearDown(container.dispose);
    final state = container.read(sudokuGameProvider(_config));
    expect(state.isComplete, isFalse);
  });

  test('initial state gameMode is classic', () {
    final container = _container();
    addTearDown(container.dispose);
    final state = container.read(sudokuGameProvider(_config));
    expect(state.gameMode, GameMode.classic);
  });

  test('selectCell updates selectedCell', () {
    final container = _container();
    addTearDown(container.dispose);
    container.read(sudokuGameProvider(_config).notifier).selectCell(3, 4);
    expect(container.read(sudokuGameProvider(_config)).selectedCell, (3, 4));
  });

  test('enterNumber returns false and does nothing for a given cell', () {
    final container = _container();
    addTearDown(container.dispose);
    final state = container.read(sudokuGameProvider(_config));
    final given = state.givenCells.first;
    final notifier = container.read(sudokuGameProvider(_config).notifier);
    notifier.selectCell(given.$1, given.$2);
    final result = notifier.enterNumber(1);
    expect(result, isFalse);
    expect(
      container.read(sudokuGameProvider(_config)).currentBoard[given.$1][given.$2],
      state.currentBoard[given.$1][given.$2],
    );
  });

  test('enterNumber places a number in an empty cell', () {
    final container = _container();
    addTearDown(container.dispose);
    final state = container.read(sudokuGameProvider(_config));
    final cell = _firstEmpty(state);
    expect(cell, isNotNull);
    final (r, c) = cell!;
    container.read(sudokuGameProvider(_config).notifier).selectCell(r, c);
    container.read(sudokuGameProvider(_config).notifier).enterNumber(5);
    expect(
      container.read(sudokuGameProvider(_config)).currentBoard[r][c],
      5,
    );
  });

  test('undo restores the previous board state', () {
    final container = _container();
    addTearDown(container.dispose);
    final state = container.read(sudokuGameProvider(_config));
    final cell = _firstEmpty(state);
    expect(cell, isNotNull);
    final (r, c) = cell!;
    final notifier = container.read(sudokuGameProvider(_config).notifier);
    notifier.selectCell(r, c);
    notifier.enterNumber(5);
    notifier.undo();
    expect(
      container.read(sudokuGameProvider(_config)).currentBoard[r][c],
      isNull,
    );
  });

  test('undo on empty history does nothing', () {
    final container = _container();
    addTearDown(container.dispose);
    final before = container.read(sudokuGameProvider(_config));
    container.read(sudokuGameProvider(_config).notifier).undo();
    final after = container.read(sudokuGameProvider(_config));
    expect(after.currentBoard, before.currentBoard);
  });

  test('clearCell removes an entered value', () {
    final container = _container();
    addTearDown(container.dispose);
    final state = container.read(sudokuGameProvider(_config));
    final cell = _firstEmpty(state);
    expect(cell, isNotNull);
    final (r, c) = cell!;
    final notifier = container.read(sudokuGameProvider(_config).notifier);
    notifier.selectCell(r, c);
    notifier.enterNumber(5);
    notifier.clearCell();
    expect(
      container.read(sudokuGameProvider(_config)).currentBoard[r][c],
      isNull,
    );
  });

  test('clearCell on a given cell does nothing', () {
    final container = _container();
    addTearDown(container.dispose);
    final state = container.read(sudokuGameProvider(_config));
    final given = state.givenCells.first;
    final original = state.currentBoard[given.$1][given.$2];
    final notifier = container.read(sudokuGameProvider(_config).notifier);
    notifier.selectCell(given.$1, given.$2);
    notifier.clearCell();
    expect(
      container.read(sudokuGameProvider(_config)).currentBoard[given.$1][given.$2],
      original,
    );
  });

  test('toggleNoteMode flips between true and false', () {
    final container = _container();
    addTearDown(container.dispose);
    final notifier = container.read(sudokuGameProvider(_config).notifier);
    expect(container.read(sudokuGameProvider(_config)).isNoteMode, isFalse);
    notifier.toggleNoteMode();
    expect(container.read(sudokuGameProvider(_config)).isNoteMode, isTrue);
    notifier.toggleNoteMode();
    expect(container.read(sudokuGameProvider(_config)).isNoteMode, isFalse);
  });

  test('history is capped at 100: cannot undo more than 100 times', () {
    final container = _container();
    addTearDown(container.dispose);
    final state = container.read(sudokuGameProvider(_config));
    final cell = _firstEmpty(state);
    expect(cell, isNotNull);
    final (r, c) = cell!;
    final notifier = container.read(sudokuGameProvider(_config).notifier);
    notifier.selectCell(r, c);

    // Push 110 history entries by cycling through distinct values.
    for (int i = 0; i < 110; i++) {
      notifier.enterNumber((i % 9) + 1);
    }

    int undoCount = 0;
    for (int i = 0; i < 110; i++) {
      final before =
          container.read(sudokuGameProvider(_config)).currentBoard[r][c];
      notifier.undo();
      final after =
          container.read(sudokuGameProvider(_config)).currentBoard[r][c];
      if (before == after) break; // history exhausted
      undoCount++;
    }

    expect(undoCount, lessThanOrEqualTo(100));
  });

  test('hint fills the selected cell with the solution value', () {
    final container = _container();
    addTearDown(container.dispose);
    final state = container.read(sudokuGameProvider(_config));
    final cell = _firstEmpty(state);
    expect(cell, isNotNull);
    final (r, c) = cell!;
    final solution = state.solution[r][c];
    final notifier = container.read(sudokuGameProvider(_config).notifier);
    notifier.selectCell(r, c);
    notifier.hint();
    expect(
      container.read(sudokuGameProvider(_config)).currentBoard[r][c],
      solution,
    );
  });
}
