import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/sudoku_game_provider.dart';

class GameHeader extends StatelessWidget {
  final SudokuGameState gameState;
  final VoidCallback onRestart;

  const GameHeader({
    super.key,
    required this.gameState,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Sudoku',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  gameState.isComplete ? 'Completado' : 'En curso',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: gameState.isComplete
                            ? AppColors.success
                            : AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
          ),
          _InfoChip(
            icon: Icons.error_outline,
            color: AppColors.error,
            label: '${gameState.mistakes}',
          ),
          const SizedBox(width: 8),
          StreamBuilder<int>(
            stream: Stream.periodic(const Duration(seconds: 1), (tick) => tick),
            initialData: 0,
            builder: (context, snapshot) {
              final elapsed = DateTime.now().difference(gameState.startTime);
              final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
              final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');

              return _InfoChip(
                icon: Icons.timer_outlined,
                color: AppColors.accent,
                label: '$minutes:$seconds',
              );
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onRestart,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
