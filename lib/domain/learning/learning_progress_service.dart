import 'learning_move_progress.dart';
import 'learning_path.dart';
import 'learning_state.dart';
import 'next_action.dart';

/// Service that manages Academy learning progression logic.
///
/// Handles:
/// - Computing the next action (Drill/Progression/Exam/Complete)
/// - Updating progress when activities are completed
/// - Unlocking moves when requirements are met
/// - Initializing learning state for new users
class LearningProgressService {
  /// Gets the required number of progression sessions for a given level.
  ///
  /// Level 1: 1 session (basics)
  /// Levels 2-3: 2 sessions
  /// Levels 4-12: 3 sessions
  static int getRequiredProgressionSessions(int level) {
    switch (level) {
      case 1:
        return 1;
      case 2:
      case 3:
        return 2;
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
      case 11:
      case 12:
        return 3;
      default:
        return 3; // Default to 3 for unknown levels
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

    if (!progress.addToArsenalDone) {
      return NextAction.addToArsenal(currentMove.id);
    }

    final requiredSessions = getRequiredProgressionSessions(currentMove.level);
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

  /// Marks the Add to Arsenal session as completed for a specific move.
  ///
  /// Returns updated state with addToArsenalDone set to true.
  /// If this is the last required step, also marks the move as unlocked.
  static LearningState completeAddToArsenal(LearningState state, int moveId) {
    final progress = state.getProgressForMove(moveId);
    if (progress == null) return state;

    // For now, completing Add to Arsenal unlocks the move
    // Later we can add progression sessions and exams as additional requirements
    final updatedProgress = progress.copyWith(
      addToArsenalDone: true,
      isUnlocked: true, // Auto-unlock after Add to Arsenal
    );
    return state.updateMoveProgress(moveId, updatedProgress);
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
  /// Creates progress entries for all 38 moves:
  /// - All moves start locked (isUnlocked = false)
  /// - Current move (first not-unlocked) will be Move 1 (Jab)
  /// - Jab will show as "Ready to Unlock", not "Unlocked"
  static LearningState initializeFreshState() {
    final allMoves = LearningPath.getAllMoves();

    // All moves start completely locked - no special cases
    final progressList = allMoves.map((move) {
      return LearningMoveProgress.initial(move.id);
    }).toList();

    return LearningState(moveProgress: progressList);
  }

  /// Unlocks a specific learning move by ID.
  ///
  /// This is a simple unlock operation that marks the move as unlocked
  /// and complete (drillDone, progressionSessions, examPassed all set to true).
  /// Used for the instant-unlock button on Move Detail screen.
  static LearningState unlockMove(LearningState state, int moveId) {
    final progress = state.getProgressForMove(moveId);
    if (progress == null) return state;

    // Mark move as fully unlocked and complete
    final unlockedProgress = progress.copyWith(
      isUnlocked: true,
      drillDone: true,
      examPassed: true,
      // Set progression sessions to the required amount for this move's level
      progressionSessionsDone: getRequiredProgressionSessions(
        LearningPath.getMoveById(moveId)?.level ?? 1,
      ),
    );

    return state.updateMoveProgress(moveId, unlockedProgress);
  }
}
