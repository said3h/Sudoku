import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/sudoku_game_provider.dart';
import '../widgets/game_header.dart';
import '../widgets/number_pad.dart';
import '../widgets/sudoku_board_widget.dart';

class GameScreen extends ConsumerWidget {
  final int cluesCount;
  final bool resumeSavedGame;

  const GameScreen({
    super.key,
    required this.cluesCount,
    this.resumeSavedGame = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = GameSessionConfig(
      cluesCount: cluesCount,
      resumeSavedGame: resumeSavedGame,
    );

    ref.listen<SudokuGameState>(sudokuGameProvider(config), (previous, next) {
      if (previous?.isComplete == true || !next.isComplete) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        _showCompletedDialog(context, ref);
      });
    });

    final provider = sudokuGameProvider(config);
    final gameState = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              gameState: gameState,
              onRestart: () => _showRestartDialog(context, notifier),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SudokuBoardWidget(
                    currentBoard: gameState.currentBoard,
                    givenCells: gameState.givenCells,
                    selectedCell: gameState.selectedCell,
                    solution: gameState.solution,
                    notes: gameState.notes,
                    onCellTap: notifier.selectCell,
                  ),
                  NumberPad(
                    isNoteMode: gameState.isNoteMode,
                    onNumberTap: notifier.enterNumber,
                    onClear: notifier.clearCell,
                    onUndo: notifier.undo,
                    onNoteToggle: notifier.toggleNoteMode,
                    onHint: notifier.hint,
                  ),
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
          content: const Text(
            'Se generara un tablero nuevo con la misma dificultad.',
          ),
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

  Future<void> _showCompletedDialog(BuildContext context, WidgetRef ref) async {
    final config = GameSessionConfig(
      cluesCount: cluesCount,
      resumeSavedGame: resumeSavedGame,
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Partida completada'),
          content: const Text(
            'Has resuelto el Sudoku. Que quieres hacer ahora?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Inicio'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(sudokuGameProvider(config).notifier).resetGame();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Nueva'),
            ),
          ],
        );
      },
    );
  }
}
