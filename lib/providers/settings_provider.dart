import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qibla_finder_flutter/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(const SettingsModel()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    state = SettingsModel(
      highContrastMode: prefs.getBool('high_contrast_mode') ?? false,
      voiceFeedback: prefs.getBool('voice_feedback') ?? false,
      largeText: prefs.getBool('large_text') ?? false,
      hapticFeedback: prefs.getBool('haptic_feedback') ?? true,
      autoCalibration: prefs.getBool('auto_calibration') ?? false,
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('high_contrast_mode', state.highContrastMode);
    await prefs.setBool('voice_feedback', state.voiceFeedback);
    await prefs.setBool('large_text', state.largeText);
    await prefs.setBool('haptic_feedback', state.hapticFeedback);
    await prefs.setBool('auto_calibration', state.autoCalibration);
  }

  void setHighContrastMode(bool value) {
    state = state.copyWith(highContrastMode: value);
    _saveSettings();
  }

  void setVoiceFeedback(bool value) {
    state = state.copyWith(voiceFeedback: value);
    _saveSettings();
  }

  void setLargeText(bool value) {
    state = state.copyWith(largeText: value);
    _saveSettings();
  }

  void setHapticFeedback(bool value) {
    state = state.copyWith(hapticFeedback: value);
    _saveSettings();
  }

  void setAutoCalibration(bool value) {
    state = state.copyWith(autoCalibration: value);
    _saveSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  return SettingsNotifier();
});
