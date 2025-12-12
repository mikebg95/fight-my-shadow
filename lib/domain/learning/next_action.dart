/// Represents the next action a user should take in Academy learning.
///
/// The progression flow is:
/// 1. Drill - Learn the move with guided practice
/// 2. Add to Arsenal - Integrate the move with unlocked moves through weighted practice
/// 3. Progression - Practice the move multiple times (1-3 sessions based on level)
/// 4. Exam - Test mastery of the move
/// 5. LearningComplete - All 18 moves have been unlocked
enum NextActionType {
  drill,
  addToArsenal,
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

  /// Factory for add to arsenal action.
  factory NextAction.addToArsenal(int moveId) {
    return NextAction(type: NextActionType.addToArsenal, moveId: moveId);
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
