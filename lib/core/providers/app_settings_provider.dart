import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings.dart';
import '../settings/app_settings_storage.dart';

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(AppSettingsStorage.load());

  Future<void> setHaptics(bool value) async {
    state = state.copyWith(hapticsEnabled: value);
    await AppSettingsStorage.save(state);
  }

  Future<void> setSound(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await AppSettingsStorage.save(state);
  }

  Future<void> setZenMode(bool value) async {
    state = state.copyWith(zenModeEnabled: value);
    await AppSettingsStorage.save(state);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
