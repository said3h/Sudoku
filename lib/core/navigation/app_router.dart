import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../features/sudoku/domain/models/game_mode.dart';
import '../../features/sudoku/presentation/providers/sudoku_game_provider.dart';
import '../../features/sudoku/presentation/screens/game_screen.dart';
import '../constants/app_constants.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: AppConstants.routeHome,
    routes: [
      GoRoute(
        path: AppConstants.routeHome,
        name: 'home',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeGame,
        name: 'game',
        pageBuilder: (context, state) {
          final cluesCount = int.tryParse(
                state.uri.queryParameters['clues'] ?? '',
              ) ??
              AppConstants.difficultyMedium;
          final resume = state.uri.queryParameters['resume'] == 'true';
          final dailyKey = state.uri.queryParameters['dailyKey'];
          final seed = int.tryParse(state.uri.queryParameters['seed'] ?? '');
          final zenMode = state.uri.queryParameters['zen'] == 'true';
          final mode = dailyKey != null ? GameMode.daily : GameMode.classic;

          return _buildPage(
            state: state,
            child: GameScreen(
              config: GameSessionConfig(
                cluesCount: cluesCount,
                resumeSavedGame: resume,
                gameMode: mode,
                dailyChallengeKey: dailyKey,
                seed: seed,
                isZenMode: zenMode,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeStats,
        name: 'stats',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const StatsScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.routeSettings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPage(
          state: state,
          child: const SettingsScreen(),
        ),
      ),
    ],
  );

  static Page<void> _buildPage({
    required GoRouterState state,
    required Widget child,
  }) {
    final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    if (isIos) {
      return CupertinoPage<void>(
        key: state.pageKey,
        fullscreenDialog: false,
        child: state.uri.path == AppConstants.routeHome
            ? child
            : _IosBackSwipeWrapper(child: child),
      );
    }

    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _IosBackSwipeWrapper extends StatefulWidget {
  const _IosBackSwipeWrapper({required this.child});

  final Widget child;

  @override
  State<_IosBackSwipeWrapper> createState() => _IosBackSwipeWrapperState();
}

class _IosBackSwipeWrapperState extends State<_IosBackSwipeWrapper> {
  static const double _edgeWidth = 28;
  static const double _popDistance = 72;

  bool _isTrackingBackSwipe = false;
  double _dragDistance = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (details) {
        _dragDistance = 0;
        _isTrackingBackSwipe = details.localPosition.dx <= _edgeWidth;
      },
      onHorizontalDragUpdate: (details) {
        if (!_isTrackingBackSwipe) return;
        _dragDistance += details.primaryDelta ?? 0;
      },
      onHorizontalDragEnd: (details) {
        if (!_isTrackingBackSwipe) return;
        _isTrackingBackSwipe = false;

        final velocity = details.primaryVelocity ?? 0;
        final shouldPop = _dragDistance > _popDistance || velocity > 450;
        if (shouldPop && context.canPop()) {
          context.pop();
        }
      },
      child: widget.child,
    );
  }
}
