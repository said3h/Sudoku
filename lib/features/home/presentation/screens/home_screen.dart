import 'dart:async';
import 'dart:math';

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
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    // Stable cross-platform seed: encode date as YYYYMMDD integer
    final dailySeed = now.year * 10000 + now.month * 100 + now.day;
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
                    level: _calculateLevel(stats.gamesCompleted),
                  ),
                  const SizedBox(height: 24),
                  _DailyChallengeHero(
                    isCompleted: isDailyCompleted,
                    currentStreak: stats.currentStreak,
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
                  if (shouldShowResume) const SizedBox(height: 20),
                  _WeeklyProgress(stats: stats),
                  const SizedBox(height: 18),
                  _QuickStatsRow(stats: stats),
                  const SizedBox(height: 26),
                  _NewGameButton(
                    onTap: () =>
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
    final newSeed = Random().nextInt(2147483647);
    context.push(
      '${AppConstants.routeGame}?clues=${result.difficulty.cluesCount}'
      '&zen=$zenModeEnabled&resume=false&seed=$newSeed',
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({
    required this.level,
  });

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
        _HeaderActionButton(
          icon: Icons.insights_rounded,
          label: 'Stats',
          onTap: () => context.push(AppConstants.routeStats),
        ),
        const SizedBox(width: 8),
        _HeaderActionButton(
          icon: Icons.tune_rounded,
          label: 'Ajustes',
          onTap: () => context.push(AppConstants.routeSettings),
        ),
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

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
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
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Tooltip(
            message: label,
            child: Icon(
              icon,
              color: c.textSecondary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyChallengeHero extends StatelessWidget {
  const _DailyChallengeHero({
    required this.isCompleted,
    required this.currentStreak,
    required this.timeUntilMidnight,
    required this.onTap,
  });

  final bool isCompleted;
  final int currentStreak;
  final Duration timeUntilMidnight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    final contextualMessage = isCompleted
        ? 'Racha mantenida'
        : currentStreak > 0
            ? 'Completa el reto para mantener tu racha'
            : 'Empieza tu racha hoy';
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
                      const SizedBox(height: 6),
                      Text(
                        contextualMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isCompleted ? c.success : c.accent,
                              fontWeight: FontWeight.w800,
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
        Text(
          ':',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: c.textMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
        _Digit(value: minutes),
        Text(
          ':',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: c.textMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
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
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    final isDailyCompleted = stats.lastCompletedDayKey == todayKey;
    final isAtRisk = stats.currentStreak > 0 && !isDailyCompleted;
    final accent = isDailyCompleted
        ? c.success
        : isAtRisk
            ? c.warning
            : c.accent;
    final status = isDailyCompleted
        ? 'Reto completado'
        : isAtRisk
            ? 'Racha en riesgo'
            : 'Racha activa';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: c.accent.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (stats.currentStreak > 0) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${stats.currentStreak}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'DÍAS',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                          ),
                        ],
                      ),
                      Text(
                        status,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: c.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: c.surfaceBorder.withOpacity(0.5), height: 1),
            const SizedBox(height: 20),
          ],
          Row(
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
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 10,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? c.success
                          : isToday
                              ? c.accent.withOpacity(0.3)
                              : c.surfaceLight,
                      border: isToday
                          ? Border.all(color: c.accent, width: 1.5)
                          : Border.all(color: c.surfaceBorder, width: 0.5),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
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
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

class _NewGameButton extends StatelessWidget {
  const _NewGameButton({required this.onTap});

  final VoidCallback onTap;

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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Nueva partida'),
          ),
        ),
      ],
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
