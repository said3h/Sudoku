import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.isNoteMode,
    required this.onNumberTap,
    required this.onClear,
    required this.onUndo,
    required this.onNoteToggle,
    required this.onHint,
  });

  final bool isNoteMode;
  final ValueChanged<int> onNumberTap;
  final VoidCallback onClear;
  final VoidCallback onUndo;
  final VoidCallback onNoteToggle;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.surfaceBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
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
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.backspace_rounded,
                  label: 'Borrar',
                  onTap: onClear,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  onTap: onUndo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_note_rounded,
                  label: 'Notas',
                  onTap: onNoteToggle,
                  isActive: isNoteMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.lightbulb_outline_rounded,
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
  const _NumberButton({
    required this.number,
    required this.onTap,
  });

  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: c.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.surfaceBorder),
          ),
          child: Center(
            child: Text(
              '$number',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: c.accentBlue,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    final color = isActive ? c.accent : c.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          decoration: BoxDecoration(
            color: isActive ? c.accentSoft : c.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive ? c.accent : c.surfaceBorder,
              width: isActive ? 1.5 : 0.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: c.accent.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 20, color: color),
                  if (isActive)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.accent,
                          border: Border.all(color: c.surface, width: 1),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
