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
      appBar: AppBar(title: const Text('Estadisticas')),
      body: ValueListenableBuilder(
        valueListenable: SudokuGameStorage.statsListenable(),
        builder: (context, _, __) {
          final stats = SudokuGameStorage.loadStats();
          final completionRate = stats.gamesStarted == 0
              ? 0
              : ((stats.gamesCompleted / stats.gamesStarted) * 100).round();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rendimiento premium',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Seguimiento real de progreso, constancia y mejores tiempos.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroStat(
                            label: 'Racha',
                            value: '${stats.currentStreak}',
                            accent: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeroStat(
                            label: 'Mejor racha',
                            value: '${stats.bestStreak}',
                            accent: AppColors.accentBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeroStat(
                            label: 'Daily',
                            value: '${stats.dailyChallengesCompleted}',
                            accent: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.25,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  _MetricCard(
                    label: 'Iniciadas',
                    value: '${stats.gamesStarted}',
                    icon: Icons.play_circle_outline_rounded,
                    accent: AppColors.accentBlue,
                  ),
                  _MetricCard(
                    label: 'Completadas',
                    value: '${stats.gamesCompleted}',
                    icon: Icons.emoji_events_outlined,
                    accent: AppColors.accent,
                  ),
                  _MetricCard(
                    label: 'Errores',
                    value: '${stats.totalMistakes}',
                    icon: Icons.auto_fix_normal_outlined,
                    accent: AppColors.error,
                  ),
                  _MetricCard(
                    label: 'Exito',
                    value: '$completionRate%',
                    icon: Icons.trending_up_rounded,
                    accent: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Mejores tiempos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...Difficulty.values.map((difficulty) {
                return _BestTimeTile(
                  difficulty: difficulty,
                  stats: stats,
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: accent),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BestTimeTile extends StatelessWidget {
  const _BestTimeTile({
    required this.difficulty,
    required this.stats,
  });

  final Difficulty difficulty;
  final SudokuStats stats;

  @override
  Widget build(BuildContext context) {
    final bestTimeMs = stats.bestTimesMs[difficulty.name];
    final bestTime = bestTimeMs == null
        ? '--:--'
        : _formatDuration(Duration(milliseconds: bestTimeMs));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: difficulty.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(difficulty.icon, color: difficulty.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              difficulty.displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            bestTime,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.accentBlueLight,
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
