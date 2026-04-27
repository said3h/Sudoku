import '../../domain/models/game_result.dart';

class DailyChallengeResult {
  const DailyChallengeResult({
    required this.dailyChallengeKey,
    required this.elapsedTime,
    required this.errorCount,
    required this.hasUsedNotes,
    required this.hasUsedHint,
    required this.seed,
    required this.isValidRun,
    required this.completedAt,
  });

  final String dailyChallengeKey;
  final Duration elapsedTime;
  final int errorCount;
  final bool hasUsedNotes;
  final bool hasUsedHint;
  final int? seed;
  final bool isValidRun;
  final DateTime completedAt;

  factory DailyChallengeResult.fromGameResult({
    required String dailyChallengeKey,
    required GameResult gameResult,
    required DateTime completedAt,
  }) {
    return DailyChallengeResult(
      dailyChallengeKey: dailyChallengeKey,
      elapsedTime: gameResult.elapsedTime,
      errorCount: gameResult.errorCount,
      hasUsedNotes: gameResult.hasUsedNotes,
      hasUsedHint: gameResult.hasUsedHint,
      seed: gameResult.seed,
      isValidRun: gameResult.isValidRun,
      completedAt: completedAt,
    );
  }

  factory DailyChallengeResult.fromMap(Map<dynamic, dynamic> rawMap) {
    final map = Map<dynamic, dynamic>.from(rawMap);
    return DailyChallengeResult(
      dailyChallengeKey: map['dailyChallengeKey'] as String? ?? '',
      elapsedTime: Duration(milliseconds: map['elapsedTimeMs'] as int? ?? 0),
      errorCount: map['errorCount'] as int? ?? 0,
      hasUsedNotes: map['hasUsedNotes'] as bool? ?? false,
      hasUsedHint: map['hasUsedHint'] as bool? ?? false,
      seed: map['seed'] as int?,
      isValidRun: map['isValidRun'] as bool? ?? true,
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        map['completedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyChallengeKey': dailyChallengeKey,
      'elapsedTimeMs': elapsedTime.inMilliseconds,
      'errorCount': errorCount,
      'hasUsedNotes': hasUsedNotes,
      'hasUsedHint': hasUsedHint,
      'seed': seed,
      'isValidRun': isValidRun,
      'completedAt': completedAt.millisecondsSinceEpoch,
    };
  }
}
