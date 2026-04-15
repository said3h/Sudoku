class SudokuStats {
  final int gamesStarted;
  final int gamesCompleted;
  final int totalMistakes;
  final Map<String, int> bestTimesMs;

  const SudokuStats({
    this.gamesStarted = 0,
    this.gamesCompleted = 0,
    this.totalMistakes = 0,
    this.bestTimesMs = const {},
  });

  SudokuStats copyWith({
    int? gamesStarted,
    int? gamesCompleted,
    int? totalMistakes,
    Map<String, int>? bestTimesMs,
  }) {
    return SudokuStats(
      gamesStarted: gamesStarted ?? this.gamesStarted,
      gamesCompleted: gamesCompleted ?? this.gamesCompleted,
      totalMistakes: totalMistakes ?? this.totalMistakes,
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
      'bestTimesMs': bestTimesMs,
    };
  }
}
