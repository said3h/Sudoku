import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final c = context.appColors.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ThemeModeSelector(
            currentMode: settings.themeMode,
            onChanged: notifier.setThemeMode,
          ),
          const SizedBox(height: 20),
          _SettingsTile(
            title: 'Haptics premium',
            subtitle: 'Vibracion suave al interactuar con el tablero.',
            value: settings.hapticsEnabled,
            onChanged: notifier.setHaptics,
          ),
          _SettingsTile(
            title: 'Sonido sutil',
            subtitle: 'Click discreto al tocar numeros y acciones.',
            value: settings.soundEnabled,
            onChanged: notifier.setSound,
          ),
          _SettingsTile(
            title: 'Modo zen por defecto',
            subtitle: 'Sin presion por errores al empezar una partida nueva.',
            value: settings.zenModeEnabled,
            onChanged: notifier.setZenMode,
          ),
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apariencia',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ThemeModeOption(
                icon: Icons.brightness_auto_rounded,
                label: 'Sistema',
                isSelected: currentMode == ThemeMode.system,
                onTap: () => onChanged(ThemeMode.system),
              ),
              const SizedBox(width: 10),
              _ThemeModeOption(
                icon: Icons.light_mode_rounded,
                label: 'Claro',
                isSelected: currentMode == ThemeMode.light,
                onTap: () => onChanged(ThemeMode.light),
              ),
              const SizedBox(width: 10),
              _ThemeModeOption(
                icon: Icons.dark_mode_rounded,
                label: 'Oscuro',
                isSelected: currentMode == ThemeMode.dark,
                onTap: () => onChanged(ThemeMode.dark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? c.accentSoft : c.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? c.accent : c.surfaceBorder,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? c.accent : c.textMuted,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? c.accent : c.textMuted,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        activeColor: c.accent,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: c.textPrimary,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.textMuted,
                ),
          ),
        ),
      ),
    );
  }
}
