class SettingsModel {
  final bool highContrastMode;
  final bool voiceFeedback;
  final bool largeText;
  final bool hapticFeedback;
  final bool autoCalibration;

  const SettingsModel({
    this.highContrastMode = false,
    this.voiceFeedback = false,
    this.largeText = false,
    this.hapticFeedback = true,
    this.autoCalibration = false,
  });

  SettingsModel copyWith({
    bool? highContrastMode,
    bool? voiceFeedback,
    bool? largeText,
    bool? hapticFeedback,
    bool? autoCalibration,
  }) {
    return SettingsModel(
      highContrastMode: highContrastMode ?? this.highContrastMode,
      voiceFeedback: voiceFeedback ?? this.voiceFeedback,
      largeText: largeText ?? this.largeText,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      autoCalibration: autoCalibration ?? this.autoCalibration,
    );
  }
}
