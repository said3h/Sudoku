import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/sudoku_game_provider.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.gameState,
    required this.onBack,
    required this.onRestart,
  });

  final SudokuGameState gameState;
  final VoidCallback onBack;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
      child: Column(
        children: [
          Row(
            children: [
              _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sudoku',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniBadge(
                          label: gameState.isDailyChallenge
                              ? 'Reto diario'
                              : 'Clasico',
                          color: gameState.isDailyChallenge
                              ? c.accentBlue
                              : c.accent,
                        ),
                        if (gameState.isZenMode)
                          _MiniBadge(
                            label: 'Zen',
                            color: c.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              _CircleButton(
                icon: Icons.refresh_rounded,
                onTap: onRestart,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.timer_outlined,
                  accent: c.accentBlue,
                  label: 'Tiempo',
                  valueBuilder: () => _formatDuration(gameState.elapsed),
                  live: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.auto_awesome_rounded,
                  accent: c.accent,
                  label: gameState.isZenMode ? 'Modo' : 'Errores',
                  valueBuilder: () =>
                      gameState.isZenMode ? 'Zen' : '${gameState.mistakes}',
                ),
              ),
            ],
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: c.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.surfaceBorder),
          ),
          child: Icon(icon, size: 18, color: c.textPrimary),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.valueBuilder,
    this.live = false,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String Function() valueBuilder;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  valueBuilder(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!live) return content;

    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 1), (tick) => tick),
      initialData: 0,
      builder: (context, snapshot) => content,
    );
  }
}
