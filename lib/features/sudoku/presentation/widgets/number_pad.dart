import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NumberPad extends StatelessWidget {
  final bool isNoteMode;
  final Function(int) onNumberTap;
  final VoidCallback onClear;
  final VoidCallback onUndo;
  final VoidCallback onNoteToggle;
  final VoidCallback onHint;

  const NumberPad({
    super.key,
    required this.isNoteMode,
    required this.onNumberTap,
    required this.onClear,
    required this.onUndo,
    required this.onNoteToggle,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(9, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 8 ? 0 : 6),
                  child: _NumberButton(
                    number: index + 1,
                    onTap: () => onNumberTap(index + 1),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.backspace_outlined,
                  label: 'Borrar',
                  onTap: onClear,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.undo_outlined,
                  label: 'Deshacer',
                  onTap: onUndo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Notas',
                  onTap: onNoteToggle,
                  isActive: isNoteMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.lightbulb_outline,
                  label: 'Pista',
                  onTap: onHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final VoidCallback onTap;

  const _NumberButton({
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceLight),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent.withOpacity(0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.accent : AppColors.surfaceLight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.accent : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isActive ? AppColors.accent : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
