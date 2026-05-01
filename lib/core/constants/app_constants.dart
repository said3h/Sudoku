class AppConstants {
  AppConstants._();

  static const String appName = 'Sudoku Premium';
  static const String appVersion = '1.0.0';

  // Hive
  static const String hiveBoxSettings = 'settings';
  static const String hiveBoxStats = 'statistics';
  static const String hiveBoxCurrentGame = 'current_game';

  // Routes
  static const String routeHome = '/';
  static const String routeGame = '/game';
  static const String routeStats = '/stats';
  static const String routeSettings = '/settings';

  // Difficulty levels
  static const int difficultyEasy = 40;
  static const int difficultyMedium = 32;
  static const int difficultyHard = 26;
  static const int difficultyExpert = 20;
}
