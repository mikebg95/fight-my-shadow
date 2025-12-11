/// Represents the next action a user should take in Academy learning.
///
/// The progression flow is:
/// 1. Drill - Learn the move with guided practice
/// 2. Progression - Practice the move multiple times (1-3 sessions based on level)
/// 3. Exam - Test mastery of the move
/// 4. LearningComplete - All 38 moves have been unlocked
enum NextActionType {
  drill,
  progression,
  exam,
  learningComplete,
}

/// Contains the next action the user should take and the associated move.
class NextAction {
  final NextActionType type;
  final int? moveId; // null when type is learningComplete

  const NextAction({
    required this.type,
    this.moveId,
  });

  /// Factory for drill action.
  factory NextAction.drill(int moveId) {
    return NextAction(type: NextActionType.drill, moveId: moveId);
  }

  /// Factory for progression action.
  factory NextAction.progression(int moveId) {
    return NextAction(type: NextActionType.progression, moveId: moveId);
  }

  /// Factory for exam action.
  factory NextAction.exam(int moveId) {
    return NextAction(type: NextActionType.exam, moveId: moveId);
  }

  /// Factory for learning complete.
  factory NextAction.complete() {
    return const NextAction(type: NextActionType.learningComplete);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NextAction &&
        other.type == type &&
        other.moveId == moveId;
  }

  @override
  int get hashCode => Object.hash(type, moveId);

  @override
  String toString() {
    if (type == NextActionType.learningComplete) {
      return 'NextAction(learningComplete)';
    }
    return 'NextAction($type, moveId: $moveId)';
  }
}
