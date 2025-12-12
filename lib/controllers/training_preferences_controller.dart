import 'package:flutter/foundation.dart';
import 'package:fight_my_shadow/domain/training/training_preferences.dart';
import 'package:fight_my_shadow/repositories/training_preferences_repository.dart';
import 'package:fight_my_shadow/domain/learning/learning_state.dart';
import 'package:fight_my_shadow/domain/learning/learning_path.dart';
import 'package:fight_my_shadow/repositories/move_repository.dart';

/// Global controller for Training Preferences.
///
/// This manages which unlocked moves are included in Training Sessions.
/// It coordinates with StoryModeController to:
/// - Initialize with all currently unlocked moves included (default)
/// - Auto-include newly unlocked moves
/// - Persist user preferences across app restarts
///
/// Usage:
/// - Create once at app startup
/// - Call init() with current LearningState to load/sync preferences
/// - Call syncWithLearningState() whenever moves are unlocked
/// - Screens listen to changes via ChangeNotifier
class TrainingPreferencesController extends ChangeNotifier {
  final TrainingPreferencesRepository _repository;
  final MoveRepository _moveRepository;

  TrainingPreferences _preferences;
  bool _isInitialized = false;

  TrainingPreferencesController(this._repository, this._moveRepository)
      : _preferences = TrainingPreferences.empty();

  /// The current training preferences. All screens should read from this.
  TrainingPreferences get preferences => _preferences;

  /// Whether the controller has finished loading persisted preferences.
  bool get isInitialized => _isInitialized;

  /// Initializes the controller by loading persisted preferences.
  ///
  /// [learningState]: The current Academy learning state to determine unlocked moves.
  ///
  /// Call this once at app startup after StoryModeController is initialized.
  /// If persisted preferences exist, they will be loaded and synced with
  /// currently unlocked moves. Otherwise, all unlocked moves will be included.
  Future<void> init(LearningState learningState) async {
    final loadedPreferences = await _repository.load();

    // Get all currently unlocked move codes
    final unlockedMoveCodes = _getUnlockedMoveCodes(learningState);

    if (loadedPreferences != null) {
      // Sync loaded preferences with newly unlocked moves
      _preferences = loadedPreferences.includeAllMoves(unlockedMoveCodes);
    } else {
      // No saved preferences - include all unlocked moves by default
      _preferences = TrainingPreferences.defaultWith(unlockedMoveCodes);
    }

    // Save the synced state
    await _repository.save(_preferences);

    _isInitialized = true;
    notifyListeners();
  }

  /// Syncs preferences with the current learning state.
  ///
  /// Call this after moves are unlocked to auto-include newly unlocked moves.
  /// This ensures users don't have to manually enable each new move.
  Future<void> syncWithLearningState(LearningState learningState) async {
    final unlockedMoveCodes = _getUnlockedMoveCodes(learningState);

    // Find newly unlocked moves (not yet in preferences)
    final newlyUnlockedMoves = unlockedMoveCodes
        .where((code) => !_preferences.isIncluded(code))
        .toList();

    if (newlyUnlockedMoves.isEmpty) {
      return; // No new moves to add
    }

    // Auto-include newly unlocked moves
    _preferences = _preferences.includeAllMoves(newlyUnlockedMoves);
    await _repository.save(_preferences);
    notifyListeners();
  }

  /// Toggles a move's inclusion state (included ↔ excluded).
  ///
  /// Only works for unlocked moves. Locked moves cannot be toggled.
  Future<void> toggleMove(String moveCode) async {
    _preferences = _preferences.toggleMove(moveCode);
    await _repository.save(_preferences);
    notifyListeners();
  }

  /// Checks if a move is included in Training.
  bool isIncluded(String moveCode) {
    return _preferences.isIncluded(moveCode);
  }

  /// Gets the count of included moves.
  int get includedCount => _preferences.includedCount;

  /// Gets all move codes that should be used for Training combo generation.
  ///
  /// Returns the intersection of:
  /// - Unlocked moves (from learningState)
  /// - Included moves (from preferences)
  ///
  /// READY_FOR_UNLOCK moves are treated as locked for Training.
  List<String> getIncludedUnlockedMoveCodes(LearningState learningState) {
    final unlockedCodes = _getUnlockedMoveCodes(learningState);
    return unlockedCodes.where(_preferences.isIncluded).toList();
  }

  /// Resets all preferences to default (all unlocked moves included).
  Future<void> reset(LearningState learningState) async {
    final unlockedMoveCodes = _getUnlockedMoveCodes(learningState);
    _preferences = TrainingPreferences.defaultWith(unlockedMoveCodes);
    await _repository.save(_preferences);
    notifyListeners();
  }

  /// Helper to extract all unlocked move codes from learning state.
  ///
  /// Only includes moves that are fully unlocked (isUnlocked = true).
  /// READY_FOR_UNLOCK moves are NOT included.
  List<String> _getUnlockedMoveCodes(LearningState learningState) {
    final allLearningMoves = LearningPath.getAllMoves();
    final unlockedCodes = <String>[];

    for (final learningMove in allLearningMoves) {
      final progress = learningState.getProgressForMove(learningMove.id);
      if (progress != null && progress.isUnlocked) {
        // This learning move is fully unlocked - add all its move codes
        unlockedCodes.addAll(learningMove.moveCodes);
      }
    }

    return unlockedCodes;
  }
}
