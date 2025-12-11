/// Represents the learning progress for a single LearningMove.
///
/// This tracks completion status for the three stages of learning a move:
/// 1. Drill - initial focused practice
/// 2. Progression - applying the move in workout sessions
/// 3. Exam - testing mastery of the move
///
/// When all three stages are complete, the move is unlocked and the user
/// advances to the next move in the learning path.
class LearningMoveProgress {
  /// The ID of the LearningMove this progress refers to (1-38).
  final int moveId;

  /// Whether the Drill session for this move has been completed.
  ///
  /// Drills introduce the move with focused, repetitive practice.
  final bool drillDone;

  /// Number of Progression sessions completed for this move.
  ///
  /// Progression sessions apply the move in realistic workout scenarios.
  /// The required number varies by level (see level-based requirements).
  final int progressionSessionsDone;

  /// Whether the Exam for this move has been passed.
  ///
  /// Exams test the user's mastery and understanding of the move.
  final bool examPassed;

  /// Whether this move has been fully unlocked.
  ///
  /// A move is unlocked when:
  /// - Drill is done
  /// - Required progression sessions are complete
  /// - Exam is passed
  ///
  /// When unlocked, the user advances to the next move.
  final bool isUnlocked;

  const LearningMoveProgress({
    required this.moveId,
    required this.drillDone,
    required this.progressionSessionsDone,
    required this.examPassed,
    required this.isUnlocked,
  });

  /// Creates a fresh progress entry for a new move (nothing completed yet).
  factory LearningMoveProgress.initial(int moveId) {
    return LearningMoveProgress(
      moveId: moveId,
      drillDone: false,
      progressionSessionsDone: 0,
      examPassed: false,
      isUnlocked: false,
    );
  }

  /// Creates a copy with updated fields.
  LearningMoveProgress copyWith({
    int? moveId,
    bool? drillDone,
    int? progressionSessionsDone,
    bool? examPassed,
    bool? isUnlocked,
  }) {
    return LearningMoveProgress(
      moveId: moveId ?? this.moveId,
      drillDone: drillDone ?? this.drillDone,
      progressionSessionsDone:
          progressionSessionsDone ?? this.progressionSessionsDone,
      examPassed: examPassed ?? this.examPassed,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningMoveProgress &&
          runtimeType == other.runtimeType &&
          moveId == other.moveId &&
          drillDone == other.drillDone &&
          progressionSessionsDone == other.progressionSessionsDone &&
          examPassed == other.examPassed &&
          isUnlocked == other.isUnlocked;

  @override
  int get hashCode => Object.hash(
        moveId,
        drillDone,
        progressionSessionsDone,
        examPassed,
        isUnlocked,
      );

  @override
  String toString() =>
      'LearningMoveProgress(moveId: $moveId, drill: $drillDone, progression: $progressionSessionsDone, exam: $examPassed, unlocked: $isUnlocked)';

  /// Converts this progress to a JSON map for persistence.
  Map<String, dynamic> toJson() {
    return {
      'moveId': moveId,
      'drillDone': drillDone,
      'progressionSessionsDone': progressionSessionsDone,
      'examPassed': examPassed,
      'isUnlocked': isUnlocked,
    };
  }

  /// Creates a LearningMoveProgress from a JSON map.
  factory LearningMoveProgress.fromJson(Map<String, dynamic> json) {
    return LearningMoveProgress(
      moveId: json['moveId'] as int,
      drillDone: json['drillDone'] as bool,
      progressionSessionsDone: json['progressionSessionsDone'] as int,
      examPassed: json['examPassed'] as bool,
      isUnlocked: json['isUnlocked'] as bool,
    );
  }
}
