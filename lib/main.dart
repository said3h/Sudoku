import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/navigation/app_router.dart';
import 'core/providers/app_settings_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/sudoku/data/sudoku_game_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.hiveBoxSettings);
  await Hive.openBox(AppConstants.hiveBoxStats);
  await Hive.openBox(AppConstants.hiveBoxCurrentGame);

  runApp(
    const ProviderScope(
      child: SudokuApp(),
    ),
  );
}

class SudokuApp extends ConsumerStatefulWidget {
  const SudokuApp({super.key});

  @override
  ConsumerState<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends ConsumerState<SudokuApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      SudokuGameStorage.flush();
    }
  }

  void _updateSystemUI(ThemeMode mode, Brightness brightness) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: brightness == Brightness.dark
            ? const Color(0xFF08111F)
            : const Color(0xFFF5F7FA),
        systemNavigationBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final themeMode = settings.themeMode;

    Brightness effectiveBrightness;
    if (themeMode == ThemeMode.light) {
      effectiveBrightness = Brightness.light;
    } else if (themeMode == ThemeMode.dark) {
      effectiveBrightness = Brightness.dark;
    } else {
      effectiveBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }

    _updateSystemUI(themeMode, effectiveBrightness);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
