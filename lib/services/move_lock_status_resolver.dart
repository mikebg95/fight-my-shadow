import 'package:fight_my_shadow/domain/learning/learning_move.dart';
import 'package:fight_my_shadow/domain/learning/learning_path.dart';
import 'package:fight_my_shadow/domain/learning/learning_state.dart';

/// Visual state of a move in the UI.
enum MoveUnlockState {
  /// Move has been fully unlocked by Story Mode.
  unlocked,

  /// Move is the current learning move - drill not yet completed.
  readyToUnlockDrillPending,

  /// Move is the current learning move - drill completed, ready to add to arsenal.
  readyToUnlockArsenalPending,

  /// Move is the current learning move - arsenal completed, ready for exam.
  readyToUnlockExamPending,

  /// Move is locked and comes after the current move.
  locked,
}

/// Service that determines the unlock state of a move based on Story Mode progress.
///
/// Returns one of four visual states:
/// - Unlocked: Move has been fully unlocked
/// - ReadyToUnlockDrillPending: Move is current, drill not yet done
/// - ReadyToUnlockArsenalPending: Move is current, drill done, arsenal pending
/// - Locked: Move comes after the current move
class MoveLockStatusResolver {
  /// Determines the visual unlock state of a move by its code.
  ///
  /// Takes the current learning move and drill completion into account
  /// to show the appropriate action button.
  static MoveUnlockState getUnlockState(
    String moveCode,
    LearningState learningState,
    LearningMove? currentMove,
  ) {
    // Get all learning moves
    final allLearningMoves = LearningPath.getAllMoves();

    // Find any LearningMove that contains this move code
    for (final learningMove in allLearningMoves) {
      if (learningMove.moveCodes.contains(moveCode)) {
        // This move is part of the learning path
        final progress = learningState.getProgressForMove(learningMove.id);

        if (progress != null && progress.isUnlocked) {
          // The learning move is unlocked
          return MoveUnlockState.unlocked;
        }

        // Check if this is the current learning move (ready to unlock)
        if (currentMove != null && currentMove.id == learningMove.id) {
          // Check progression: Drill -> Arsenal -> Exam -> Unlocked
          if (progress != null) {
            if (!progress.drillDone) {
              return MoveUnlockState.readyToUnlockDrillPending;
            } else if (!progress.addToArsenalDone) {
              return MoveUnlockState.readyToUnlockArsenalPending;
            } else if (!progress.examPassed) {
              return MoveUnlockState.readyToUnlockExamPending;
            }
          }
          // All done but not marked unlocked yet (shouldn't happen)
          return MoveUnlockState.readyToUnlockExamPending;
        }

        // Not unlocked and not current - it's locked
        return MoveUnlockState.locked;
      }
    }

    // Not found in any learning move - treat as locked
    return MoveUnlockState.locked;
  }

  /// Convenience method to check if a move is unlocked (simple boolean).
  /// Deprecated - use getUnlockState for full state information.
  @Deprecated('Use getUnlockState instead for three-state support')
  static bool isUnlocked(String moveCode, LearningState learningState) {
    final allLearningMoves = LearningPath.getAllMoves();

    for (final learningMove in allLearningMoves) {
      if (learningMove.moveCodes.contains(moveCode)) {
        final progress = learningState.getProgressForMove(learningMove.id);
        return progress != null && progress.isUnlocked;
      }
    }

    return false;
  }
}
