import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool soundEnabled = true;

  static Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  static Future<void> playComboHit(int combo) async {
    if (!soundEnabled) return;
    try {
      // In low-latency mode, we play audio effect; if asset not present, silent fallback
      await _player.stop();
      // Increase pitch slightly with higher combo
      final double pitch = (1.0 + (combo * 0.05)).clamp(1.0, 2.0);
      await _player.setPlaybackRate(pitch);
      await _player.play(AssetSource('audio/combo_hit.mp3'));
    } catch (_) {
      // Graceful fallback without crash
    }
  }

  static Future<void> playCardFlip() async {
    if (!soundEnabled) return;
    try {
      await _player.stop();
      await _player.setPlaybackRate(1.2);
      await _player.play(AssetSource('audio/combo_hit.mp3'));
    } catch (_) {}
  }

  static Future<void> playSuccess() async {
    if (!soundEnabled) return;
    try {
      await _player.stop();
      await _player.setPlaybackRate(1.0);
      await _player.play(AssetSource('audio/success.mp3'));
    } catch (_) {}
  }

  static Future<void> playError() async {
    if (!soundEnabled) return;
    try {
      await _player.stop();
      await _player.setPlaybackRate(1.0);
      await _player.play(AssetSource('audio/error.mp3'));
    } catch (_) {}
  }

  static Future<void> playLevelUp() async {
    if (!soundEnabled) return;
    try {
      await _player.stop();
      await _player.setPlaybackRate(1.0);
      await _player.play(AssetSource('audio/level_up.mp3'));
    } catch (_) {}
  }
}
