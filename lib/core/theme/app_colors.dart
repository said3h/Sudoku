import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const primary = Color(0xFF1A1A2E);
  static const primaryLight = Color(0xFF16213E);
  static const accent = Color(0xFFE2B04A);
  static const accentLight = Color(0xFFF4D06F);

  // Background
  static const background = Color(0xFF0F0F1A);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceLight = Color(0xFF252542);

  // Text
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFFA0A0B0);
  static const textMuted = Color(0xFF6B6B80);

  // Sudoku Board
  static const boardBackground = Color(0xFF1E1E35);
  static const cellBackground = Color(0xFF252542);
  static const cellSelected = Color(0xFF3A3A5C);
  static const cellHighlighted = Color(0xFF2A2A4A);
  static const cellConflict = Color(0xFFE74C3C);
  static const cellSuccess = Color(0xFF27AE60);
  static const givenNumber = Color(0xFFF5F5F7);
  static const userNumber = Color(0xFFE2B04A);
  static const noteColor = Color(0xFF8080A0);
  static const gridLine = Color(0xFF3A3A5C);
  static const gridLineThick = Color(0xFFE2B04A);

  // Status
  static const error = Color(0xFFE74C3C);
  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFF39C12);
  static const info = Color(0xFF3498DB);

  // Gradient
  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFFE2B04A), Color(0xFFF4D06F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientBackground = LinearGradient(
    colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
