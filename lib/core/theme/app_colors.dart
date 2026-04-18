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
    primary: Color(0xFF0F1220),
    primaryLight: Color(0xFF171C31),
    accent: Color(0xFFE2B04A),
    accentLight: Color(0xFFF4D79A),
    accentSoft: Color(0x1FE2B04A),
    accentBlue: Color(0xFF59A8FF),
    accentBlueLight: Color(0xFF9FD0FF),
    background: Color(0xFF090B13),
    surface: Color(0xFF121725),
    surfaceLight: Color(0xFF171D2D),
    surfaceElevated: Color(0xFF1B2233),
    surfaceBorder: Color(0xFF4A5A78),
    textPrimary: Color(0xFFF4F7FB),
    textSecondary: Color(0xFFB4BED1),
    textMuted: Color(0xFF79839A),
    boardBackground: Color(0xFF0F1523),
    cellBackground: Color(0xFF131A2A),
    cellSelected: Color(0xFF2A4A8C),
    cellHighlighted: Color(0xFF1E2D4A),
    cellPeer: Color(0xFF1A2640),
    cellMatched: Color(0x2823A6FF),
    cellConflict: Color(0xFFEA8E8A),
    cellConflictSoft: Color(0x28EA8E8A),
    cellSuccess: Color(0xFF27AE60),
    givenNumber: Color(0xFFF4F7FB),
    userNumber: Color(0xFFB8D8FF),
    noteColor: Color(0xFF7B88A2),
    gridLine: Color(0xFF283146),
    gridLineThick: Color(0xFF53617F),
    error: Color(0xFFEA8E8A),
    success: Color(0xFF54D2A5),
    warning: Color(0xFFF2C66B),
    info: Color(0xFF59A8FF),
    gradientPrimary: LinearGradient(
      colors: [Color(0xFFE2B04A), Color(0xFFF4D06F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientBackground: LinearGradient(
      colors: [Color(0xFF090B13), Color(0xFF121725)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    heroGradient: LinearGradient(
      colors: [Color(0xFF121A2C), Color(0xFF0C101B), Color(0xFF151F33)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const light = AppColorScheme(
    primary: Color(0xFF1A1D26),
    primaryLight: Color(0xFFFFFFFF),
    accent: Color(0xFFD4A843),
    accentLight: Color(0xFFF5DEB3),
    accentSoft: Color(0x1FD4A843),
    accentBlue: Color(0xFF3B82F6),
    accentBlueLight: Color(0xFF93C5FD),
    background: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFF1F3F7),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceBorder: Color(0xFFE4E8EF),
    textPrimary: Color(0xFF1A1D26),
    textSecondary: Color(0xFF5C6370),
    textMuted: Color(0xFF9BA3AF),
    boardBackground: Color(0xFFEEF1F6),
    cellBackground: Color(0xFFFFFFFF),
    cellSelected: Color(0xFFD8E8FC),
    cellHighlighted: Color(0xFFF0F4FA),
    cellPeer: Color(0xFFE8EEF6),
    cellMatched: Color(0x283B82F6),
    cellConflict: Color(0xFFDC2626),
    cellConflictSoft: Color(0x28DC2626),
    cellSuccess: Color(0xFF16A34A),
    givenNumber: Color(0xFF1A1D26),
    userNumber: Color(0xFF2563EB),
    noteColor: Color(0xFF6B7280),
    gridLine: Color(0xFFD1D5DB),
    gridLineThick: Color(0xFF9CA3AF),
    error: Color(0xFFDC2626),
    success: Color(0xFF16A34A),
    warning: Color(0xFFCA8A04),
    info: Color(0xFF3B82F6),
    gradientPrimary: LinearGradient(
      colors: [Color(0xFFD4A843), Color(0xFFE8C468)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientBackground: LinearGradient(
      colors: [Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    heroGradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFF1F3F7), Color(0xFFFFFFFF)],
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
