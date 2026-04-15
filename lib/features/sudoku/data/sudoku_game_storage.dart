import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/difficulty.dart';
import 'models/saved_sudoku_game.dart';
import 'models/sudoku_stats.dart';

class SudokuGameStorage {
  SudokuGameStorage._();

  static const String currentGameKey = 'active_game';
  static const String statsKey = 'summary';

  static Box get _currentGameBox => Hive.box(AppConstants.hiveBoxCurrentGame);
  static Box get _statsBox => Hive.box(AppConstants.hiveBoxStats);

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
  }) {
    final stats = loadStats();
    final difficultyKey = _difficultyKey(cluesCount);
    final bestTimes = Map<String, int>.from(stats.bestTimesMs);
    final elapsedMs = elapsed.inMilliseconds;
    final bestTime = bestTimes[difficultyKey];

    if (bestTime == null || elapsedMs < bestTime) {
      bestTimes[difficultyKey] = elapsedMs;
    }

    _statsBox.put(
      statsKey,
      stats
          .copyWith(
            gamesCompleted: stats.gamesCompleted + 1,
            totalMistakes: stats.totalMistakes + mistakes,
            bestTimesMs: bestTimes,
          )
          .toMap(),
    );
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
