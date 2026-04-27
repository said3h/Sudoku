import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/feedback_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/sudoku_stats.dart';
import '../../data/sudoku_game_storage.dart';
import '../providers/sudoku_game_provider.dart';
import '../widgets/game_header.dart';
import '../widgets/number_pad.dart';
import '../widgets/sudoku_board_widget.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({
    super.key,
    required this.config,
  });

  final GameSessionConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors.colors;

    ref.listen<SudokuGameState>(sudokuGameProvider(config),
        (previous, next) async {
      if (previous?.isComplete == true || !next.isComplete) return;

      final feedback = ref.read(feedbackServiceProvider);

      if (next.isDailyChallenge) {
        await feedback.victorySpecial();
      } else {
        await feedback.softSuccess();
      }

      if (!context.mounted) return;
      _showCompletedDialog(context, ref, next);
    });

    final provider = sudokuGameProvider(config);
    final gameState = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final feedback = ref.read(feedbackServiceProvider);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              gameState: gameState,
              onBack: context.pop,
              onRestart: gameState.isDailyChallenge
                  ? null
                  : () => _showRestartDialog(context, notifier),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SudokuBoardWidget(
                        currentBoard: gameState.currentBoard,
                        givenCells: gameState.givenCells,
                        selectedCell: gameState.selectedCell,
                        solution: gameState.solution,
                        notes: gameState.notes,
                        isZenMode: gameState.isZenMode,
                        onCellTap: (row, col) async {
                          notifier.selectCell(row, col);
                          await feedback.tap();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  NumberPad(
                    isNoteMode: gameState.isNoteMode,
                    onNumberTap: (number) async {
                      final isMistake = notifier.enterNumber(number);
                      await feedback.tap();
                      if (isMistake) {
                        await feedback.softError();
                      }
                    },
                    onClear: () async {
                      notifier.clearCell();
                      await feedback.tap();
                    },
                    onUndo: () async {
                      notifier.undo();
                      await feedback.tap();
                    },
                    onNoteToggle: () async {
                      notifier.toggleNoteMode();
                      await feedback.tap();
                    },
                    onHint: () async {
                      notifier.hint();
                      await feedback.tap();
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRestartDialog(
    BuildContext context,
    SudokuGameNotifier notifier,
  ) async {
    final c = context.appColors.colors;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: c.surface,
          title: const Text('Reiniciar partida'),
          content: const Text(
              'Se generara un tablero nuevo con la misma dificultad.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                notifier.resetGame();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCompletedDialog(
    BuildContext context,
    WidgetRef ref,
    SudokuGameState state,
  ) async {
    final c = context.appColors.colors;
    final stats = SudokuGameStorage.loadStats();
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    final isDailyStreak =
        state.isDailyChallenge && stats.lastCompletedDayKey == todayKey;
    final isNewRecord = _checkNewRecord(state, stats);

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'victory',
      barrierColor: Colors.black.withOpacity(0.64),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: c.surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: state.isDailyChallenge
                      ? c.success.withOpacity(0.15)
                      : c.accentBlue.withOpacity(0.15),
                  blurRadius: 32,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _VictoryIcon(isDailyChallenge: state.isDailyChallenge),
                  const SizedBox(height: 16),
                  Text(
                    _getVictoryTitle(state),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getVictorySubtitle(state, isDailyStreak),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: c.textSecondary,
                        ),
                  ),
                  if (state.isDailyChallenge) ...[
                    const SizedBox(height: 12),
                    _DailyStreakReward(
                      streak: stats.currentStreak,
                      isMaintained: isDailyStreak,
                    ),
                  ],
                  if (isNewRecord) ...[
                    const SizedBox(height: 12),
                    _NewRecordBadge(),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _VictoryMetric(
                          label: 'Tiempo',
                          value: _formatDuration(state.elapsed),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _VictoryMetric(
                          label: state.isZenMode ? 'Modo' : 'Errores',
                          value: state.isZenMode ? 'Zen' : '${state.mistakes}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.go('/stats');
                          },
                          child: const Text('Stats'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(sudokuGameProvider(config).notifier)
                                .resetGame();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Nueva'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  bool _checkNewRecord(SudokuGameState state, SudokuStats stats) {
    if (state.isZenMode) return false;
    final key = _difficultyKey(state.cluesCount);
    final currentBest = stats.bestTimesMs[key];
    if (currentBest == null) return true;
    return state.elapsed.inMilliseconds < currentBest;
  }

  String _difficultyKey(int cluesCount) {
    if (cluesCount >= 40) return 'easy';
    if (cluesCount >= 32) return 'medium';
    if (cluesCount >= 26) return 'hard';
    return 'expert';
  }

  String _getVictoryTitle(SudokuGameState state) {
    if (state.isDailyChallenge) return 'Reto completado';
    if (state.isZenMode) return 'Resuelto';
    return 'Victoria';
  }

  String _getVictorySubtitle(SudokuGameState state, bool isDailyStreak) {
    if (state.isDailyChallenge) {
      return isDailyStreak ? 'Racha mantenida' : 'Reto diario completado';
    }
    if (state.isZenMode) return 'Modo zen completado';
    return 'Sudoku resuelto con precision';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _VictoryIcon extends StatelessWidget {
  const _VictoryIcon({required this.isDailyChallenge});

  final bool isDailyChallenge;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isDailyChallenge
            ? LinearGradient(
                colors: [
                  c.success,
                  c.success.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : c.gradientPrimary,
      ),
      child: Icon(
        isDailyChallenge
            ? Icons.check_circle_rounded
            : Icons.emoji_events_rounded,
        color: isDailyChallenge ? Colors.white : c.primary,
        size: 32,
      ),
    ).animate().scale(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutBack,
        );
  }
}

class _NewRecordBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: c.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.accent.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            color: c.accent,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            'Nuevo record',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.accent,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DailyStreakReward extends StatelessWidget {
  const _DailyStreakReward({
    required this.streak,
    required this.isMaintained,
  });

  final int streak;
  final bool isMaintained;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: c.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.success.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: c.success,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isMaintained ? '+1 dia de racha' : 'Racha mantenida',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.success,
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (streak > 0) ...[
            const SizedBox(width: 6),
            Text(
              '$streak dias',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: c.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.08);
  }
}

class _VictoryMetric extends StatelessWidget {
  const _VictoryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: c.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.textMuted,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
