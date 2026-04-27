import 'game_mode.dart';

class GameResult {
  const GameResult({
    required this.elapsedTime,
    required this.errorCount,
    required this.hasUsedNotes,
    required this.gameMode,
    required this.seed,
    required this.isValidRun,
  });

  final Duration elapsedTime;
  final int errorCount;
  final bool hasUsedNotes;
  final GameMode gameMode;
  final int? seed;
  final bool isValidRun;
}
