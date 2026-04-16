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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
