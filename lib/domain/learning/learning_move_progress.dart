/// Represents the learning progress for a single LearningMove.
///
/// This tracks completion status for the stages of learning a move:
/// 1. Drill - initial focused practice
/// 2. Add to Arsenal - integrate the move with unlocked moves
/// 3. Progression - applying the move in workout sessions (future)
/// 4. Exam - testing mastery of the move (future)
///
/// When all stages are complete, the move is unlocked and the user
/// advances to the next move in the learning path.
class LearningMoveProgress {
  /// The ID of the LearningMove this progress refers to (1-38).
  final int moveId;

  /// Whether the Drill session for this move has been completed.
  ///
  /// Drills introduce the move with focused, repetitive practice.
  final bool drillDone;

  /// Whether the Add to Arsenal session for this move has been completed.
  ///
  /// Add to Arsenal integrates the newly drilled move with previously
  /// unlocked moves through weighted practice sessions.
  final bool addToArsenalDone;

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
  /// - Add to Arsenal is done
  /// - Required progression sessions are complete (future)
  /// - Exam is passed (future)
  ///
  /// When unlocked, the user advances to the next move.
  final bool isUnlocked;

  const LearningMoveProgress({
    required this.moveId,
    required this.drillDone,
    required this.addToArsenalDone,
    required this.progressionSessionsDone,
    required this.examPassed,
    required this.isUnlocked,
  });

  /// Creates a fresh progress entry for a new move (nothing completed yet).
  factory LearningMoveProgress.initial(int moveId) {
    return LearningMoveProgress(
      moveId: moveId,
      drillDone: false,
      addToArsenalDone: false,
      progressionSessionsDone: 0,
      examPassed: false,
      isUnlocked: false,
    );
  }

  /// Creates a copy with updated fields.
  LearningMoveProgress copyWith({
    int? moveId,
    bool? drillDone,
    bool? addToArsenalDone,
    int? progressionSessionsDone,
    bool? examPassed,
    bool? isUnlocked,
  }) {
    return LearningMoveProgress(
      moveId: moveId ?? this.moveId,
      drillDone: drillDone ?? this.drillDone,
      addToArsenalDone: addToArsenalDone ?? this.addToArsenalDone,
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
          addToArsenalDone == other.addToArsenalDone &&
          progressionSessionsDone == other.progressionSessionsDone &&
          examPassed == other.examPassed &&
          isUnlocked == other.isUnlocked;

  @override
  int get hashCode => Object.hash(
        moveId,
        drillDone,
        addToArsenalDone,
        progressionSessionsDone,
        examPassed,
        isUnlocked,
      );

  @override
  String toString() =>
      'LearningMoveProgress(moveId: $moveId, drill: $drillDone, arsenal: $addToArsenalDone, progression: $progressionSessionsDone, exam: $examPassed, unlocked: $isUnlocked)';

  /// Converts this progress to a JSON map for persistence.
  Map<String, dynamic> toJson() {
    return {
      'moveId': moveId,
      'drillDone': drillDone,
      'addToArsenalDone': addToArsenalDone,
      'progressionSessionsDone': progressionSessionsDone,
      'examPassed': examPassed,
      'isUnlocked': isUnlocked,
    };
  }

  /// Creates a LearningMoveProgress from a JSON map.
  /// Handles migration from older versions without addToArsenalDone field.
  factory LearningMoveProgress.fromJson(Map<String, dynamic> json) {
    return LearningMoveProgress(
      moveId: json['moveId'] as int,
      drillDone: json['drillDone'] as bool,
      addToArsenalDone: json['addToArsenalDone'] as bool? ?? false, // Migration: default to false for old saves
      progressionSessionsDone: json['progressionSessionsDone'] as int,
      examPassed: json['examPassed'] as bool,
      isUnlocked: json['isUnlocked'] as bool,
    );
  }
}
