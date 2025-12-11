import 'package:fight_my_shadow/domain/learning/learning_path.dart';
import 'package:fight_my_shadow/domain/learning/learning_state.dart';

/// Result of checking a move's lock status.
class MoveLockStatus {
  /// Whether the move is unlocked (accessible to the user).
  final bool isUnlocked;

  /// Whether the move is part of the learning path.
  final bool isInLearningPath;

  const MoveLockStatus({
    required this.isUnlocked,
    required this.isInLearningPath,
  });

  /// Creates a locked status (default state).
  const MoveLockStatus.locked()
      : isUnlocked = false,
        isInLearningPath = false;

  /// Creates an unlocked status.
  const MoveLockStatus.unlocked({this.isInLearningPath = true})
      : isUnlocked = true;
}

/// Service that determines whether a move is locked or unlocked based on
/// Story Mode learning progress.
///
/// Uses LearningPath and LearningState to decide:
/// - If a move's code appears in any LearningMove's moveCodes
/// - If that LearningMove has been unlocked (isUnlocked = true)
///
/// By default, all moves are locked until Story Mode unlocks them.
class MoveLockStatusResolver {
  /// Determines the lock status of a move by its code.
  ///
  /// Returns:
  /// - isUnlocked = true if the move is part of a LearningMove that has been unlocked
  /// - isUnlocked = false otherwise (default locked state)
  /// - isInLearningPath = true if the move code appears in any LearningMove
  static MoveLockStatus getStatus(String moveCode, LearningState learningState) {
    // Get all learning moves
    final allLearningMoves = LearningPath.getAllMoves();

    // Find any LearningMove that contains this move code
    for (final learningMove in allLearningMoves) {
      if (learningMove.moveCodes.contains(moveCode)) {
        // This move is part of the learning path
        // Check if the LearningMove is unlocked
        final progress = learningState.getProgressForMove(learningMove.id);

        if (progress != null && progress.isUnlocked) {
          // The learning move is unlocked, so this move is unlocked
          return const MoveLockStatus.unlocked(isInLearningPath: true);
        }

        // Found in learning path but not yet unlocked
        return const MoveLockStatus(
          isUnlocked: false,
          isInLearningPath: true,
        );
      }
    }

    // Not found in any learning move - treat as locked and not in learning path
    // (In the future, we might have moves that are "free" and not part of Story Mode,
    // but for now everything is locked by default)
    return const MoveLockStatus.locked();
  }

  /// Convenience method to check if a move is unlocked (simple boolean).
  static bool isUnlocked(String moveCode, LearningState learningState) {
    return getStatus(moveCode, learningState).isUnlocked;
  }
}
