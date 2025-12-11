import 'learning_move.dart';
import 'learning_move_progress.dart';
import 'learning_path.dart';

/// Represents the entire Story Mode learning progress for a user.
///
/// Contains progress for all 18 learning moves and computed properties
/// for current move and overall completion status.
class LearningState {
  /// Progress for all 18 learning moves (indexed by moveId - 1)
  final List<LearningMoveProgress> moveProgress;

  const LearningState({
    required this.moveProgress,
  });

  /// Gets the current move the user should work on next.
  /// Returns the first unlocked move in the learning path order.
  /// Returns null if learning is complete (all moves unlocked).
  LearningMove? get currentMove {
    final allMoves = LearningPath.getAllMoves();

    for (final move in allMoves) {
      final progress = getProgressForMove(move.id);
      if (progress != null && !progress.isUnlocked) {
        return move;
      }
    }

    return null; // All moves unlocked
  }

  /// Returns true when all 18 moves are unlocked.
  bool get learningComplete {
    return moveProgress.every((progress) => progress.isUnlocked);
  }

  /// Gets the progress for a specific move by ID (1-18).
  LearningMoveProgress? getProgressForMove(int moveId) {
    if (moveId < 1 || moveId > 18) return null;
    return moveProgress.firstWhere(
      (p) => p.moveId == moveId,
      orElse: () => LearningMoveProgress.initial(moveId),
    );
  }

  /// Creates a new LearningState with updated progress for a specific move.
  LearningState updateMoveProgress(int moveId, LearningMoveProgress newProgress) {
    final updatedList = moveProgress.map((p) {
      return p.moveId == moveId ? newProgress : p;
    }).toList();

    return LearningState(moveProgress: updatedList);
  }

  /// Creates a copy with the specified changes.
  LearningState copyWith({
    List<LearningMoveProgress>? moveProgress,
  }) {
    return LearningState(
      moveProgress: moveProgress ?? this.moveProgress,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LearningState) return false;

    if (moveProgress.length != other.moveProgress.length) return false;
    for (int i = 0; i < moveProgress.length; i++) {
      if (moveProgress[i] != other.moveProgress[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hashAll(moveProgress);

  @override
  String toString() {
    final current = currentMove;
    return 'LearningState(currentMove: ${current?.displayName ?? 'Complete'}, '
           'learningComplete: $learningComplete, '
           'totalMoves: ${moveProgress.length})';
  }
}
