enum AppThemePreset {
  adaptive,
  cognacIvory,
  emeraldSilver,
  midnightGold,
  royalAmethyst,
}

extension AppThemePresetLabel on AppThemePreset {
  String get label {
    return switch (this) {
      AppThemePreset.adaptive => 'Actual',
      AppThemePreset.cognacIvory => 'Cognac',
      AppThemePreset.emeraldSilver => 'Emerald',
      AppThemePreset.midnightGold => 'Midnight',
      AppThemePreset.royalAmethyst => 'Amethyst',
    };
  }
}
