import 'package:audioplayers/audioplayers.dart';

/// Service for playing sound effects during workouts.
///
/// Currently supports:
/// - Boxing bell sound (round start/end)
class SoundEffectsService {
  final AudioPlayer _bellPlayer = AudioPlayer();
  bool _isInitialized = false;

  /// Initializes the audio player.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set audio player to low latency mode for quick playback
      await _bellPlayer.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
    } catch (e) {
      print('SoundEffectsService: Failed to initialize: $e');
    }
  }

  /// Plays the boxing bell sound.
  ///
  /// This sound plays at:
  /// - Start of each round (Drill and Add-to-Arsenal modes)
  /// - End of each round (Drill and Add-to-Arsenal modes)
  ///
  /// The sound plays asynchronously and doesn't block the UI or TTS.
  Future<void> playBell() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Play the bell sound from assets
      // Note: If the asset doesn't exist, this will fail silently
      await _bellPlayer.play(AssetSource('sounds/boxing_bell.mp3'));
    } catch (e) {
      // Sound file might not exist yet - that's okay
      print('SoundEffectsService: Could not play bell sound: $e');
    }
  }

  /// Stops any currently playing sound.
  Future<void> stop() async {
    try {
      await _bellPlayer.stop();
    } catch (e) {
      print('SoundEffectsService: Failed to stop: $e');
    }
  }

  /// Disposes of audio resources.
  Future<void> dispose() async {
    await _bellPlayer.dispose();
  }
}
