import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.manropeTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    ).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    final scheme = const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accentBlue,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.primary,
      onSecondary: AppColors.primary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accent,
      colorScheme: scheme,
      textTheme: baseTextTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceBorder,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 22,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.accentSoft,
        disabledColor: AppColors.surfaceLight,
        secondarySelectedColor: AppColors.accentSoft,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: baseTextTheme.bodySmall!,
        secondaryLabelStyle: baseTextTheme.bodySmall!,
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
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
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.surfaceBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: baseTextTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle: baseTextTheme.labelMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle:
            baseTextTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.primary;
          return AppColors.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.accent;
          return AppColors.surfaceBorder;
        }),
      ),
    );
  }
}
