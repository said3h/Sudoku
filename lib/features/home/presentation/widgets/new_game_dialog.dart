import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/difficulty.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/home_providers.dart';

class NewGameDialog extends ConsumerWidget {
  const NewGameDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDifficulty = ref.watch(selectedDifficultyProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.games_outlined, color: AppColors.accent, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Nueva Partida',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Selecciona la dificultad',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ...Difficulty.values.map((difficulty) {
              final isSelected = difficulty == selectedDifficulty;
              return _DifficultyOption(
                difficulty: difficulty,
                isSelected: isSelected,
                onTap: () {
                  ref.read(selectedDifficultyProvider.notifier).state = difficulty;
                },
              ).animate().fade(delay: Duration(milliseconds: 50 * difficulty.index.toInt()))
                  .slideX(begin: 0.2, duration: const Duration(milliseconds: 300));
            }),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(isNewGameDialogOpenProvider.notifier).state = false;
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(isNewGameDialogOpenProvider.notifier).state = false;
                      ref.read(navigateToGameProvider.notifier).state = true;
                    },
                    child: const Text('Jugar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  final Difficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyOption({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? difficulty.color.withOpacity(0.15) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? difficulty.color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              difficulty.icon,
              color: isSelected ? difficulty.color : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? difficulty.color : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    difficulty.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: difficulty.color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
