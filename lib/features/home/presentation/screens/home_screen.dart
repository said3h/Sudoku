import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/difficulty.dart';
import '../../../../core/providers/home_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/overlay_builder.dart';
import '../../../stats/presentation/screens/stats_screen.dart';
import '../../../sudoku/data/sudoku_game_storage.dart';
import '../../../sudoku/presentation/screens/game_screen.dart';
import '../widgets/new_game_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNewGameOpen = ref.watch(isNewGameDialogOpenProvider);
    final navigateToGame = ref.watch(navigateToGameProvider);

    if (navigateToGame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigateToGameProvider.notifier).state = false;
        final difficulty = ref.read(selectedDifficultyProvider);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameScreen(cluesCount: difficulty.cluesCount),
          ),
        );
      });
    }

    return Scaffold(
      body: OverlayBuilder(
        overlayBuilder: (context) {
          if (isNewGameOpen) {
            return const NewGameDialog();
          }

          return const SizedBox.shrink();
        },
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientBackground,
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradientPrimary,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.grid_on,
                              size: 56,
                              color: AppColors.primary,
                            ),
                          ).animate().scale(
                                duration: const Duration(milliseconds: 600),
                              ),
                          const SizedBox(height: 24),
                          Text(
                            'SUDOKU',
                            style:
                                Theme.of(context).textTheme.displayLarge?.copyWith(
                                      letterSpacing: 8,
                                      color: AppColors.accent,
                                    ),
                          ).animate().fadeIn(
                                delay: const Duration(milliseconds: 200),
                              ),
                          Text(
                            'PREMIUM',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      letterSpacing: 12,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w300,
                                    ),
                          ).animate().fadeIn(
                                delay: const Duration(milliseconds: 400),
                              ),
                        ],
                      ),
                      const SizedBox(height: 80),
                      _PrimaryButton(
                        icon: Icons.play_arrow,
                        label: 'Nueva Partida',
                        subtitle: 'Comienza un nuevo desafio',
                        onPressed: () {
                          ref.read(isNewGameDialogOpenProvider.notifier).state =
                              true;
                        },
                      ).animate().fadeIn(
                            delay: const Duration(milliseconds: 600),
                          ).slideY(
                            begin: 0.3,
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder(
                        valueListenable:
                            SudokuGameStorage.currentGameListenable(),
                        builder: (context, box, child) {
                          final savedGame = SudokuGameStorage.loadSavedGame();
                          final hasSavedGame = savedGame != null;

                          return _SecondaryButton(
                            icon: Icons.history,
                            label: 'Continuar Partida',
                            subtitle: hasSavedGame
                                ? 'Reanuda tu ultimo juego'
                                : 'No hay ninguna partida activa',
                            onPressed: () {
                              if (savedGame == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'No hay partidas guardadas',
                                    ),
                                    backgroundColor: AppColors.textMuted,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GameScreen(
                                    cluesCount: savedGame.cluesCount,
                                    resumeSavedGame: true,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ).animate().fadeIn(
                            delay: const Duration(milliseconds: 800),
                          ).slideY(
                            begin: 0.3,
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 16),
                      _SecondaryButton(
                        icon: Icons.bar_chart,
                        label: 'Estadisticas',
                        subtitle: 'Revisa tu progreso',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StatsScreen(),
                            ),
                          );
                        },
                      ).animate().fadeIn(
                            delay: const Duration(milliseconds: 1000),
                          ).slideY(
                            begin: 0.3,
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 16),
                      _SecondaryButton(
                        icon: Icons.settings,
                        label: 'Ajustes',
                        subtitle: 'Personaliza tu experiencia',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Ajustes proximamente...'),
                              backgroundColor: AppColors.textMuted,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ).animate().fadeIn(
                            delay: const Duration(milliseconds: 1200),
                          ).slideY(
                            begin: 0.3,
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 60),
                      Text(
                        'Dificultad rapida',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: Difficulty.values.map((difficulty) {
                          return _QuickDifficultyChip(difficulty: difficulty)
                              .animate()
                              .fadeIn(
                                delay: Duration(
                                  milliseconds: 1400 + (50 * difficulty.index),
                                ),
                              )
                              .scale();
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickDifficultyChip extends ConsumerWidget {
  final Difficulty difficulty;

  const _QuickDifficultyChip({
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(selectedDifficultyProvider.notifier).state = difficulty;
        ref.read(isNewGameDialogOpenProvider.notifier).state = true;
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: difficulty.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          difficulty.displayName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: difficulty.color,
          ),
        ),
      ),
    );
  }
}
