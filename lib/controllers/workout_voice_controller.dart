import 'package:fight_my_shadow/domain/combos/combo.dart';
import 'package:fight_my_shadow/main.dart';
import 'package:fight_my_shadow/services/voice_coach_service.dart';

/// Controller that manages voice coaching during workouts.
///
/// This controller:
/// - Observes workout state changes
/// - Detects when a new combo appears
/// - Triggers TTS to speak combo codes at the right time
/// - Handles pause/resume/rest/stop states correctly
///
/// PART 3: When to Speak
/// - Speaks combo codes ONCE when a new combo appears during announce phase
/// - Never speaks during execute or recovery phases
/// - Never re-speaks the same combo (prevents duplicates on rebuilds)
///
/// PART 4: State Management
/// - Pause: stops speaking immediately, doesn't speak while paused
/// - Resume: doesn't re-speak current combo
/// - Rest: doesn't speak during rest phase
/// - Stop: stops speaking and cleans up
class WorkoutVoiceController {
  final VoiceCoachService _voiceService;

  // Track previous state to detect changes
  Combo? _previousCombo;
  bool _wasPaused = false;

  WorkoutVoiceController(this._voiceService);

  /// Updates the controller with current workout state.
  ///
  /// Call this method from your workout state's setState or whenever
  /// workout state changes (combo, phase, pause status).
  ///
  /// This method intelligently decides whether to speak based on state changes.
  void update({
    required Combo? currentCombo,
    required ComboPhase comboPhase,
    required WorkoutPhase workoutPhase,
    required bool isPaused,
  }) {
    // PART 4: Handle pause state
    if (isPaused) {
      if (!_wasPaused) {
        // Just paused - stop any ongoing speech
        _voiceService.stop();
        _wasPaused = true;
      }
      // Don't speak while paused
      return;
    }

    // PART 4: Handle resume
    if (_wasPaused && !isPaused) {
      // Just resumed - don't re-speak current combo
      _wasPaused = false;
      // Update previous state to prevent speaking on resume
      _previousCombo = currentCombo;
      return;
    }

    // PART 4: Handle rest phase
    if (workoutPhase == WorkoutPhase.rest) {
      // Don't speak during rest
      return;
    }

    // PART 3: Detect new combo during announce phase
    final isNewCombo = _isNewCombo(currentCombo);
    final isAnnouncePhase = comboPhase == ComboPhase.announce;
    final hasCombo = currentCombo != null && currentCombo.moveCodes.isNotEmpty;

    if (isNewCombo && isAnnouncePhase && hasCombo) {
      // Speak the new combo codes
      _speakCombo(currentCombo);
    }

    // Update previous state
    _previousCombo = currentCombo;
  }

  /// Stops voice coaching and cleans up resources.
  ///
  /// Call this when the workout ends or is stopped.
  void stop() {
    _voiceService.stop();
    _reset();
  }

  /// Disposes the controller and its resources.
  ///
  /// Call this when the controller is no longer needed.
  void dispose() {
    _voiceService.dispose();
    _reset();
  }

  // ========== Private Methods ==========

  /// Checks if the current combo is different from the previous one.
  ///
  /// Uses sequenceId when available (for drill mode) to ensure every combo instance
  /// is considered new, even if move codes are identical.
  bool _isNewCombo(Combo? currentCombo) {
    // No combo → not new
    if (currentCombo == null) {
      return false;
    }

    // No previous combo → this is new
    if (_previousCombo == null) {
      return true;
    }

    // If both combos have sequence IDs, compare those first
    // This ensures drill mode speaks every combo, even identical codes
    if (currentCombo.sequenceId != null && _previousCombo!.sequenceId != null) {
      return currentCombo.sequenceId != _previousCombo!.sequenceId;
    }

    // Fallback: Compare combo codes (for combos without sequence IDs)
    final currentCodes = currentCombo.moveCodes;
    final previousCodes = _previousCombo!.moveCodes;

    // Different length → different combo
    if (currentCodes.length != previousCodes.length) {
      return true;
    }

    // Compare each code
    for (int i = 0; i < currentCodes.length; i++) {
      if (currentCodes[i] != previousCodes[i]) {
        return true;
      }
    }

    // Same combo
    return false;
  }

  /// Speaks the given combo's codes using TTS.
  void _speakCombo(Combo combo) {
    _voiceService.speakCombo(combo.moveCodes);
  }

  /// Resets internal state tracking.
  void _reset() {
    _previousCombo = null;
    _wasPaused = false;
  }
}
