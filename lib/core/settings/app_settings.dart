class AppSettings {
  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool zenModeEnabled;

  const AppSettings({
    this.hapticsEnabled = true,
    this.soundEnabled = true,
    this.zenModeEnabled = false,
  });

  AppSettings copyWith({
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? zenModeEnabled,
  }) {
    return AppSettings(
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      zenModeEnabled: zenModeEnabled ?? this.zenModeEnabled,
    );
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> rawMap) {
    final map = Map<dynamic, dynamic>.from(rawMap);
    return AppSettings(
      hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      zenModeEnabled: map['zenModeEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hapticsEnabled': hapticsEnabled,
      'soundEnabled': soundEnabled,
      'zenModeEnabled': zenModeEnabled,
    };
  }
}
