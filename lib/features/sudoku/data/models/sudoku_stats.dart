class SudokuStats {
  final int gamesStarted;
  final int gamesCompleted;
  final int totalMistakes;
  final int currentStreak;
  final int bestStreak;
  final int dailyChallengesCompleted;
  final String? lastCompletedDayKey;
  final Map<String, int> bestTimesMs;

  const SudokuStats({
    this.gamesStarted = 0,
    this.gamesCompleted = 0,
    this.totalMistakes = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.dailyChallengesCompleted = 0,
    this.lastCompletedDayKey,
    this.bestTimesMs = const {},
  });

  SudokuStats copyWith({
    int? gamesStarted,
    int? gamesCompleted,
    int? totalMistakes,
    int? currentStreak,
    int? bestStreak,
    int? dailyChallengesCompleted,
    Object? lastCompletedDayKey = _sentinel,
    Map<String, int>? bestTimesMs,
  }) {
    return SudokuStats(
      gamesStarted: gamesStarted ?? this.gamesStarted,
      gamesCompleted: gamesCompleted ?? this.gamesCompleted,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      dailyChallengesCompleted:
          dailyChallengesCompleted ?? this.dailyChallengesCompleted,
      lastCompletedDayKey: identical(lastCompletedDayKey, _sentinel)
          ? this.lastCompletedDayKey
          : lastCompletedDayKey as String?,
      bestTimesMs: bestTimesMs ?? this.bestTimesMs,
    );
  }

  factory SudokuStats.fromMap(Map<dynamic, dynamic> rawMap) {
    final map = Map<dynamic, dynamic>.from(rawMap);
    final bestTimesRaw = map['bestTimesMs'];

    return SudokuStats(
      gamesStarted: map['gamesStarted'] as int? ?? 0,
      gamesCompleted: map['gamesCompleted'] as int? ?? 0,
      totalMistakes: map['totalMistakes'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      bestStreak: map['bestStreak'] as int? ?? 0,
      dailyChallengesCompleted: map['dailyChallengesCompleted'] as int? ?? 0,
      lastCompletedDayKey: map['lastCompletedDayKey'] as String?,
      bestTimesMs: bestTimesRaw is Map
          ? {
              for (final entry in bestTimesRaw.entries)
                entry.key.toString(): entry.value as int,
            }
          : const {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gamesStarted': gamesStarted,
      'gamesCompleted': gamesCompleted,
      'totalMistakes': totalMistakes,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'dailyChallengesCompleted': dailyChallengesCompleted,
      'lastCompletedDayKey': lastCompletedDayKey,
      'bestTimesMs': bestTimesMs,
    };
  }
}

const _sentinel = Object();
