import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticFeedbackService {
  static Future<void> lightImpact() async {
    HapticFeedback.lightImpact();
  }
  
  static Future<void> mediumImpact() async {
    HapticFeedback.mediumImpact();
  }
  
  static Future<void> heavyImpact() async {
    HapticFeedback.heavyImpact();
  }
  
  static Future<void> qiblaAlignmentFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 100, 100, 100]);
    }
  }
} 