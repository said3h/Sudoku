import 'package:flutter/material.dart';

class AppSettings {
  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool zenModeEnabled;
  final ThemeMode themeMode;

  const AppSettings({
    this.hapticsEnabled = true,
    this.soundEnabled = true,
    this.zenModeEnabled = false,
    this.themeMode = ThemeMode.system,
  });

  AppSettings copyWith({
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? zenModeEnabled,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      zenModeEnabled: zenModeEnabled ?? this.zenModeEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> rawMap) {
    final map = Map<dynamic, dynamic>.from(rawMap);
    final themeModeIndex = map['themeMode'] as int? ?? 0;
    return AppSettings(
      hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      zenModeEnabled: map['zenModeEnabled'] as bool? ?? false,
      themeMode: ThemeMode.values[themeModeIndex.clamp(0, 2)],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hapticsEnabled': hapticsEnabled,
      'soundEnabled': soundEnabled,
      'zenModeEnabled': zenModeEnabled,
      'themeMode': themeMode.index,
    };
  }
}
