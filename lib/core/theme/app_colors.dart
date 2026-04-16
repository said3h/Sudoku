import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF0F1220);
  static const primaryLight = Color(0xFF171C31);
  static const accent = Color(0xFFE2B04A);
  static const accentLight = Color(0xFFF4D79A);
  static const accentSoft = Color(0x1FE2B04A);
  static const accentBlue = Color(0xFF59A8FF);
  static const accentBlueLight = Color(0xFF9FD0FF);

  static const background = Color(0xFF090B13);
  static const surface = Color(0xFF121725);
  static const surfaceLight = Color(0xFF171D2D);
  static const surfaceElevated = Color(0xFF1B2233);
  static const surfaceBorder = Color(0xFF2A3348);

  static const textPrimary = Color(0xFFF4F7FB);
  static const textSecondary = Color(0xFFB4BED1);
  static const textMuted = Color(0xFF79839A);

  static const boardBackground = Color(0xFF0F1523);
  static const cellBackground = Color(0xFF131A2A);
  static const cellSelected = Color(0xFF1D2B48);
  static const cellHighlighted = Color(0xFF182134);
  static const cellPeer = Color(0xFF141D2D);
  static const cellMatched = Color(0x1823A6FF);
  static const cellConflict = Color(0xFFEA8E8A);
  static const cellConflictSoft = Color(0x1BEA8E8A);
  static const cellSuccess = Color(0xFF27AE60);
  static const givenNumber = Color(0xFFF4F7FB);
  static const userNumber = Color(0xFF82BFFF);
  static const noteColor = Color(0xFF7B88A2);
  static const gridLine = Color(0xFF283146);
  static const gridLineThick = Color(0xFF53617F);

  static const error = Color(0xFFEA8E8A);
  static const success = Color(0xFF54D2A5);
  static const warning = Color(0xFFF2C66B);
  static const info = Color(0xFF59A8FF);

  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFFE2B04A), Color(0xFFF4D06F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientBackground = LinearGradient(
    colors: [Color(0xFF090B13), Color(0xFF121725)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const heroGradient = LinearGradient(
    colors: [Color(0xFF121A2C), Color(0xFF0C101B), Color(0xFF151F33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
