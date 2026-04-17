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
    final c = context.appColors.colors;

    final isDailyCompleted = stats.lastCompletedDayKey == todayKey;
    final hasSavedGame = savedGame != null && !savedGame.isComplete;
    final shouldShowResume = hasSavedGame && !savedGame.isZenMode;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: c.gradientBackground,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.accentBlue.withOpacity(0.08),
                      Colors.transparent,
                      c.accent.withOpacity(0.05),
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
                  _AppHeader(
                    streak: stats.currentStreak,
                    level: _calculateLevel(stats.gamesCompleted),
                  ),
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
                    hasSavedGame: hasSavedGame,
                  ),
                  const SizedBox(height: 18),
                  _WeeklyProgress(stats: stats),
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

  int _calculateLevel(int gamesCompleted) {
    if (gamesCompleted < 5) return 1;
    if (gamesCompleted < 15) return 2;
    if (gamesCompleted < 30) return 3;
    if (gamesCompleted < 50) return 4;
    if (gamesCompleted < 100) return 5;
    return 6;
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
  const _AppHeader({required this.streak, required this.level});

  final int streak;
  final int level;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.surfaceBorder),
          ),
          child: Icon(
            Icons.grid_view_rounded,
            color: c.textPrimary,
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
                      color: c.textMuted,
                    ),
              ),
            ],
          ),
        ),
        _LevelBadge(level: level),
        const SizedBox(width: 8),
        if (streak > 0) _StreakBadge(streak: streak),
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: c.accentLight,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$level',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.accent.withOpacity(0.2),
            c.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: c.accent.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: c.accent,
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
    final c = context.appColors.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: isCompleted
              ? LinearGradient(
                  colors: [
                    c.success.withOpacity(0.12),
                    c.success.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : c.heroGradient,
          border: Border.all(
            color: isCompleted ? c.success.withOpacity(0.25) : c.surfaceBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? c.success.withOpacity(0.1)
                  : c.accentBlue.withOpacity(0.15),
              blurRadius: 32,
              spreadRadius: -8,
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
                        ? c.success.withOpacity(0.2)
                        : c.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.local_fire_department_rounded,
                    color: isCompleted ? c.success : c.accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompleted ? 'Reto de hoy' : 'Reto de hoy',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isCompleted ? c.success : c.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted
                            ? 'Completado · Mañana mas'
                            : '1 puzzle · 1 oportunidad',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isCompleted
                                  ? c.success.withOpacity(0.8)
                                  : c.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  color: isCompleted ? c.success : c.accent,
                  size: 26,
                ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              _CountdownTimer(timeUntilMidnight: timeUntilMidnight),
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
    final c = context.appColors.colors;
    final hours = timeUntilMidnight.inHours;
    final minutes = timeUntilMidnight.inMinutes.remainder(60);
    final seconds = timeUntilMidnight.inSeconds.remainder(60);

    return Row(
      children: [
        Text(
          'Siguiente',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: c.textMuted,
              ),
        ),
        const SizedBox(width: 10),
        _Digit(value: hours),
        Text(':', style: TextStyle(color: c.textMuted)),
        _Digit(value: minutes),
        Text(':', style: TextStyle(color: c.textMuted)),
        _Digit(value: seconds),
      ],
    );
  }
}

class _Digit extends StatelessWidget {
  const _Digit({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: c.surfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value.toString().padLeft(2, '0'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _WeeklyProgress extends StatelessWidget {
  const _WeeklyProgress({required this.stats});

  final SudokuStats stats;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    final weekDays = _getWeekDays();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays.map((day) {
          final isCompleted = day['key'] == stats.lastCompletedDayKey;
          final isToday = day['isToday'] == true;

          return Column(
            children: [
              Text(
                day['label'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isToday ? c.accent : c.textMuted,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 10,
                    ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? c.success
                      : isToday
                          ? c.accent.withOpacity(0.3)
                          : c.surfaceLight,
                  border:
                      isToday ? Border.all(color: c.accent, width: 1.5) : null,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _getWeekDays() {
    final now = DateTime.now();
    final labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final key = date.toIso8601String().split('T').first;
      return {
        'label': labels[date.weekday - 1],
        'key': key,
        'isToday': index == 6,
      };
    });
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
    final c = context.appColors.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.accentBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.play_circle_outline_rounded,
                color: c.accentBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continuar partida',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Retoma donde lo dejaste',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: c.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _getModeColor(context).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getModeLabel(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getModeColor(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getModeColor(BuildContext context) {
    final c = context.appColors.colors;
    if (gameMode == GameMode.daily) return c.accent;
    if (isZenMode) return c.success;
    return c.accentBlue;
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
    required this.hasSavedGame,
  });

  final int currentStreak;
  final bool isDailyCompleted;
  final bool hasSavedGame;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getColor(context),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _getMessage(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getColor(context),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    if (isDailyCompleted) return Icons.celebration_outlined;
    if (hasSavedGame) return Icons.play_arrow_rounded;
    if (currentStreak > 0) return Icons.local_fire_department_outlined;
    return Icons.trending_up_rounded;
  }

  Color _getColor(BuildContext context) {
    final c = context.appColors.colors;
    if (isDailyCompleted) return c.success;
    if (hasSavedGame) return c.accentBlue;
    if (currentStreak > 0) return c.accent;
    return c.textSecondary;
  }

  String _getMessage() {
    if (isDailyCompleted && currentStreak > 1) {
      return 'Racha de $currentStreak dias';
    }
    if (isDailyCompleted) return 'Reto completado';
    if (hasSavedGame) return 'Continua tu partida';
    if (currentStreak > 0) return 'Mantén tu racha de $currentStreak dias';
    return 'Completa el reto diario para empezar tu racha';
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
        const SizedBox(width: 8),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.timer_outlined,
            value: bestTime,
            label: 'Mejor tiempo',
          ),
        ),
        const SizedBox(width: 8),
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
    final c = context.appColors.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: c.textMuted, size: 16),
          const SizedBox(height: 6),
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
                  color: c.textMuted,
                  fontSize: 9,
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
    final c = context.appColors.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NUEVA PARTIDA',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                letterSpacing: 1.8,
                color: c.textMuted,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _DifficultyChip(
              difficulty: Difficulty.easy,
              onTap: onStartNew,
            ),
            const SizedBox(width: 8),
            _DifficultyChip(
              difficulty: Difficulty.medium,
              onTap: onStartNew,
            ),
            const SizedBox(width: 8),
            _DifficultyChip(
              difficulty: Difficulty.hard,
              onTap: onStartNew,
            ),
            const SizedBox(width: 8),
            _DifficultyChip(
              difficulty: Difficulty.expert,
              onTap: onStartNew,
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
    required this.onTap,
  });

  final Difficulty difficulty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: difficulty.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: difficulty.color.withOpacity(0.2),
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
    final c = context.appColors.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.surfaceBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c.textMuted, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
