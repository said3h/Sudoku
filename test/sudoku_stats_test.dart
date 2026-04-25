import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/features/sudoku/data/models/sudoku_stats.dart';

void main() {
  group('SudokuStats defaults', () {
    test('all counters start at zero', () {
      const stats = SudokuStats();
      expect(stats.gamesStarted, 0);
      expect(stats.gamesCompleted, 0);
      expect(stats.totalMistakes, 0);
      expect(stats.currentStreak, 0);
      expect(stats.bestStreak, 0);
      expect(stats.dailyChallengesCompleted, 0);
      expect(stats.lastCompletedDayKey, isNull);
      expect(stats.completedDayKeys, isEmpty);
      expect(stats.bestTimesMs, isEmpty);
    });
  });

  group('SudokuStats.toMap / fromMap', () {
    test('roundtrip preserves completedDayKeys', () {
      const stats = SudokuStats(
        completedDayKeys: {'2026-04-21', '2026-04-22', '2026-04-23'},
      );
      final restored = SudokuStats.fromMap(stats.toMap());
      expect(restored.completedDayKeys,
          {'2026-04-21', '2026-04-22', '2026-04-23'});
    });

    test('fromMap with no completedDayKeys key defaults to empty set', () {
      final map = const SudokuStats(gamesCompleted: 3).toMap()
        ..remove('completedDayKeys');
      final stats = SudokuStats.fromMap(map);
      expect(stats.completedDayKeys, isEmpty);
      expect(stats.gamesCompleted, 3);
    });

    test('roundtrip preserves bestTimesMs', () {
      const stats =
          SudokuStats(bestTimesMs: {'easy': 90000, 'expert': 480000});
      final restored = SudokuStats.fromMap(stats.toMap());
      expect(restored.bestTimesMs['easy'], 90000);
      expect(restored.bestTimesMs['expert'], 480000);
    });

    test('roundtrip preserves streak fields', () {
      const stats = SudokuStats(
        currentStreak: 7,
        bestStreak: 14,
        lastCompletedDayKey: '2026-04-23',
      );
      final restored = SudokuStats.fromMap(stats.toMap());
      expect(restored.currentStreak, 7);
      expect(restored.bestStreak, 14);
      expect(restored.lastCompletedDayKey, '2026-04-23');
    });

    test('roundtrip with empty bestTimesMs stays empty', () {
      final restored = SudokuStats.fromMap(const SudokuStats().toMap());
      expect(restored.bestTimesMs, isEmpty);
    });
  });

  group('SudokuStats.copyWith', () {
    test('updates completedDayKeys without touching other fields', () {
      const original = SudokuStats(
        gamesCompleted: 10,
        completedDayKeys: {'2026-04-20'},
      );
      final updated = original.copyWith(
        completedDayKeys: {'2026-04-20', '2026-04-21'},
      );
      expect(updated.completedDayKeys, {'2026-04-20', '2026-04-21'});
      expect(updated.gamesCompleted, 10);
      expect(original.completedDayKeys, {'2026-04-20'}); // unchanged
    });

    test('null lastCompletedDayKey can be cleared via sentinel', () {
      const original = SudokuStats(lastCompletedDayKey: '2026-04-23');
      // Passing null explicitly exercises the sentinel guard in copyWith.
      final updated = original.copyWith(lastCompletedDayKey: null);
      expect(updated.lastCompletedDayKey, isNull);
    });
  });
}
