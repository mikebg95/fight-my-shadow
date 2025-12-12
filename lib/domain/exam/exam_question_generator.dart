import 'dart:math';
import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/main.dart';

/// Generates exam questions for Academy exams.
///
/// Questions test CODE → MOVE recognition with plausible distractors.
/// The target (new) move appears ~40% of the time, other unlocked moves ~60%.
class ExamQuestionGenerator {
  final Random _random = Random();

  /// Generates a list of exam questions.
  ///
  /// [targetMove]: The new move being tested (appears ~40% of time)
  /// [unlockedMoves]: Previously unlocked moves (appear ~60% of time)
  /// [questionCount]: Total number of questions to generate
  ///
  /// Returns a list of ExamQuestion objects with shuffled options.
  List<ExamQuestion> generateQuestions({
    required Move targetMove,
    required List<Move> unlockedMoves,
    required int questionCount,
  }) {
    final questions = <ExamQuestion>[];
    final allMoves = [targetMove, ...unlockedMoves];
    int consecutiveTargetCount = 0;

    for (int i = 0; i < questionCount; i++) {
      // Weighted sampling: target move gets 6x weight vs 1x for others
      final correctMove = _selectCorrectMove(
        targetMove: targetMove,
        unlockedMoves: unlockedMoves,
        consecutiveTargetCount: consecutiveTargetCount,
      );

      // Track consecutive target move questions
      if (correctMove.code == targetMove.code) {
        consecutiveTargetCount++;
      } else {
        consecutiveTargetCount = 0;
      }

      // Generate distractors (2 wrong options)
      final distractors = _generateDistractors(
        correctMove: correctMove,
        allMoves: allMoves,
      );

      // Create options list and shuffle
      final options = [correctMove.name, ...distractors];
      options.shuffle(_random);

      questions.add(ExamQuestion(
        code: correctMove.code,
        correctMoveName: correctMove.name,
        options: options,
      ));
    }

    return questions;
  }

  /// Selects the correct move for a question using weighted sampling.
  ///
  /// Target move gets 6x weight. Prevents more than 3 consecutive target moves.
  Move _selectCorrectMove({
    required Move targetMove,
    required List<Move> unlockedMoves,
    required int consecutiveTargetCount,
  }) {
    // Prevent long streaks: force unlocked move after 3 consecutive target moves
    if (consecutiveTargetCount >= 3 && unlockedMoves.isNotEmpty) {
      return unlockedMoves[_random.nextInt(unlockedMoves.length)];
    }

    // Build weighted pool
    final weightedPool = <Move>[];

    // Add target move 6 times (6x weight)
    for (int i = 0; i < 6; i++) {
      weightedPool.add(targetMove);
    }

    // Add each unlocked move once (1x weight)
    weightedPool.addAll(unlockedMoves);

    // If only target move exists, return it
    if (weightedPool.isEmpty) {
      return targetMove;
    }

    return weightedPool[_random.nextInt(weightedPool.length)];
  }

  /// Generates 2 plausible distractors for the correct move.
  ///
  /// Strategy:
  /// 1. Prefer same category (punch/defense/footwork/feint)
  /// 2. Include left/right counterpart if applicable
  /// 3. Ensure distractors are distinct from correct answer
  List<String> _generateDistractors({
    required Move correctMove,
    required List<Move> allMoves,
  }) {
    final distractors = <String>[];
    final availableMoves = allMoves.where((m) => m.code != correctMove.code).toList();

    if (availableMoves.isEmpty) {
      // Edge case: only one move available (shouldn't happen in practice)
      return ['Unknown Move A', 'Unknown Move B'];
    }

    // Strategy 1: Try to add left/right counterpart
    final counterpart = _findCounterpart(correctMove, availableMoves);
    if (counterpart != null) {
      distractors.add(counterpart.name);
    }

    // Strategy 2: Add moves from same category
    final sameCategoryMoves = availableMoves
        .where((m) =>
            m.category == correctMove.category &&
            !distractors.contains(m.name))
        .toList();

    while (distractors.length < 2 && sameCategoryMoves.isNotEmpty) {
      final move = sameCategoryMoves.removeAt(_random.nextInt(sameCategoryMoves.length));
      distractors.add(move.name);
    }

    // Strategy 3: Fill remaining with any available moves
    final remainingMoves = availableMoves
        .where((m) => !distractors.contains(m.name))
        .toList();

    while (distractors.length < 2 && remainingMoves.isNotEmpty) {
      final move = remainingMoves.removeAt(_random.nextInt(remainingMoves.length));
      distractors.add(move.name);
    }

    // Edge case: if still not enough, duplicate (shouldn't happen)
    while (distractors.length < 2) {
      distractors.add(availableMoves[_random.nextInt(availableMoves.length)].name);
    }

    return distractors.take(2).toList();
  }

  /// Finds the left/right counterpart of a move if it exists.
  ///
  /// Examples: Slip Left ↔ Slip Right, Pivot Left ↔ Pivot Right
  Move? _findCounterpart(Move move, List<Move> availableMoves) {
    final nameLower = move.name.toLowerCase();

    // Check if move has left/right in name
    String? oppositeKeyword;
    if (nameLower.contains('left')) {
      oppositeKeyword = 'right';
    } else if (nameLower.contains('right')) {
      oppositeKeyword = 'left';
    }

    if (oppositeKeyword == null) {
      return null;
    }

    // Find move with opposite keyword and similar base name
    for (final candidate in availableMoves) {
      final candidateLower = candidate.name.toLowerCase();
      if (candidateLower.contains(oppositeKeyword)) {
        // Check if base name is similar (e.g., "Slip" in "Slip Left" and "Slip Right")
        final baseName = nameLower.replaceAll('left', '').replaceAll('right', '').trim();
        final candidateBase = candidateLower.replaceAll('left', '').replaceAll('right', '').trim();
        if (baseName == candidateBase) {
          return candidate;
        }
      }
    }

    return null;
  }
}
