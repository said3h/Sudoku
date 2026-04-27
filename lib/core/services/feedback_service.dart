import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_settings_provider.dart';

class FeedbackService {
  FeedbackService(this._ref);

  final Ref _ref;

  Future<void> tap() async {
    final settings = _ref.read(appSettingsProvider);
    if (settings.hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }
    if (settings.soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> softSuccess() async {
    final settings = _ref.read(appSettingsProvider);
    if (settings.hapticsEnabled) {
      await HapticFeedback.lightImpact();
    }
    if (settings.soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> softError() async {
    final settings = _ref.read(appSettingsProvider);
    if (settings.hapticsEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }

  Future<void> victorySpecial() async {
    final settings = _ref.read(appSettingsProvider);
    if (settings.hapticsEnabled) {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.selectionClick();
    }
    if (settings.soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 100));
      await SystemSound.play(SystemSoundType.click);
    }
  }
}

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService(ref);
});
