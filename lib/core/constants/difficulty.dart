import 'package:flutter/material.dart';

enum Difficulty {
  easy(40),
  medium(32),
  hard(26),
  expert(20);

  final int cluesCount;

  const Difficulty(this.cluesCount);

  String get displayName {
    switch (this) {
      case easy:
        return 'Facil';
      case medium:
        return 'Medio';
      case hard:
        return 'Dificil';
      case expert:
        return 'Experto';
    }
  }

  String get description {
    switch (this) {
      case easy:
        return 'Perfecto para principiantes';
      case medium:
        return 'Un buen desafio';
      case hard:
        return 'Para jugadores experimentados';
      case expert:
        return 'Solo para expertos';
    }
  }

  Color get color {
    switch (this) {
      case easy:
        return const Color(0xFF27AE60);
      case medium:
        return const Color(0xFF3498DB);
      case hard:
        return const Color(0xFFF39C12);
      case expert:
        return const Color(0xFFE74C3C);
    }
  }

  IconData get icon {
    switch (this) {
      case easy:
        return Icons.sentiment_satisfied;
      case medium:
        return Icons.sentiment_neutral;
      case hard:
        return Icons.sentiment_dissatisfied;
      case expert:
        return Icons.emoji_events;
    }
  }

  static String keyFromCluesCount(int cluesCount) {
    if (cluesCount >= easy.cluesCount) return easy.name;
    if (cluesCount >= medium.cluesCount) return medium.name;
    if (cluesCount >= hard.cluesCount) return hard.name;
    return expert.name;
  }
}
