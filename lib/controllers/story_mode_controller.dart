import 'package:flutter/foundation.dart';
import 'package:fight_my_shadow/domain/learning/learning_state.dart';
import 'package:fight_my_shadow/domain/learning/learning_progress_service.dart';
import 'package:fight_my_shadow/repositories/learning_progress_repository.dart';

/// Global controller for Story Mode learning progress.
///
/// This is the single source of truth for LearningState across the entire app.
/// It manages:
/// - In-memory state that all screens read from
/// - Persistence to local storage (survives app restarts)
/// - State updates with automatic save and notification
/// - Migration when the curriculum changes (moves added/removed)
///
/// Usage:
/// - Create once at app startup
/// - Call init() to load persisted state
/// - Inject into screens via InheritedWidget, Provider, or similar
/// - Screens listen to changes via ChangeNotifier
///
/// Migration behavior:
/// When the app's curriculum changes (new moves added, moves removed or
/// reordered), [init] automatically migrates persisted state to match the
/// current curriculum. User progress is preserved for moves that still exist;
/// new moves start with fresh progress. This prevents crash-on-launch when
/// users update the app to a version with a different curriculum.
class StoryModeController extends ChangeNotifier {
  final LearningProgressRepository _repository;

  LearningState _state;
  bool _isInitialized = false;

  StoryModeController(this._repository)
      : _state = LearningProgressService.initializeFreshState();

  /// The current learning state. All screens should read from this.
  LearningState get state => _state;

  /// Whether the controller has finished loading persisted state.
  bool get isInitialized => _isInitialized;

  /// Initializes the controller by loading persisted state.
  ///
  /// Call this once at app startup before using the controller.
  /// If persisted state exists, it will be loaded and migrated if necessary.
  /// Otherwise, a fresh initial state will be created.
  ///
  /// This method is designed to be crash-safe:
  /// - Catches all exceptions during load/parse
  /// - Falls back to fresh state if anything goes wrong
  /// - Migrates outdated state to match current curriculum
  /// - Always leaves the app in a valid, launchable state
  Future<void> init() async {
    try {
      final loadedState = await _repository.load();

      if (loadedState != null) {
        // Validate and migrate to current curriculum if needed
        final (migratedState, wasMigrated) =
            LearningState.migrateToCurrentCurriculum(loadedState);

        _state = migratedState;

        // Save migrated state to persist the fix
        if (wasMigrated) {
          if (kDebugMode) {
            print('[StoryModeController] MIGRATION: old=${loadedState.moveProgress.length} '
                'new=${migratedState.moveProgress.length}, saving migrated state');
          }
          await _repository.save(_state);
        }
      } else {
        // No saved state - initialize fresh
        _state = LearningProgressService.initializeFreshState();
      }
    } catch (e, stackTrace) {
      // Catch-all for any unexpected errors during init
      // This ensures the app NEVER crashes on launch due to persisted data
      if (kDebugMode) {
        print('[StoryModeController] Error during init, resetting to fresh state: $e');
        print(stackTrace);
      }

      // Clear corrupted storage and start fresh
      try {
        await _repository.clear();
      } catch (_) {
        // Ignore errors from clear - we're already in error recovery
      }

      _state = LearningProgressService.initializeFreshState();
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Unlocks a specific learning move by ID.
  ///
  /// This is the instant-unlock operation triggered by the UNLOCK button.
  /// It marks the move as fully unlocked and complete, then:
  /// - Updates the in-memory state
  /// - Saves to persistent storage
  /// - Notifies all listeners to rebuild UI
  Future<void> unlockMove(int moveId) async {
    _state = LearningProgressService.unlockMove(_state, moveId);

    // Save to storage in the background
    await _repository.save(_state);

    // Notify listeners so UI updates
    notifyListeners();
  }

  /// Marks a drill as completed for a specific learning move.
  ///
  /// Used for the full drill/progression/exam flow (not yet implemented).
  Future<void> markDrillDone(int moveId) async {
    _state = LearningProgressService.completeDrill(_state);
    await _repository.save(_state);
    notifyListeners();
  }

  /// Marks the Add to Arsenal session as completed for a specific learning move.
  ///
  /// This is called after the user successfully completes the Arsenal integration session.
  Future<void> markAddToArsenalDone(int moveId) async {
    _state = LearningProgressService.completeAddToArsenal(_state, moveId);
    await _repository.save(_state);
    notifyListeners();
  }

  /// Marks a progression session as completed for the current move.
  ///
  /// Used for the full drill/progression/exam flow (not yet implemented).
  Future<void> markProgressionSessionDone() async {
    _state = LearningProgressService.completeProgressionSession(_state);
    await _repository.save(_state);
    notifyListeners();
  }

  /// Marks an exam as passed for a specific learning move and unlocks it.
  ///
  /// This is the final step in the Academy progression flow.
  Future<void> markExamPassed(int moveId) async {
    _state = LearningProgressService.completeExam(_state, moveId);
    await _repository.save(_state);
    notifyListeners();
  }

  /// Legacy method for backward compatibility.
  /// Used for the full drill/progression/exam flow (not yet implemented).
  Future<void> _legacyMarkExamPassed() async {
    _state = LearningProgressService.passExam(_state);
    await _repository.save(_state);
    notifyListeners();
  }

  /// Resets all Story Mode progress.
  ///
  /// Useful for testing or if the user wants to start over.
  Future<void> reset() async {
    _state = LearningProgressService.initializeFreshState();
    await _repository.clear();
    notifyListeners();
  }
}
