import 'package:flutter/foundation.dart';
import 'learning_move.dart';
import 'learning_move_progress.dart';
import 'learning_path.dart';

/// Represents the entire Story Mode learning progress for a user.
///
/// Contains progress for all learning moves and computed properties
/// for current move and overall completion status.
///
/// The number of moves is determined dynamically by [LearningPath.totalMoves].
/// Currently there are 37 learning moves in the Academy curriculum.
class LearningState {
  /// Progress for all learning moves in the path
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

  /// Returns true when all moves are unlocked.
  bool get learningComplete {
    return moveProgress.every((progress) => progress.isUnlocked);
  }

  /// Gets the progress for a specific move by ID (1-37).
  /// Returns null if moveId is invalid or not found.
  LearningMoveProgress? getProgressForMove(int moveId) {
    // Validate against actual learning path size
    final totalMoves = LearningPath.totalMoves;
    if (moveId < 1 || moveId > totalMoves) return null;

    try {
      return moveProgress.firstWhere(
        (p) => p.moveId == moveId,
      );
    } catch (e) {
      return LearningMoveProgress.initial(moveId);
    }
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

  /// Converts this state to a JSON map for persistence.
  Map<String, dynamic> toJson() {
    return {
      'moveProgress': moveProgress.map((p) => p.toJson()).toList(),
    };
  }

  /// Creates a LearningState from a JSON map.
  factory LearningState.fromJson(Map<String, dynamic> json) {
    final progressList = (json['moveProgress'] as List)
        .map((item) => LearningMoveProgress.fromJson(item as Map<String, dynamic>))
        .toList();

    return LearningState(moveProgress: progressList);
  }

  /// Validates and migrates the current state to match the current curriculum.
  ///
  /// This method ensures the app doesn't crash when the curriculum changes
  /// (moves added, removed, or reordered). It preserves user progress while
  /// ensuring the state matches the current [LearningPath].
  ///
  /// Migration strategy:
  /// 1. If saved progress length matches current curriculum, validate and return
  /// 2. For each move in current curriculum:
  ///    - If progress exists for that moveId, preserve it
  ///    - If no progress exists, create fresh initial progress
  /// 3. Discard progress for moveIds that no longer exist in curriculum
  ///
  /// Returns the migrated state and a flag indicating if migration occurred.
  /// If the state was already valid, returns itself unchanged.
  static (LearningState state, bool migrated) migrateToCurrentCurriculum(
    LearningState loadedState,
  ) {
    final currentMoves = LearningPath.getAllMoves();
    final expectedMoveCount = currentMoves.length;
    final loadedProgress = loadedState.moveProgress;

    // Build a lookup map from loaded progress for efficient access
    final progressByMoveId = <int, LearningMoveProgress>{};
    for (final progress in loadedProgress) {
      progressByMoveId[progress.moveId] = progress;
    }

    // Check if migration is needed
    bool needsMigration = false;

    // 1. Length mismatch indicates curriculum change
    if (loadedProgress.length != expectedMoveCount) {
      needsMigration = true;
      if (kDebugMode) {
        print('[LearningState] Migration needed: progress count '
            '(${loadedProgress.length}) != curriculum count ($expectedMoveCount)');
      }
    }

    // 2. Check if all expected moveIds are present
    if (!needsMigration) {
      for (final move in currentMoves) {
        if (!progressByMoveId.containsKey(move.id)) {
          needsMigration = true;
          if (kDebugMode) {
            print('[LearningState] Migration needed: missing progress for '
                'moveId ${move.id} (${move.displayName})');
          }
          break;
        }
      }
    }

    // If no migration needed, return original state
    if (!needsMigration) {
      return (loadedState, false);
    }

    // Build migrated progress list, preserving existing progress where possible
    final migratedProgress = <LearningMoveProgress>[];

    for (final move in currentMoves) {
      final existingProgress = progressByMoveId[move.id];
      if (existingProgress != null) {
        // Preserve existing progress
        migratedProgress.add(existingProgress);
      } else {
        // Create fresh progress for new/missing moves
        migratedProgress.add(LearningMoveProgress.initial(move.id));
        if (kDebugMode) {
          print('[LearningState] Created fresh progress for moveId ${move.id} '
              '(${move.displayName})');
        }
      }
    }

    if (kDebugMode) {
      final preserved = migratedProgress
          .where((p) => progressByMoveId.containsKey(p.moveId) &&
                        (progressByMoveId[p.moveId]!.isUnlocked ||
                         progressByMoveId[p.moveId]!.drillDone))
          .length;
      print('[LearningState] Migration complete: preserved $preserved moves '
          'with progress, total ${migratedProgress.length} moves');
    }

    return (LearningState(moveProgress: migratedProgress), true);
  }

  /// Checks if this state is valid for the current curriculum.
  ///
  /// Returns true if:
  /// - Progress count matches [LearningPath.totalMoves]
  /// - All moveIds in current curriculum have progress entries
  bool get isValidForCurrentCurriculum {
    final currentMoves = LearningPath.getAllMoves();

    if (moveProgress.length != currentMoves.length) {
      return false;
    }

    final progressIds = moveProgress.map((p) => p.moveId).toSet();
    for (final move in currentMoves) {
      if (!progressIds.contains(move.id)) {
        return false;
      }
    }

    return true;
  }
}
