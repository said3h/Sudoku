import 'package:flutter/material.dart';

import 'app_theme_preset.dart';

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
    accentBlue: Color(0xFF7A5C57), // was 0xFF8C6B65 — 4.40:1 → 5.56:1
    accentBlueLight: Color(0xFFF4DCD3),
    background: Color(0xFFFAF5F0),
    surface: Color(0xFFFAF5F0),
    surfaceLight: Color(0xFFF8F1EC),
    surfaceElevated: Color(0xFFF3EBE6),
    surfaceBorder: Color(0xFFD4C8C5),
    textPrimary: Color(0xFF2D2422),
    textSecondary: Color(0xFF534340),
    textMuted: Color(0xFF6B5250), // was 0xFF857370 — 4.14:1 → 6.58:1
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
    userNumber: Color(0xFFA3533E), // was 0xFFD89A8F — 2.17:1 → 5.01:1
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

  static const cognacIvory = AppColorScheme(
    primary: Color(0xFF451A03),
    primaryLight: Color(0xFFFEF3C7),
    accent: Color(0xFFFEF3C7),
    accentLight: Color(0xFFFDE68A),
    accentSoft: Color(0x26FEF3C7),
    accentBlue: Color(0xFFFDE68A),
    accentBlueLight: Color(0xFFFEF3C7),
    background: Color(0xFF451A03),
    surface: Color(0xFF78350F),
    surfaceLight: Color(0xFF92400E),
    surfaceElevated: Color(0xFF78350F),
    surfaceBorder: Color(0xFF4F4636),
    textPrimary: Color(0xFFFEF3C7),
    textSecondary: Color(0xFFFDE68A),
    textMuted: Color(0xFFD6B76A),
    boardBackground: Color(0xFF451A03),
    cellBackground: Color(0xFF451A03),
    cellSelected: Color(0xFF92400E),
    cellHighlighted: Color(0xFF78350F),
    cellPeer: Color(0xFF78350F),
    cellMatched: Color(0x26FEF3C7),
    cellConflict: Color(0xFFFFB4AB),
    cellConflictSoft: Color(0x33FFB4AB),
    cellSuccess: Color(0xFF6DEABB),
    givenNumber: Color(0xFFFEF3C7),
    userNumber: Color(0xFFFDE68A),
    noteColor: Color(0xFFFDE68A),
    gridLine: Color(0xFF4F4636),
    gridLineThick: Color(0xFFFEF3C7),
    error: Color(0xFFFFB4AB),
    success: Color(0xFF6DEABB),
    warning: Color(0xFFFDE68A),
    info: Color(0xFFFEF3C7),
    gradientPrimary: LinearGradient(
      colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientBackground: LinearGradient(
      colors: [Color(0xFF451A03), Color(0xFF78350F)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    heroGradient: LinearGradient(
      colors: [Color(0xFF451A03), Color(0xFF78350F), Color(0xFF92400E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const emeraldSilver = AppColorScheme(
    primary: Color(0xFF064E3B),
    primaryLight: Color(0xFFD1D5DB),
    accent: Color(0xFFD1D5DB),
    accentLight: Color(0xFFE5E7EB),
    accentSoft: Color(0x26D1D5DB),
    accentBlue: Color(0xFF9CA3AF),
    accentBlueLight: Color(0xFFD1D5DB),
    background: Color(0xFF064E3B),
    surface: Color(0xFF065F46),
    surfaceLight: Color(0xFF047857),
    surfaceElevated: Color(0xFF065F46),
    surfaceBorder: Color(0xFF4F4636),
    textPrimary: Color(0xFFE2E1EE),
    textSecondary: Color(0xFFD1D5DB),
    textMuted: Color(0xFF9CA3AF),
    boardBackground: Color(0xFF064E3B),
    cellBackground: Color(0xFF064E3B),
    cellSelected: Color(0xFF065F46),
    cellHighlighted: Color(0xFF047857),
    cellPeer: Color(0xFF065F46),
    cellMatched: Color(0x26D1D5DB),
    cellConflict: Color(0xFFFFB4AB),
    cellConflictSoft: Color(0x33FFB4AB),
    cellSuccess: Color(0xFF6DEABB),
    givenNumber: Color(0xFFE2E1EE),
    userNumber: Color(0xFFD1D5DB),
    noteColor: Color(0xFFD1D5DB),
    gridLine: Color(0xFF4F4636),
    gridLineThick: Color(0xFFD1D5DB),
    error: Color(0xFFFFB4AB),
    success: Color(0xFF6DEABB),
    warning: Color(0xFFD1D5DB),
    info: Color(0xFFD1D5DB),
    gradientPrimary: LinearGradient(
      colors: [Color(0xFFD1D5DB), Color(0xFF9CA3AF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientBackground: LinearGradient(
      colors: [Color(0xFF064E3B), Color(0xFF065F46)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    heroGradient: LinearGradient(
      colors: [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF047857)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const midnightGold = AppColorScheme(
    primary: Color(0xFF0F172A),
    primaryLight: Color(0xFFF59E0B),
    accent: Color(0xFFF59E0B),
    accentLight: Color(0xFFFCD34D),
    accentSoft: Color(0x26F59E0B),
    accentBlue: Color(0xFFCBD5E1),
    accentBlueLight: Color(0xFFF8FAFC),
    background: Color(0xFF0F172A),
    surface: Color(0xFF0F172A),
    surfaceLight: Color(0xFF1E293B),
    surfaceElevated: Color(0xFF1E293B),
    surfaceBorder: Color(0xFF4F4636),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textMuted: Color(0xFF94A3B8),
    boardBackground: Color(0xFF0F172A),
    cellBackground: Color(0xFF0F172A),
    cellSelected: Color(0xFF1E293B),
    cellHighlighted: Color(0xFF1E293B),
    cellPeer: Color(0xFF1E293B),
    cellMatched: Color(0x26F59E0B),
    cellConflict: Color(0xFFFFB4AB),
    cellConflictSoft: Color(0x33FFB4AB),
    cellSuccess: Color(0xFF6DEABB),
    givenNumber: Color(0xFFF8FAFC),
    userNumber: Color(0xFFF59E0B),
    noteColor: Color(0xFFCBD5E1),
    gridLine: Color(0xFF4F4636),
    gridLineThick: Color(0xFFF59E0B),
    error: Color(0xFFFFB4AB),
    success: Color(0xFF6DEABB),
    warning: Color(0xFFFCD34D),
    info: Color(0xFFCBD5E1),
    gradientPrimary: LinearGradient(
      colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientBackground: LinearGradient(
      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    heroGradient: LinearGradient(
      colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const royalAmethyst = AppColorScheme(
    primary: Color(0xFF1E0B45),
    primaryLight: Color(0xFFC084FC),
    accent: Color(0xFFC084FC),
    accentLight: Color(0xFFE9D5FF),
    accentSoft: Color(0x26C084FC),
    accentBlue: Color(0xFFE9D5FF),
    accentBlueLight: Color(0xFFF3E8FF),
    background: Color(0xFF2E1065),
    surface: Color(0xFF4C1D95),
    surfaceLight: Color(0xFF5B21B6),
    surfaceElevated: Color(0xFF4C1D95),
    surfaceBorder: Color(0xFF4F4636),
    textPrimary: Color(0xFFE2E1EE),
    textSecondary: Color(0xFFE9D5FF),
    textMuted: Color(0xFFC4B5FD),
    boardBackground: Color(0xFF1E0B45),
    cellBackground: Color(0xFF1E0B45),
    cellSelected: Color(0xFF5B21B6),
    cellHighlighted: Color(0xFF4C1D95),
    cellPeer: Color(0xFF3B1675),
    cellMatched: Color(0x26C084FC),
    cellConflict: Color(0xFFFFB4AB),
    cellConflictSoft: Color(0x33FFB4AB),
    cellSuccess: Color(0xFF6DEABB),
    givenNumber: Color(0xFFE2E1EE),
    userNumber: Color(0xFFC084FC),
    noteColor: Color(0xFFE9D5FF),
    gridLine: Color(0xFF4F4636),
    gridLineThick: Color(0xFFC084FC),
    error: Color(0xFFFFB4AB),
    success: Color(0xFF6DEABB),
    warning: Color(0xFFE9D5FF),
    info: Color(0xFFC084FC),
    gradientPrimary: LinearGradient(
      colors: [Color(0xFFC084FC), Color(0xFFE9D5FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientBackground: LinearGradient(
      colors: [Color(0xFF2E1065), Color(0xFF4C1D95)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    heroGradient: LinearGradient(
      colors: [Color(0xFF1E0B45), Color(0xFF3B1675), Color(0xFF5B21B6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static AppColorScheme forPreset(
    AppThemePreset preset,
    Brightness brightness,
  ) {
    return switch (preset) {
      AppThemePreset.adaptive =>
        brightness == Brightness.light ? light : dark,
      AppThemePreset.cognacIvory => cognacIvory,
      AppThemePreset.emeraldSilver => emeraldSilver,
      AppThemePreset.midnightGold => midnightGold,
      AppThemePreset.royalAmethyst => royalAmethyst,
    };
  }
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
