import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../providers/app_settings_provider.dart';

class FeedbackService {
  FeedbackService(this._ref);

  final Ref _ref;

  Future<void> tap() async {
    final settings = _ref.read(appSettingsProvider);
    if (settings.hapticsEnabled && await Vibration.hasVibrator() == true) {
      await Vibration.vibrate(duration: 12, amplitude: 32);
    }
    if (settings.soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> softSuccess() async {
    final settings = _ref.read(appSettingsProvider);
    if (settings.hapticsEnabled && await Vibration.hasVibrator() == true) {
      await Vibration.vibrate(pattern: [0, 18, 24, 28], intensities: [0, 40, 0, 60]);
    }
    if (settings.soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> softError() async {
    final settings = _ref.read(appSettingsProvider);
    if (settings.hapticsEnabled && await Vibration.hasVibrator() == true) {
      await Vibration.vibrate(duration: 18, amplitude: 46);
    }
  }
}

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService(ref);
});
