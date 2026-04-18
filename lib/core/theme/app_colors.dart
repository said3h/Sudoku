import 'package:flutter/material.dart';

class AppColorScheme {
  const AppColorScheme({
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.accentLight,
    required this.accentSoft,
    required this.accentBlue,
    required this.accentBlueLight,
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.surfaceElevated,
    required this.surfaceBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.boardBackground,
    required this.cellBackground,
    required this.cellSelected,
    required this.cellHighlighted,
    required this.cellPeer,
    required this.cellMatched,
    required this.cellConflict,
    required this.cellConflictSoft,
    required this.cellSuccess,
    required this.givenNumber,
    required this.userNumber,
    required this.noteColor,
    required this.gridLine,
    required this.gridLineThick,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.gradientPrimary,
    required this.gradientBackground,
    required this.heroGradient,
  });

  final Color primary;
  final Color primaryLight;
  final Color accent;
  final Color accentLight;
  final Color accentSoft;
  final Color accentBlue;
  final Color accentBlueLight;
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color surfaceElevated;
  final Color surfaceBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color boardBackground;
  final Color cellBackground;
  final Color cellSelected;
  final Color cellHighlighted;
  final Color cellPeer;
  final Color cellMatched;
  final Color cellConflict;
  final Color cellConflictSoft;
  final Color cellSuccess;
  final Color givenNumber;
  final Color userNumber;
  final Color noteColor;
  final Color gridLine;
  final Color gridLineThick;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Gradient gradientPrimary;
  final Gradient gradientBackground;
  final Gradient heroGradient;

  static const dark = AppColorScheme(
    primary: Color(0xFF001E2B),
    primaryLight: Color(0xFFBAE6FD),
    accent: Color(0xFF38BDF8),
    accentLight: Color(0xFF7DD3FC),
    accentSoft: Color(0x2638BDF8),
    accentBlue: Color(0xFF38BDF8),
    accentBlueLight: Color(0xFFBAE6FD),
    background: Color(0xFF020617),
    surface: Color(0xFF0F172A),
    surfaceLight: Color(0xFF1E293B),
    surfaceElevated: Color(0xFF1E293B),
    surfaceBorder: Color(0xFF334155),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textMuted: Color(0xFF64748B),
    boardBackground: Color(0xFF020617),
    cellBackground: Color(0xFF020617),
    cellSelected: Color(0xFF0F172A),
    cellHighlighted: Color(0xFF1E293B),
    cellPeer: Color(0xFF0F172A),
    cellMatched: Color(0x2638BDF8),
    cellConflict: Color(0xFFFFB4AB),
    cellConflictSoft: Color(0x33FFB4AB),
    cellSuccess: Color(0xFF6DEABB),
    givenNumber: Color(0xFFF8FAFC),
    userNumber: Color(0xFF38BDF8),
    noteColor: Color(0xFFCBD5E1),
    gridLine: Color(0xFF334155),
    gridLineThick: Color(0xFF38BDF8),
    error: Color(0xFFFFB4AB),
    success: Color(0xFF6DEABB),
    warning: Color(0xFFBAE6FD),
    info: Color(0xFF38BDF8),
    gradientPrimary: LinearGradient(
      colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientBackground: LinearGradient(
      colors: [Color(0xFF020617), Color(0xFF0F172A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    heroGradient: LinearGradient(
      colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E293B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const light = AppColorScheme(
    primary: Color(0xFF2D2422),
    primaryLight: Color(0xFFFFFBF8),
    accent: Color(0xFFD89A8F),
    accentLight: Color(0xFFFFDAD4),
    accentSoft: Color(0x26D89A8F),
    accentBlue: Color(0xFF8C6B65),
    accentBlueLight: Color(0xFFF4DCD3),
    background: Color(0xFFFAF5F0),
    surface: Color(0xFFFAF5F0),
    surfaceLight: Color(0xFFF8F1EC),
    surfaceElevated: Color(0xFFF3EBE6),
    surfaceBorder: Color(0xFFD4C8C5),
    textPrimary: Color(0xFF2D2422),
    textSecondary: Color(0xFF534340),
    textMuted: Color(0xFF857370),
    boardBackground: Color(0xFFFAF5F0),
    cellBackground: Color(0xFFFAF5F0),
    cellSelected: Color(0xFFE8D5CE),
    cellHighlighted: Color(0xFFF4DCD3),
    cellPeer: Color(0xFFF0E6E3),
    cellMatched: Color(0x26D89A8F),
    cellConflict: Color(0xFFBA1A1A),
    cellConflictSoft: Color(0x22BA1A1A),
    cellSuccess: Color(0xFF8C6B65),
    givenNumber: Color(0xFF2D2422),
    userNumber: Color(0xFFD89A8F),
    noteColor: Color(0xFF534340),
    gridLine: Color(0xFFD4C8C5),
    gridLineThick: Color(0xFFD89A8F),
    error: Color(0xFFBA1A1A),
    success: Color(0xFF8C6B65),
    warning: Color(0xFFA63C2C),
    info: Color(0xFFD89A8F),
    gradientPrimary: LinearGradient(
      colors: [Color(0xFFD89A8F), Color(0xFFF4DCD3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientBackground: LinearGradient(
      colors: [Color(0xFFFAF5F0), Color(0xFFF8F1EC)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    heroGradient: LinearGradient(
      colors: [Color(0xFFFFFBF8), Color(0xFFF4DCD3), Color(0xFFF8F1EC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final AppColorScheme colors;

  const AppColorsExtension({required this.colors});

  @override
  ThemeExtension<AppColorsExtension> copyWith({AppColorScheme? colors}) {
    return AppColorsExtension(colors: colors ?? this.colors);
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return this;
  }

  static const dark = AppColorsExtension(colors: AppColorScheme.dark);
  static const light = AppColorsExtension(colors: AppColorScheme.light);
}

extension AppColorsExtensionBuildContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.dark;
}
