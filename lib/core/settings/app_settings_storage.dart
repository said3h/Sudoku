import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import 'app_settings.dart';

class AppSettingsStorage {
  AppSettingsStorage._();

  static const String settingsKey = 'app_settings';

  static Box get _settingsBox => Hive.box(AppConstants.hiveBoxSettings);

  static AppSettings load() {
    final raw = _settingsBox.get(settingsKey);
    if (raw is! Map) return const AppSettings();
    return AppSettings.fromMap(raw);
  }

  static Future<void> save(AppSettings settings) async {
    await _settingsBox.put(settingsKey, settings.toMap());
    await _settingsBox.flush();
  }
}
