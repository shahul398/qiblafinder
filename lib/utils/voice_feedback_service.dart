import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceFeedbackService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;
  static bool _isSpeaking = false;
  
  static Future<void> initialize() async {
    if (!_isInitialized) {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    }
  }
  
  static Future<void> speak(String text) async {
    try {
      await initialize();
      if (!_isSpeaking) {
        _isSpeaking = true;
        await _flutterTts.speak(text);
        _isSpeaking = false;
      }
    } catch (e) {
      debugPrint('Error with TTS: $e');
      _isSpeaking = false;
    }
  }
  
  static Future<void> speakQiblaDirection(double degrees) async {
    final directionText = _getDirectionText(degrees);
    await speak('Qibla is $directionText at ${degrees.round()} degrees');
  }
  
  static String _getDirectionText(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'North';
    if (degrees >= 22.5 && degrees < 67.5) return 'Northeast';
    if (degrees >= 67.5 && degrees < 112.5) return 'East';
    if (degrees >= 112.5 && degrees < 157.5) return 'Southeast';
    if (degrees >= 157.5 && degrees < 202.5) return 'South';
    if (degrees >= 202.5 && degrees < 247.5) return 'Southwest';
    if (degrees >= 247.5 && degrees < 292.5) return 'West';
    return 'Northwest';
  }
  
  static Future<void> stop() async {
    if (_isInitialized) {
      _isSpeaking = false;
      await _flutterTts.stop();
    }
  }
} 