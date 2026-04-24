import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service to play alarm sounds.
class AudioService {
  static AudioPlayer? _player;
  static bool _isPlaying = false;

  /// Get or create audio player (lazy initialization)
  static AudioPlayer _getPlayer() {
    _player ??= AudioPlayer();
    return _player!;
  }

  /// Play the alarm sound in a loop.
  static Future<void> playAlarm() async {
    if (_isPlaying) return;

    // Skip audio on web platform to avoid initialization errors
    if (kIsWeb) return;

    _isPlaying = true;
    try {
      final player = _getPlayer();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(1.0);
      // Use a default system-like alert tone since we may not have the asset
      await player.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      // If alarm.mp3 not found, try a URL-based fallback
      try {
        final player = _getPlayer();
        await player.play(UrlSource(
            'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg'));
      } catch (_) {
        // Silently fail if no audio source available
      }
    }
  }

  /// Stop the alarm sound.
  static Future<void> stopAlarm() async {
    _isPlaying = false;
    if (_player != null) {
      await _player!.stop();
    }
  }

  /// Dispose the player.
  static Future<void> dispose() async {
    _isPlaying = false;
    if (_player != null) {
      await _player!.dispose();
    }
  }
}
