import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/difficulty.dart';
import '../../../../core/theme/app_colors.dart';

class NewGameDialogResult {
  final Difficulty difficulty;

  const NewGameDialogResult({
    required this.difficulty,
  });
}

class NewGameDialog extends StatefulWidget {
  const NewGameDialog({
    super.key,
    this.initialDifficulty = Difficulty.medium,
  });

  final Difficulty initialDifficulty;

  @override
  State<NewGameDialog> createState() => _NewGameDialogState();
}

class _NewGameDialogState extends State<NewGameDialog> {
  late Difficulty _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: c.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nueva partida',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Elige la dificultad para empezar una sesion premium.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ...Difficulty.values.map((difficulty) {
              final isSelected = difficulty == _selectedDifficulty;
              return _DifficultyOption(
                difficulty: difficulty,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedDifficulty = difficulty),
              )
                  .animate()
                  .fade(
                    delay: Duration(milliseconds: 40 * difficulty.index),
                  )
                  .slideX(
                    begin: 0.08,
                    duration: const Duration(milliseconds: 240),
                  );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        NewGameDialogResult(difficulty: _selectedDifficulty),
                      );
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
  const _DifficultyOption({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  final Difficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? difficulty.color.withOpacity(0.14) : c.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? difficulty.color : c.surfaceBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(difficulty.icon, color: difficulty.color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      difficulty.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: isSelected ? 1 : 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: difficulty.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
