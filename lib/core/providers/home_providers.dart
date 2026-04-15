import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/difficulty.dart';

final selectedDifficultyProvider = StateProvider<Difficulty>((ref) {
  return Difficulty.medium;
});

final isNewGameDialogOpenProvider = StateProvider<bool>((ref) {
  return false;
});

final navigateToGameProvider = StateProvider<bool>((ref) {
  return false;
});
