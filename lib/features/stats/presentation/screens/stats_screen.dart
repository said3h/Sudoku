import 'package:flutter/material.dart';

import '../../../../core/constants/difficulty.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sudoku/data/models/sudoku_stats.dart';
import '../../../sudoku/data/sudoku_game_storage.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Estadisticas'),
        backgroundColor: Colors.transparent,
      ),
      body: ValueListenableBuilder(
        valueListenable: SudokuGameStorage.statsListenable(),
        builder: (context, _, __) {
          final stats = SudokuGameStorage.loadStats();
          final completionRate = stats.gamesStarted == 0
              ? 0
              : ((stats.gamesCompleted / stats.gamesStarted) * 100).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu progreso',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.accent,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Resumen de tu rendimiento en Sudoku Premium.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _StatsCard(
                        label: 'Iniciadas',
                        value: '${stats.gamesStarted}',
                        icon: Icons.play_circle_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatsCard(
                        label: 'Completadas',
                        value: '${stats.gamesCompleted}',
                        icon: Icons.emoji_events_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatsCard(
                        label: 'Errores',
                        value: '${stats.totalMistakes}',
                        icon: Icons.error_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatsCard(
                        label: 'Tasa de exito',
                        value: '$completionRate%',
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Mejores tiempos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...Difficulty.values.map(
                  (difficulty) => _BestTimeTile(
                    difficulty: difficulty,
                    stats: stats,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatsCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(height: 20),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _BestTimeTile extends StatelessWidget {
  final Difficulty difficulty;
  final SudokuStats stats;

  const _BestTimeTile({
    required this.difficulty,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final bestTimeMs = stats.bestTimesMs[difficulty.name];
    final bestTime = bestTimeMs == null
        ? '--:--'
        : _formatDuration(Duration(milliseconds: bestTimeMs));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Icon(difficulty.icon, color: difficulty.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              difficulty.displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            bestTime,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accent,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
