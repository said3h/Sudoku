import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData buildTheme(AppColorScheme colors, Brightness brightness) {
    final baseTextTheme = GoogleFonts.manropeTextTheme(
      TextTheme(
        displayLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary),
        displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary),
        displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary),
        headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary),
        titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary),
        titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary),
        bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary),
        bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary),
        labelLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary),
        labelMedium: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary),
      ),
    );

    final scheme = brightness == Brightness.dark
        ? ColorScheme.dark(
            primary: colors.accent,
            onPrimary: colors.primary,
            secondary: colors.accentBlue,
            onSecondary: colors.primary,
            error: colors.error,
            onError: colors.primary,
            surface: colors.surface,
            onSurface: colors.textPrimary,
          )
        : ColorScheme.light(
            primary: colors.accent,
            onPrimary: colors.primary,
            secondary: colors.accentBlue,
            onSecondary: colors.primary,
            error: colors.error,
            onError: colors.primary,
            surface: colors.surface,
            onSurface: colors.textPrimary,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.accent,
      colorScheme: scheme,
      textTheme: baseTextTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.surfaceBorder),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.surfaceBorder,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: colors.textSecondary,
        size: 22,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceLight,
        selectedColor: colors.accentSoft,
        disabledColor: colors.surfaceLight,
        secondarySelectedColor: colors.accentSoft,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: baseTextTheme.bodySmall!,
        secondaryLabelStyle: baseTextTheme.bodySmall!,
        brightness: brightness,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.surfaceBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.primary,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: colors.surfaceBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textSecondary,
          textStyle: baseTextTheme.labelMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(color: colors.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.accentBlue, width: 1.2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colors.surfaceBorder),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return colors.primary;
          return colors.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return colors.accent;
          return colors.surfaceBorder;
        }),
      ),
    ).copyWith(
      extensions: [
        AppColorsExtension(colors: colors),
      ],
    );
  }

  static ThemeData get darkTheme =>
      buildTheme(AppColorScheme.dark, Brightness.dark);
  static ThemeData get lightTheme =>
      buildTheme(AppColorScheme.light, Brightness.light);
}
