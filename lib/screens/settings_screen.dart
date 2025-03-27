import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qibla_finder_flutter/providers/settings_provider.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          SwitchListTile(
            title: const Text('High Contrast Mode'),
            subtitle: const Text('Enhance visibility with high contrast colors'),
            value: settings.highContrastMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setHighContrastMode(value);
            },
          ),
          SwitchListTile(
            title: const Text('Voice Feedback'),
            subtitle: const Text('Enable voice guidance for directions'),
            value: settings.voiceFeedback,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setVoiceFeedback(value);
            },
          ),
          SwitchListTile(
            title: const Text('Large Text'),
            subtitle: const Text('Increase text size for better readability'),
            value: settings.largeText,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setLargeText(value);
            },
          ),
          SwitchListTile(
            title: const Text('Auto Calibration'),
            subtitle: const Text('Show compass calibration popup automatically when needed'),
            value: settings.autoCalibration,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setAutoCalibration(value);
            },
          ),
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate when aligned with Qibla direction'),
            value: settings.hapticFeedback,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setHapticFeedback(value);
            },
          ),
          const Divider(),
          ListTile(
            title: Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Qibla Finder v1.0.0'),
          ),
        ],
      ),
    );
  }
}
