import 'package:audioplayers/audioplayers.dart';

/// Service to play alarm sounds.
class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  /// Play the alarm sound in a loop.
  static Future<void> playAlarm() async {
    if (_isPlaying) return;
    _isPlaying = true;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);
      // Use a default system-like alert tone since we may not have the asset
      await _player.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      // If alarm.mp3 not found, try a URL-based fallback
      try {
        await _player.play(UrlSource(
            'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg'));
      } catch (_) {
        // Silently fail if no audio source available
      }
    }
  }

  /// Stop the alarm sound.
  static Future<void> stopAlarm() async {
    _isPlaying = false;
    await _player.stop();
  }

  /// Dispose the player.
  static Future<void> dispose() async {
    _isPlaying = false;
    await _player.dispose();
  }
}
