import 'learning_move_progress.dart';
import 'learning_path.dart';
import 'learning_state.dart';
import 'next_action.dart';

/// Service that manages Story Mode learning progression logic.
///
/// Handles:
/// - Computing the next action (Drill/Progression/Exam/Complete)
/// - Updating progress when activities are completed
/// - Unlocking moves when requirements are met
/// - Initializing learning state for new users
class LearningProgressService {
  /// Gets the required number of progression sessions for a given phase.
  ///
  /// Phase 1: 1 session
  /// Phases 2-3: 2-3 sessions (using 2 for consistency)
  /// Phases 4-6: 3 sessions
  static int getRequiredProgressionSessions(int phase) {
    switch (phase) {
      case 1:
        return 1;
      case 2:
      case 3:
        return 2;
      case 4:
      case 5:
      case 6:
        return 3;
      default:
        return 3; // Default to 3 for unknown phases
    }
  }

  /// Computes the next action the user should take based on current state.
  ///
  /// Decision logic:
  /// 1. If all moves unlocked → LearningComplete
  /// 2. Get current move (first non-unlocked)
  /// 3. If drill not done → Drill
  /// 4. If progression sessions incomplete → Progression
  /// 5. If exam not passed → Exam
  /// 6. Otherwise → should not happen (move should be unlocked)
  static NextAction computeNextAction(LearningState state) {
    // Check if learning is complete
    if (state.learningComplete) {
      return NextAction.complete();
    }

    // Get current move
    final currentMove = state.currentMove;
    if (currentMove == null) {
      // Should not happen if learningComplete is false
      return NextAction.complete();
    }

    // Get progress for current move
    final progress = state.getProgressForMove(currentMove.id);
    if (progress == null) {
      // Should not happen - return drill as safe default
      return NextAction.drill(currentMove.id);
    }

    // Decision tree
    if (!progress.drillDone) {
      return NextAction.drill(currentMove.id);
    }

    final requiredSessions = getRequiredProgressionSessions(currentMove.phase);
    if (progress.progressionSessionsDone < requiredSessions) {
      return NextAction.progression(currentMove.id);
    }

    if (!progress.examPassed) {
      return NextAction.exam(currentMove.id);
    }

    // If we reach here, the move should have been unlocked
    // Return exam as a safe fallback
    return NextAction.exam(currentMove.id);
  }

  /// Marks the drill as completed for the current move.
  ///
  /// Returns updated state with drillDone set to true.
  static LearningState completeDrill(LearningState state) {
    final currentMove = state.currentMove;
    if (currentMove == null) return state;

    final progress = state.getProgressForMove(currentMove.id);
    if (progress == null) return state;

    final updatedProgress = progress.copyWith(drillDone: true);
    return state.updateMoveProgress(currentMove.id, updatedProgress);
  }

  /// Increments the progression sessions count for the current move.
  ///
  /// Returns updated state with progressionSessionsDone incremented by 1.
  static LearningState completeProgressionSession(LearningState state) {
    final currentMove = state.currentMove;
    if (currentMove == null) return state;

    final progress = state.getProgressForMove(currentMove.id);
    if (progress == null) return state;

    final updatedProgress = progress.copyWith(
      progressionSessionsDone: progress.progressionSessionsDone + 1,
    );
    return state.updateMoveProgress(currentMove.id, updatedProgress);
  }

  /// Marks the exam as passed for the current move and unlocks it.
  ///
  /// Also unlocks the next move in sequence.
  /// Returns updated state with examPassed and isUnlocked set to true.
  static LearningState passExam(LearningState state) {
    final currentMove = state.currentMove;
    if (currentMove == null) return state;

    final progress = state.getProgressForMove(currentMove.id);
    if (progress == null) return state;

    // Mark current move as passed and unlocked
    final updatedProgress = progress.copyWith(
      examPassed: true,
      isUnlocked: true,
    );
    var updatedState = state.updateMoveProgress(currentMove.id, updatedProgress);

    // Unlock the next move in sequence
    final allMoves = LearningPath.getAllMoves();
    final currentIndex = LearningPath.getUnlockIndex(currentMove);

    if (currentIndex < allMoves.length - 1) {
      final nextMove = allMoves[currentIndex + 1];
      final nextProgress = updatedState.getProgressForMove(nextMove.id);

      if (nextProgress != null && !nextProgress.isUnlocked) {
        final unlockedNextProgress = nextProgress.copyWith(isUnlocked: true);
        updatedState = updatedState.updateMoveProgress(nextMove.id, unlockedNextProgress);
      }
    }

    return updatedState;
  }

  /// Initializes a fresh LearningState for a new user.
  ///
  /// Creates progress entries for all 18 moves:
  /// - Move 1 (Jab) is unlocked and ready to start
  /// - Moves 2-18 are locked
  static LearningState initializeFreshState() {
    final allMoves = LearningPath.getAllMoves();

    final progressList = allMoves.map((move) {
      // First move (Jab) starts unlocked
      if (move.id == 1) {
        return LearningMoveProgress.initial(move.id).copyWith(isUnlocked: true);
      }

      // All other moves start locked
      return LearningMoveProgress.initial(move.id);
    }).toList();

    return LearningState(moveProgress: progressList);
  }
}
