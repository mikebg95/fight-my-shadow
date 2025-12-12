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
///
/// Usage:
/// - Create once at app startup
/// - Call init() to load persisted state
/// - Inject into screens via InheritedWidget, Provider, or similar
/// - Screens listen to changes via ChangeNotifier
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
  /// If persisted state exists, it will be loaded. Otherwise,
  /// a fresh initial state will be used.
  Future<void> init() async {
    final loadedState = await _repository.load();

    if (loadedState != null) {
      _state = loadedState;
    } else {
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

  /// Marks an exam as passed for the current move.
  ///
  /// Used for the full drill/progression/exam flow (not yet implemented).
  Future<void> markExamPassed() async {
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
