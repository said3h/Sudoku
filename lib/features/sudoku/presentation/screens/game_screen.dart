import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/feedback_service.dart';
import '../../../../core/theme/app_colors.dart';
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
    ref.listen<SudokuGameState>(sudokuGameProvider(config), (previous, next) async {
      if (previous?.isComplete == true || !next.isComplete) return;

      await ref.read(feedbackServiceProvider).softSuccess();

      if (!context.mounted) return;
      _showCompletedDialog(context, ref, next);
    });

    final provider = sudokuGameProvider(config);
    final gameState = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final feedback = ref.read(feedbackServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              gameState: gameState,
              onBack: context.pop,
              onRestart: () => _showRestartDialog(context, notifier),
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
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 18),
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
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Reiniciar partida'),
          content: const Text('Se generara un tablero nuevo con la misma dificultad.'),
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withOpacity(0.18),
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
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.gradientPrimary,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ).animate().scale(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 18),
                  Text(
                    'Victoria impecable',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.isDailyChallenge
                        ? 'Has completado el reto diario.'
                        : state.isZenMode
                            ? 'Sudoku resuelto en modo zen.'
                            : 'Sudoku completado con acabado premium.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _VictoryMetric(
                          label: 'Tiempo',
                          value: _formatDuration(state.elapsed),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _VictoryMetric(
                          label: state.isZenMode ? 'Modo' : 'Errores',
                          value: state.isZenMode ? 'Zen' : '${state.mistakes}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(sudokuGameProvider(config).notifier).resetGame();
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
            scale: Tween<double>(begin: 0.92, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
