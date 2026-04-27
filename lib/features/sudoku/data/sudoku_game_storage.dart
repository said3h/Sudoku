import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/difficulty.dart';
import '../domain/models/game_mode.dart';
import 'models/daily_challenge_result.dart';
import 'models/saved_sudoku_game.dart';
import 'models/sudoku_stats.dart';

class SudokuGameStorage {
  SudokuGameStorage._();

  static const String currentGameKey = 'active_game';
  static const String statsKey = 'summary';

  static Box get _currentGameBox => Hive.box(AppConstants.hiveBoxCurrentGame);
  static Box get _statsBox => Hive.box(AppConstants.hiveBoxStats);
  static Box get _dailyResultsBox => Hive.box(AppConstants.hiveBoxDailyResults);

  static ValueListenable<Box> currentGameListenable() {
    return _currentGameBox.listenable(keys: [currentGameKey]);
  }

  static bool hasSavedGame() {
    return _currentGameBox.containsKey(currentGameKey);
  }

  static SavedSudokuGame? loadSavedGame() {
    final raw = _currentGameBox.get(currentGameKey);
    if (raw is! Map) return null;

    return SavedSudokuGame.fromMap(raw);
  }

  static void saveGame(SavedSudokuGame game) {
    _currentGameBox.put(currentGameKey, game.toMap());
  }

  static void clearSavedGame() {
    _currentGameBox.delete(currentGameKey);
  }

  static Future<void> flush() async {
    await _currentGameBox.flush();
    await _statsBox.flush();
    await _dailyResultsBox.flush();
  }

  static List<DailyChallengeResult> loadDailyResults() {
    return _dailyResultsBox.values
        .whereType<Map>()
        .map(DailyChallengeResult.fromMap)
        .where((result) => result.dailyChallengeKey.isNotEmpty)
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  static DailyChallengeResult? loadDailyResult(String dailyChallengeKey) {
    final raw = _dailyResultsBox.get(dailyChallengeKey);
    if (raw is! Map) return null;

    return DailyChallengeResult.fromMap(raw);
  }

  static bool hasDailyResult(String dailyChallengeKey) {
    return _dailyResultsBox.containsKey(dailyChallengeKey);
  }

  static bool saveDailyResult(DailyChallengeResult result) {
    if (_dailyResultsBox.containsKey(result.dailyChallengeKey)) {
      return false;
    }

    _dailyResultsBox.put(result.dailyChallengeKey, result.toMap());
    return true;
  }

  static SudokuStats loadStats() {
    final raw = _statsBox.get(statsKey);
    if (raw is! Map) return const SudokuStats();

    return SudokuStats.fromMap(raw);
  }

  static ValueListenable<Box> statsListenable() {
    return _statsBox.listenable(keys: [statsKey]);
  }

  static void recordGameStarted() {
    final stats = loadStats();
    _statsBox.put(
      statsKey,
      stats.copyWith(gamesStarted: stats.gamesStarted + 1).toMap(),
    );
  }

  static void recordGameCompleted({
    required int cluesCount,
    required Duration elapsed,
    required int mistakes,
    required GameMode gameMode,
    required String? completedDayKey,
  }) {
    final stats = loadStats();
    final difficultyKey = _difficultyKey(cluesCount);
    final bestTimes = Map<String, int>.from(stats.bestTimesMs);
    final elapsedMs = elapsed.inMilliseconds;
    final bestTime = bestTimes[difficultyKey];
    final streak = _nextStreak(
      currentStreak: stats.currentStreak,
      previousDayKey: stats.lastCompletedDayKey,
      completedDayKey: completedDayKey,
    );

    if (bestTime == null || elapsedMs < bestTime) {
      bestTimes[difficultyKey] = elapsedMs;
    }

    _statsBox.put(
      statsKey,
      stats
          .copyWith(
            gamesCompleted: stats.gamesCompleted + 1,
            totalMistakes: stats.totalMistakes + mistakes,
            currentStreak: streak,
            bestStreak: streak > stats.bestStreak ? streak : stats.bestStreak,
            dailyChallengesCompleted: stats.dailyChallengesCompleted +
                (gameMode == GameMode.daily ? 1 : 0),
            lastCompletedDayKey: completedDayKey,
            bestTimesMs: bestTimes,
          )
          .toMap(),
    );
  }

  static int _nextStreak({
    required int currentStreak,
    required String? previousDayKey,
    required String? completedDayKey,
  }) {
    if (completedDayKey == null) {
      return currentStreak;
    }

    if (previousDayKey == completedDayKey) {
      return currentStreak;
    }

    if (previousDayKey == null) {
      return 1;
    }

    final previous = DateTime.tryParse(previousDayKey);
    final completed = DateTime.tryParse(completedDayKey);
    if (previous == null || completed == null) {
      return 1;
    }

    final dayDifference = completed.difference(previous).inDays;
    if (dayDifference == 1) {
      return currentStreak + 1;
    }
    if (dayDifference <= 0) {
      return currentStreak;
    }
    return 1;
  }

  static String _difficultyKey(int cluesCount) {
    return Difficulty.values
        .firstWhere(
          (difficulty) => difficulty.cluesCount == cluesCount,
          orElse: () => Difficulty.medium,
        )
        .name;
  }
}
