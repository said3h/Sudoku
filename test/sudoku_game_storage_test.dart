import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sudoku_app/core/constants/app_constants.dart';
import 'package:sudoku_app/features/sudoku/data/models/saved_sudoku_game.dart';
import 'package:sudoku_app/features/sudoku/data/sudoku_game_storage.dart';
import 'package:sudoku_app/features/sudoku/domain/models/game_mode.dart';
import 'package:sudoku_app/features/sudoku/domain/models/sudoku_board.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDir;

  setUpAll(() async {
    hiveDir = await Directory.systemTemp.createTemp('sudoku_storage_test');
    Hive.init(hiveDir.path);
    await Hive.openBox(AppConstants.hiveBoxSettings);
    await Hive.openBox(AppConstants.hiveBoxStats);
    await Hive.openBox(AppConstants.hiveBoxCurrentGame);
  });

  tearDown(() async {
    await Hive.box(AppConstants.hiveBoxSettings).clear();
    await Hive.box(AppConstants.hiveBoxStats).clear();
    await Hive.box(AppConstants.hiveBoxCurrentGame).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    if (hiveDir.existsSync()) {
      await hiveDir.delete(recursive: true);
    }
  });

  // ---------------------------------------------------------------------------
  // Saved game
  // ---------------------------------------------------------------------------

  test('saved game roundtrip preserves premium session metadata', () {
    final puzzle = _emptyBoard();
    final solution = _emptyBoard()..[0][0] = 4;
    final current = _emptyBoard()..[0][0] = 4;

    SudokuGameStorage.saveGame(
      SavedSudokuGame(
        cluesCount: 26,
        gameMode: GameMode.daily,
        dailyChallengeKey: '2026-04-16',
        puzzle: puzzle,
        solution: solution,
        currentBoard: current,
        notes: {
          (0, 1): {2, 7},
        },
        isNoteMode: true,
        isZenMode: true,
        selectedCell: (0, 1),
        isComplete: false,
        startTime: DateTime(2026, 4, 16, 10, 0),
        mistakes: 2,
      ),
    );

    final restored = SudokuGameStorage.loadSavedGame();

    expect(restored, isNotNull);
    expect(restored!.gameMode, GameMode.daily);
    expect(restored.dailyChallengeKey, '2026-04-16');
    expect(restored.isZenMode, isTrue);
    expect(restored.notes[(0, 1)], {2, 7});
    expect(restored.selectedCell, (0, 1));
  });

  test('hasSavedGame returns false on empty box', () {
    expect(SudokuGameStorage.hasSavedGame(), isFalse);
  });

  test('hasSavedGame returns true after saveGame', () {
    SudokuGameStorage.saveGame(_minimalGame());
    expect(SudokuGameStorage.hasSavedGame(), isTrue);
  });

  test('clearSavedGame removes the saved game', () {
    SudokuGameStorage.saveGame(_minimalGame());
    SudokuGameStorage.clearSavedGame();
    expect(SudokuGameStorage.hasSavedGame(), isFalse);
    expect(SudokuGameStorage.loadSavedGame(), isNull);
  });

  test('loadSavedGame returns null when no game is saved', () {
    expect(SudokuGameStorage.loadSavedGame(), isNull);
  });

  // ---------------------------------------------------------------------------
  // Stats — streak logic
  // ---------------------------------------------------------------------------

  test('daily completion increases streak and daily counters', () {
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 26,
      elapsed: const Duration(minutes: 4, seconds: 12),
      mistakes: 1,
      gameMode: GameMode.daily,
      completedDayKey: '2026-04-15',
    );

    SudokuGameStorage.recordGameCompleted(
      cluesCount: 26,
      elapsed: const Duration(minutes: 3, seconds: 58),
      mistakes: 0,
      gameMode: GameMode.daily,
      completedDayKey: '2026-04-16',
    );

    final stats = SudokuGameStorage.loadStats();

    expect(stats.gamesCompleted, 2);
    expect(stats.dailyChallengesCompleted, 2);
    expect(stats.currentStreak, 2);
    expect(stats.bestStreak, 2);
    expect(stats.totalMistakes, 1);
  });

  test('streak resets to 1 when there is a gap of more than one day', () {
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 5),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-10',
    );
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 6),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-15', // 5-day gap
    );

    expect(SudokuGameStorage.loadStats().currentStreak, 1);
  });

  test('completing on the same day twice does not increment streak', () {
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 5),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-20',
    );
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 4),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-20',
    );

    expect(SudokuGameStorage.loadStats().currentStreak, 1);
  });

  // ---------------------------------------------------------------------------
  // Stats — best times
  // ---------------------------------------------------------------------------

  test('best time is set on first completion', () {
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 5),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-20',
    );

    final stats = SudokuGameStorage.loadStats();
    expect(stats.bestTimesMs['medium'], const Duration(minutes: 5).inMilliseconds);
  });

  test('best time updates when a faster time is recorded', () {
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 5),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-20',
    );
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 3),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-21',
    );

    final stats = SudokuGameStorage.loadStats();
    expect(stats.bestTimesMs['medium'], const Duration(minutes: 3).inMilliseconds);
  });

  test('best time does not update when a slower time is recorded', () {
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 3),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-20',
    );
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 5),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-21',
    );

    final stats = SudokuGameStorage.loadStats();
    expect(stats.bestTimesMs['medium'], const Duration(minutes: 3).inMilliseconds);
  });

  // ---------------------------------------------------------------------------
  // Stats — completedDayKeys
  // ---------------------------------------------------------------------------

  test('completedDayKeys accumulates across multiple completions', () {
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 5),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-21',
    );
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 4),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-22',
    );
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 6),
      mistakes: 1,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-23',
    );

    final stats = SudokuGameStorage.loadStats();
    expect(stats.completedDayKeys,
        containsAll(['2026-04-21', '2026-04-22', '2026-04-23']));
  });

  test('completedDayKeys does not duplicate the same day', () {
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 5),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-23',
    );
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 4),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: '2026-04-23',
    );

    final stats = SudokuGameStorage.loadStats();
    expect(
      stats.completedDayKeys.where((k) => k == '2026-04-23').length,
      1,
    );
  });

  test('completedDayKeys with null dayKey does not add to set', () {
    SudokuGameStorage.recordGameCompleted(
      cluesCount: 32,
      elapsed: const Duration(minutes: 5),
      mistakes: 0,
      gameMode: GameMode.classic,
      completedDayKey: null,
    );

    expect(SudokuGameStorage.loadStats().completedDayKeys, isEmpty);
  });

  // ---------------------------------------------------------------------------
  // Stats — recordGameStarted
  // ---------------------------------------------------------------------------

  test('recordGameStarted increments gamesStarted', () {
    SudokuGameStorage.recordGameStarted();
    SudokuGameStorage.recordGameStarted();
    expect(SudokuGameStorage.loadStats().gamesStarted, 2);
  });
}

SudokuBoard _emptyBoard() =>
    List.generate(9, (_) => List<int?>.filled(9, null));

SavedSudokuGame _minimalGame() => SavedSudokuGame(
      cluesCount: 32,
      gameMode: GameMode.classic,
      dailyChallengeKey: null,
      puzzle: _emptyBoard(),
      solution: _emptyBoard(),
      currentBoard: _emptyBoard(),
      notes: const {},
      isNoteMode: false,
      isZenMode: false,
      selectedCell: null,
      isComplete: false,
      startTime: DateTime.utc(2026, 4, 23),
      mistakes: 0,
    );
