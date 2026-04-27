import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sudoku_app/core/constants/app_constants.dart';
import 'package:sudoku_app/features/sudoku/data/models/daily_challenge_result.dart';
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
    await Hive.openBox(AppConstants.hiveBoxDailyResults);
  });

  tearDown(() async {
    await Hive.box(AppConstants.hiveBoxSettings).clear();
    await Hive.box(AppConstants.hiveBoxStats).clear();
    await Hive.box(AppConstants.hiveBoxCurrentGame).clear();
    await Hive.box(AppConstants.hiveBoxDailyResults).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    if (hiveDir.existsSync()) {
      await hiveDir.delete(recursive: true);
    }
  });

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
        errorCount: 2,
        hasUsedNotes: true,
        hasUsedHint: false,
        isValidRun: true,
      ),
    );

    final restored = SudokuGameStorage.loadSavedGame();

    expect(restored, isNotNull);
    expect(restored!.gameMode, GameMode.daily);
    expect(restored.dailyChallengeKey, '2026-04-16');
    expect(restored.isZenMode, isTrue);
    expect(restored.notes[(0, 1)], {2, 7});
    expect(restored.selectedCell, (0, 1));
    expect(restored.errorCount, 2);
    expect(restored.hasUsedNotes, isTrue);
    expect(restored.hasUsedHint, isFalse);
    expect(restored.isValidRun, isTrue);
  });

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

  test('daily results are saved once per daily challenge key', () {
    const dailyKey = '2026-04-27';
    final firstResult = DailyChallengeResult(
      dailyChallengeKey: dailyKey,
      elapsedTime: const Duration(minutes: 5),
      errorCount: 1,
      hasUsedNotes: true,
      hasUsedHint: false,
      seed: 123,
      isValidRun: true,
      completedAt: DateTime(2026, 4, 27, 10),
    );
    final duplicateResult = DailyChallengeResult(
      dailyChallengeKey: dailyKey,
      elapsedTime: const Duration(minutes: 4),
      errorCount: 0,
      hasUsedNotes: false,
      hasUsedHint: false,
      seed: 123,
      isValidRun: true,
      completedAt: DateTime(2026, 4, 27, 11),
    );

    expect(SudokuGameStorage.saveDailyResult(firstResult), isTrue);
    expect(SudokuGameStorage.saveDailyResult(duplicateResult), isFalse);

    final restored = SudokuGameStorage.loadDailyResult(dailyKey);
    expect(restored, isNotNull);
    expect(restored!.elapsedTime, const Duration(minutes: 5));
    expect(restored.errorCount, 1);
    expect(SudokuGameStorage.loadDailyResults(), hasLength(1));
  });
}

SudokuBoard _emptyBoard() {
  return List.generate(9, (_) => List<int?>.filled(9, null));
}
