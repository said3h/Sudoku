import 'package:flutter/material.dart';

import '../../../../core/constants/difficulty.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sudoku/data/models/sudoku_stats.dart';
import '../../../sudoku/data/sudoku_game_storage.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(title: const Text('Estadisticas')),
      body: ValueListenableBuilder(
        valueListenable: SudokuGameStorage.statsListenable(),
        builder: (context, _, __) {
          final stats = SudokuGameStorage.loadStats();
          final completionRate = stats.gamesStarted == 0
              ? 0
              : ((stats.gamesCompleted / stats.gamesStarted) * 100).round();
          final todayKey = DateTime.now().toIso8601String().split('T').first;
          final isDailyCompleted = stats.lastCompletedDayKey == todayKey;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: c.heroGradient,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: c.surfaceBorder),
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
                            sublabel: 'días seguidos',
                            value: '${stats.currentStreak}',
                            accent: c.accent,
                            icon: '🔥',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeroStat(
                            label: 'Mejor racha',
                            value: '${stats.bestStreak}',
                            accent: c.accentBlue,
                            icon: '⚡',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HeroStat(
                            label: 'Completados',
                            value: '${stats.dailyChallengesCompleted}',
                            accent: c.success,
                            icon: '🎯',
                          ),
                        ),
                      ],
                    ),
                    if (!isDailyCompleted) ...[
                      const SizedBox(height: 16),
                      _StreakReminder(),
                    ],
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
                    accent: c.accentBlue,
                  ),
                  _MetricCard(
                    label: 'Completadas',
                    value: '${stats.gamesCompleted}',
                    icon: Icons.emoji_events_outlined,
                    accent: c.accent,
                  ),
                  _MetricCard(
                    label: 'Errores',
                    value: '${stats.totalMistakes}',
                    icon: Icons.auto_fix_normal_outlined,
                    accent: c.error,
                  ),
                  _MetricCard(
                    label: 'Exito',
                    value: '$completionRate%',
                    icon: Icons.trending_up_rounded,
                    accent: c.success,
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
    this.sublabel,
    this.icon = '🔥',
  });

  final String label;
  final String value;
  final Color accent;
  final String? sublabel;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontSize: 10,
                ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 2),
            Text(
              sublabel!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: c.textMuted,
                    fontSize: 9,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakReminder extends StatelessWidget {
  const _StreakReminder();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: c.accent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Completa el reto de hoy',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: c.accent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
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
    final c = context.appColors.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.surfaceBorder),
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
    final c = context.appColors.colors;
    final bestTimeMs = stats.bestTimesMs[difficulty.name];
    final bestTime = bestTimeMs == null
        ? '--:--'
        : _formatDuration(Duration(milliseconds: bestTimeMs));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.surfaceBorder),
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
                  color: c.accentBlueLight,
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
