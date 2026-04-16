import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/difficulty.dart';
import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sudoku/data/sudoku_game_storage.dart';
import '../../../sudoku/domain/models/game_mode.dart';
import '../widgets/new_game_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    final dailySeed = todayKey.hashCode;
    final savedGame = SudokuGameStorage.loadSavedGame();
    final stats = SudokuGameStorage.loadStats();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.gradientBackground,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentBlue.withOpacity(0.08),
                      Colors.transparent,
                      AppColors.accent.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  _PremiumHero(
                    currentStreak: stats.currentStreak,
                    zenEnabled: settings.zenModeEnabled,
                  ),
                  const SizedBox(height: 26),
                  _PrimaryActionCard(
                    icon: Icons.play_arrow_rounded,
                    title: 'Nueva partida',
                    subtitle: 'Comienza una sesion elegante y fluida.',
                    onTap: () => _startNewGame(context, settings.zenModeEnabled),
                  ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.06),
                  const SizedBox(height: 14),
                  _SecondaryActionCard(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Reto diario',
                    subtitle: 'Puzzle del dia con semilla fija y progreso propio.',
                    trailing: Text(
                      todayKey.substring(5),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () {
                      context.push(
                        '${AppConstants.routeGame}?clues=${Difficulty.hard.cluesCount}'
                        '&dailyKey=$todayKey&seed=$dailySeed'
                        '&zen=${settings.zenModeEnabled}&resume=false',
                      );
                    },
                  ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.06),
                  const SizedBox(height: 14),
                  _SecondaryActionCard(
                    icon: Icons.history_rounded,
                    title: 'Continuar partida',
                    subtitle: savedGame == null
                        ? 'No hay ninguna sesion activa.'
                        : 'Retoma exactamente donde la dejaste.',
                    trailing: savedGame == null
                        ? null
                        : _ModeBadge(
                            label: savedGame.gameMode == GameMode.daily
                                ? 'Diaria'
                                : savedGame.isZenMode
                                    ? 'Zen'
                                    : 'Clasica',
                          ),
                    onTap: () {
                      if (savedGame == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No hay partidas guardadas'),
                          ),
                        );
                        return;
                      }
                      context.push(
                        '${AppConstants.routeGame}?clues=${savedGame.cluesCount}'
                        '&resume=true',
                      );
                    },
                  ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.06),
                  const SizedBox(height: 14),
                  _SecondaryActionCard(
                    icon: Icons.insights_rounded,
                    title: 'Estadisticas',
                    subtitle: 'Mejores tiempos, streak y vision global.',
                    onTap: () => context.push(AppConstants.routeStats),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.06),
                  const SizedBox(height: 14),
                  _SecondaryActionCard(
                    icon: Icons.tune_rounded,
                    title: 'Ajustes',
                    subtitle: 'Haptics, sonido y modo zen por defecto.',
                    onTap: () => context.push(AppConstants.routeSettings),
                  ).animate().fadeIn(delay: 360.ms).slideY(begin: 0.06),
                  const SizedBox(height: 26),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Dificultad rapida',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            letterSpacing: 1.8,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: Difficulty.values.map((difficulty) {
                      return ActionChip(
                        backgroundColor: difficulty.color.withOpacity(0.14),
                        side: BorderSide(color: difficulty.color.withOpacity(0.26)),
                        label: Text(
                          difficulty.displayName,
                          style: TextStyle(color: difficulty.color),
                        ),
                        onPressed: () {
                          context.push(
                            '${AppConstants.routeGame}?clues=${difficulty.cluesCount}'
                            '&zen=${settings.zenModeEnabled}&resume=false',
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startNewGame(BuildContext context, bool zenModeEnabled) async {
    final result = await showDialog<NewGameDialogResult>(
      context: context,
      builder: (_) => const NewGameDialog(),
    );

    if (result == null || !context.mounted) return;
    context.push(
      '${AppConstants.routeGame}?clues=${result.difficulty.cluesCount}'
      '&zen=$zenModeEnabled&resume=false',
    );
  }
}

class _PremiumHero extends StatelessWidget {
  const _PremiumHero({
    required this.currentStreak,
    required this.zenEnabled,
  });

  final int currentStreak;
  final bool zenEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: AppColors.heroGradient,
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withOpacity(0.18),
            blurRadius: 38,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  size: 34,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUDOKU',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            letterSpacing: 6,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Premium Edition',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.accentLight,
                          ),
                    ),
                  ],
                ),
              ),
              _ModeBadge(label: zenEnabled ? 'Zen on' : 'Classic'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  title: 'Streak',
                  value: '$currentStreak dias',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _HeroMetric(
                  title: 'Sensacion',
                  value: 'Ultra smooth',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: AppColors.gradientPrimary,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryLight,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionCard extends StatelessWidget {
  const _SecondaryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.accentBlue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 10),
              ],
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.textMuted, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.accentBlueLight,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
