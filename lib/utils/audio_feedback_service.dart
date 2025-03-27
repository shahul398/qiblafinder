import 'package:audioplayers/audioplayers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final audioFeedbackServiceProvider = Provider<AudioFeedbackService>((ref) {
  return AudioFeedbackService();
});

class AudioFeedbackService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  
  Future<void> playAlignmentSound() async {
    if (_isPlaying) return;
    
    try {
      _isPlaying = true;
      // Play a simple "ding" sound
      await _audioPlayer.play(AssetSource('sounds/qibla_found.mp3'));
      
      // Reset the playing state after sound completes
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      print('Error playing sound: $e');
      _isPlaying = false;
    }
  }
  
  Future<void> stop() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _isPlaying = false;
    }
  }
  
  void dispose() {
    _audioPlayer.dispose();
  }
} 