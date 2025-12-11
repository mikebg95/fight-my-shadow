import 'package:flutter_tts/flutter_tts.dart';

/// Service that manages text-to-speech for voice coaching during workouts.
///
/// This service:
/// - Wraps the FlutterTts plugin
/// - Converts move codes to spoken words (e.g., "1" → "one")
/// - Provides clean API for speaking and stopping
/// - Maintains TTS configuration (rate, pitch, language)
class VoiceCoachService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  /// Initializes the TTS engine with optimal settings for workout coaching.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set language to English (US)
      await _tts.setLanguage('en-US');

      // Set speech rate (1.0 is normal speed, 0.5 is half speed, 2.0 is double speed)
      // Slightly slower for clarity during workouts
      await _tts.setSpeechRate(0.6);

      // Set pitch (1.0 is normal)
      await _tts.setPitch(1.0);

      // Set volume (1.0 is max)
      await _tts.setVolume(1.0);

      _isInitialized = true;
    } catch (e) {
      // TTS initialization failed, log error
      // In production, you might want to notify the user
      print('VoiceCoachService: Failed to initialize TTS: $e');
    }
  }

  /// Speaks the given combo codes.
  ///
  /// Converts move codes to spoken phrases and uses TTS to announce them.
  ///
  /// Example:
  /// ```dart
  /// await speakCombo(['1', '2', 'A']);
  /// // Speaks: "one, two, A"
  /// ```
  Future<void> speakCombo(List<String> codes) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (codes.isEmpty) return;

    // Convert codes to spoken words
    final spokenPhrase = _buildSpokenPhrase(codes);

    // Speak the phrase
    try {
      await _tts.speak(spokenPhrase);
    } catch (e) {
      print('VoiceCoachService: Failed to speak: $e');
    }
  }

  /// Stops any currently playing speech immediately.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('VoiceCoachService: Failed to stop: $e');
    }
  }

  /// Disposes the TTS engine.
  ///
  /// Call this when the service is no longer needed.
  void dispose() {
    _tts.stop();
  }

  // ========== PART 2: Code to Speech Conversion ==========

  /// Builds a spoken phrase from move codes.
  ///
  /// Uses commas for natural pauses between codes.
  String _buildSpokenPhrase(List<String> codes) {
    final spokenWords = codes.map(_codeToSpokenWord).toList();
    // Join with commas for natural pauses in TTS
    return spokenWords.join(', ');
  }

  /// Converts a single move code to its spoken word equivalent.
  ///
  /// Mapping:
  /// - Numbers: "1" → "one", "2" → "two", etc.
  /// - Letters: "A" → "A" (TTS pronounces as "ay"), "B" → "B", etc.
  ///
  /// This ensures we speak codes only, never move names.
  String _codeToSpokenWord(String code) {
    // Map numeric codes to spoken numbers
    const numberMap = {
      '1': 'one',
      '2': 'two',
      '3': 'three',
      '4': 'four',
      '5': 'five',
      '6': 'six',
      '7': 'seven',
      '8': 'eight',
      '9': 'nine',
      '10': 'ten',
      '11': 'eleven',
      '12': 'twelve',
      '13': 'thirteen',
      '14': 'fourteen',
    };

    // Check if it's a number
    if (numberMap.containsKey(code)) {
      return numberMap[code]!;
    }

    // For alphabetic codes (A-Z), return as-is
    // TTS will pronounce letters naturally (A → "ay", B → "bee", etc.)
    // This handles defense codes (A-M) and footwork codes (N-X)
    return code;
  }
}
