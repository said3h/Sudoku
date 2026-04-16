import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/difficulty.dart';
import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../sudoku/data/models/sudoku_stats.dart';
import '../../../sudoku/data/sudoku_game_storage.dart';
import '../../../sudoku/domain/models/game_mode.dart';
import '../widgets/new_game_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _midnightTimer;
  Duration _timeUntilMidnight = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeUntilMidnight();
    _midnightTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateTimeUntilMidnight();
    });
  }

  void _calculateTimeUntilMidnight() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    setState(() {
      _timeUntilMidnight = tomorrow.difference(now);
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    final dailySeed = todayKey.hashCode;
    final stats = SudokuGameStorage.loadStats();
    final savedGame = SudokuGameStorage.loadSavedGame();

    final isDailyCompleted = stats.lastCompletedDayKey == todayKey;
    final hasSavedGame = savedGame != null && !savedGame.isComplete;
    final isStreakAtRisk = _isStreakAtRisk(stats.lastCompletedDayKey);
    final shouldShowResume = hasSavedGame && !savedGame.isZenMode;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  _AppHeader(streak: stats.currentStreak),
                  const SizedBox(height: 24),
                  _DailyChallengeHero(
                    isCompleted: isDailyCompleted,
                    timeUntilMidnight: _timeUntilMidnight,
                    onTap: () {
                      context.push(
                        '${AppConstants.routeGame}?clues=${Difficulty.hard.cluesCount}'
                        '&dailyKey=$todayKey&seed=$dailySeed'
                        '&zen=${settings.zenModeEnabled}&resume=false',
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  if (shouldShowResume)
                    _ContinueCard(
                      gameMode: savedGame.gameMode,
                      isZenMode: savedGame.isZenMode,
                      onTap: () {
                        context.push(
                          '${AppConstants.routeGame}?clues=${savedGame.cluesCount}'
                          '&resume=true',
                        );
                      },
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.06),
                  if (shouldShowResume) const SizedBox(height: 18),
                  _MotivationalMessage(
                    currentStreak: stats.currentStreak,
                    isDailyCompleted: isDailyCompleted,
                    isStreakAtRisk: isStreakAtRisk,
                    hasSavedGame: hasSavedGame,
                  ),
                  const SizedBox(height: 18),
                  _QuickStatsRow(stats: stats),
                  const SizedBox(height: 26),
                  _NewGameSection(
                    zenEnabled: settings.zenModeEnabled,
                    onStartNew: () =>
                        _startNewGame(context, settings.zenModeEnabled),
                  ),
                  const SizedBox(height: 18),
                  _SecondaryActions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isStreakAtRisk(String? lastCompletedDayKey) {
    if (lastCompletedDayKey == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = yesterday.toIso8601String().split('T').first;
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    return lastCompletedDayKey != todayKey &&
        lastCompletedDayKey != yesterdayKey;
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

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: const Icon(
            Icons.grid_view_rounded,
            color: AppColors.textPrimary,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SUDOKU',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      letterSpacing: 4,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                'Premium Edition',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
        if (streak > 0) _StreakBadge(streak: streak),
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.2),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16))
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                  duration: 2000.ms,
                  color: AppColors.accentLight.withOpacity(0.3)),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeHero extends StatelessWidget {
  const _DailyChallengeHero({
    required this.isCompleted,
    required this.timeUntilMidnight,
    required this.onTap,
  });

  final bool isCompleted;
  final Duration timeUntilMidnight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: isCompleted
              ? LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.15),
                    AppColors.success.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : AppColors.heroGradient,
          border: Border.all(
            color: isCompleted
                ? AppColors.success.withOpacity(0.3)
                : AppColors.surfaceBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.accentBlue.withOpacity(0.18),
              blurRadius: 38,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.local_fire_department_rounded,
                    color: isCompleted ? AppColors.success : AppColors.accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompleted ? 'Reto de hoy completado' : 'Reto de hoy',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isCompleted
                                  ? AppColors.success
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted
                            ? 'Mañana tendras un nuevo desafio'
                            : '1 puzzle · 1 oportunidad',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isCompleted
                                  ? AppColors.success.withOpacity(0.8)
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: isCompleted ? AppColors.success : AppColors.accent,
                  size: 28,
                ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 20),
              _CountdownTimer(timeUntilMidnight: timeUntilMidnight),
            ],
            if (isCompleted) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Racha mantenida',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.96, 0.96));
  }
}

class _CountdownTimer extends StatelessWidget {
  const _CountdownTimer({required this.timeUntilMidnight});

  final Duration timeUntilMidnight;

  @override
  Widget build(BuildContext context) {
    final hours = timeUntilMidnight.inHours;
    final minutes = timeUntilMidnight.inMinutes.remainder(60);
    final seconds = timeUntilMidnight.inSeconds.remainder(60);

    return Row(
      children: [
        Text(
          'Siguiente reto en',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(width: 12),
        _CountdownDigit(value: hours, label: 'h'),
        _CountdownDigit(value: minutes, label: 'm', showColon: true),
        _CountdownDigit(value: seconds, label: 's', showColon: true),
      ],
    );
  }
}

class _CountdownDigit extends StatelessWidget {
  const _CountdownDigit({
    required this.value,
    required this.label,
    this.showColon = false,
  });

  final int value;
  final String label;
  final bool showColon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        if (showColon)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              ':',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.gameMode,
    required this.isZenMode,
    required this.onTap,
  });

  final GameMode gameMode;
  final bool isZenMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.play_circle_outline_rounded,
                color: AppColors.accentBlue,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continuar partida',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Retoma donde lo dejaste',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getModeColor().withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getModeLabel(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getModeColor(),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Color _getModeColor() {
    if (gameMode == GameMode.daily) return AppColors.accent;
    if (isZenMode) return AppColors.success;
    return AppColors.accentBlue;
  }

  String _getModeLabel() {
    if (gameMode == GameMode.daily) return 'Diaria';
    if (isZenMode) return 'Zen';
    return 'Clasica';
  }
}

class _MotivationalMessage extends StatelessWidget {
  const _MotivationalMessage({
    required this.currentStreak,
    required this.isDailyCompleted,
    required this.isStreakAtRisk,
    required this.hasSavedGame,
  });

  final int currentStreak;
  final bool isDailyCompleted;
  final bool isStreakAtRisk;
  final bool hasSavedGame;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(
            _getMessageIcon(),
            color: _getMessageColor(),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getMessage(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getMessageColor(),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMessageIcon() {
    if (isDailyCompleted) return Icons.celebration_rounded;
    if (isStreakAtRisk) return Icons.schedule_rounded;
    if (hasSavedGame) return Icons.play_arrow_rounded;
    return Icons.trending_up_rounded;
  }

  Color _getMessageColor() {
    if (isDailyCompleted) return AppColors.success;
    if (isStreakAtRisk) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String _getMessage() {
    if (isDailyCompleted && currentStreak > 1) {
      return 'Racha de $currentStreak dias. Sigue asi!';
    }
    if (isDailyCompleted) {
      return 'Reto completado! Mañana mas.';
    }
    if (isStreakAtRisk) {
      return 'Tu racha esta en riesgo. Completa el reto hoy!';
    }
    if (hasSavedGame) {
      return 'Tienes una partida en progreso.';
    }
    if (currentStreak > 0) {
      return 'Continua tu racha de $currentStreak dias.';
    }
    return 'Completa el reto diario para empezar tu racha.';
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.stats});

  final SudokuStats stats;

  @override
  Widget build(BuildContext context) {
    final bestTime = _formatBestTime();

    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Icons.emoji_events_outlined,
            value: '${stats.gamesCompleted}',
            label: 'Completadas',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.timer_outlined,
            value: bestTime,
            label: 'Mejor tiempo',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.local_fire_department_outlined,
            value: '${stats.bestStreak}',
            label: 'Mejor racha',
          ),
        ),
      ],
    );
  }

  String _formatBestTime() {
    final allTimes = stats.bestTimesMs.values;
    if (allTimes.isEmpty) return '--:--';
    final minTime = allTimes.reduce((a, b) => a < b ? a : b);
    final duration = Duration(milliseconds: minTime);
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

class _NewGameSection extends StatelessWidget {
  const _NewGameSection({
    required this.zenEnabled,
    required this.onStartNew,
  });

  final bool zenEnabled;
  final VoidCallback onStartNew;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NUEVA PARTIDA',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                letterSpacing: 1.8,
                color: AppColors.textMuted,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DifficultyChip(
                difficulty: Difficulty.easy,
                zenEnabled: zenEnabled,
                onTap: () => onStartNew(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DifficultyChip(
                difficulty: Difficulty.medium,
                zenEnabled: zenEnabled,
                onTap: () => onStartNew(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DifficultyChip(
                difficulty: Difficulty.hard,
                zenEnabled: zenEnabled,
                onTap: () => onStartNew(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DifficultyChip(
                difficulty: Difficulty.expert,
                zenEnabled: zenEnabled,
                onTap: () => onStartNew(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
    required this.difficulty,
    required this.zenEnabled,
    required this.onTap,
  });

  final Difficulty difficulty;
  final bool zenEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: difficulty.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: difficulty.color.withOpacity(0.25),
          ),
        ),
        child: Column(
          children: [
            Icon(difficulty.icon, color: difficulty.color, size: 18),
            const SizedBox(height: 4),
            Text(
              difficulty.displayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: difficulty.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActions extends StatelessWidget {
  const _SecondaryActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SecondaryActionButton(
            icon: Icons.insights_rounded,
            label: 'Stats',
            onTap: () => context.push(AppConstants.routeStats),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SecondaryActionButton(
            icon: Icons.tune_rounded,
            label: 'Ajustes',
            onTap: () => context.push(AppConstants.routeSettings),
          ),
        ),
      ],
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
