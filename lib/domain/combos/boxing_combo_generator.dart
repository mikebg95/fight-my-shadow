import 'dart:math';

import 'package:fight_my_shadow/domain/combos/combo.dart';
import 'package:fight_my_shadow/domain/combos/combo_generator.dart';
import 'package:fight_my_shadow/main.dart';
import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/repositories/move_repository.dart';

/// Boxing-specific implementation of [ComboGenerator].
///
/// This class generates realistic boxing combinations using move data from a
/// [MoveRepository]. It applies difficulty-based rules to create varied,
/// practical combos that mix punches, defense, and footwork moves.
///
/// Generation rules:
/// - Beginner: 2-3 moves, mostly punches, occasional defense
/// - Intermediate: 3-5 moves, punches + defense, some footwork
/// - Advanced: 4-7 moves, full mix of all categories
///
/// Usage:
/// ```dart
/// final repository = InMemoryMoveRepository();
/// final generator = BoxingComboGenerator(repository);
///
/// final combo = generator.generateCombo(
///   difficulty: Difficulty.beginner,
/// );
/// print(combo.moveCodes); // e.g., ['1', '2', 'A']
/// ```
class BoxingComboGenerator implements ComboGenerator {
  /// Repository providing access to available boxing moves.
  final MoveRepository _repository;

  /// Random number generator for move selection and pattern choice.
  final Random _random = Random();

  /// Creates a boxing combo generator with access to move data.
  BoxingComboGenerator(this._repository);

  @override
  Combo generateCombo({
    required Difficulty difficulty,
    Combo? previousCombo,
  }) {
    // Generate combo codes based on difficulty
    List<String> codes = _generateComboCodes(difficulty);

    // Validate the generated combo
    codes = _ensureValidCombo(codes);

    // If identical to previous combo, regenerate once
    if (previousCombo != null && _isIdenticalCombo(codes, previousCombo.moveCodes)) {
      codes = _generateComboCodes(difficulty);
      codes = _ensureValidCombo(codes);
    }

    return Combo(
      moveCodes: codes,
      difficulty: difficulty,
    );
  }

  /// Generates a list of move codes based on the difficulty level.
  List<String> _generateComboCodes(Difficulty difficulty) {
    // Pick a random pattern for this difficulty
    final pattern = _selectRandomPattern(difficulty);

    // Fill the pattern with random moves from each category
    final codes = <String>[];
    for (final category in pattern) {
      final code = _randomMoveCodeFromCategory(category);
      if (code != null) {
        codes.add(code);
      }
    }

    return codes;
  }

  /// Selects a random category pattern based on difficulty.
  List<MoveCategory> _selectRandomPattern(Difficulty difficulty) {
    List<List<MoveCategory>> patterns;

    switch (difficulty) {
      case Difficulty.beginner:
        patterns = _beginnerPatterns;
        break;
      case Difficulty.intermediate:
        patterns = _intermediatePatterns;
        break;
      case Difficulty.advanced:
        patterns = _advancedPatterns;
        break;
    }

    return patterns[_random.nextInt(patterns.length)];
  }

  /// Category patterns for beginner difficulty.
  /// 2-3 moves, mostly punches, occasional defense at the end.
  List<List<MoveCategory>> get _beginnerPatterns => [
        // Pure punches
        [MoveCategory.punch, MoveCategory.punch],
        [MoveCategory.punch, MoveCategory.punch],
        [MoveCategory.punch, MoveCategory.punch, MoveCategory.punch],

        // Punches with defense
        [MoveCategory.punch, MoveCategory.punch, MoveCategory.defense],
        [MoveCategory.punch, MoveCategory.defense],
      ];

  /// Category patterns for intermediate difficulty.
  /// 3-5 moves, mix of punches and defense, some footwork.
  List<List<MoveCategory>> get _intermediatePatterns => [
        // Punches with defense
        [MoveCategory.punch, MoveCategory.punch, MoveCategory.defense],
        [MoveCategory.punch, MoveCategory.defense, MoveCategory.punch],
        [MoveCategory.defense, MoveCategory.punch, MoveCategory.punch],
        [
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.defense,
          MoveCategory.punch
        ],

        // With footwork
        [MoveCategory.footwork, MoveCategory.punch, MoveCategory.punch],
        [MoveCategory.punch, MoveCategory.punch, MoveCategory.footwork],
        [
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.defense
        ],
        [
          MoveCategory.footwork,
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.defense
        ],

        // Longer combinations
        [
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.defense,
          MoveCategory.punch,
          MoveCategory.punch
        ],
      ];

  /// Category patterns for advanced difficulty.
  /// 4-7 moves, full mix of punches, defense, and footwork.
  List<List<MoveCategory>> get _advancedPatterns => [
        // Complex mixes
        [
          MoveCategory.footwork,
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.defense,
          MoveCategory.punch
        ],
        [
          MoveCategory.punch,
          MoveCategory.defense,
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.footwork
        ],
        [
          MoveCategory.defense,
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.defense,
          MoveCategory.punch
        ],

        // Longer combinations
        [
          MoveCategory.footwork,
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.defense,
          MoveCategory.punch,
          MoveCategory.punch
        ],
        [
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.defense,
          MoveCategory.footwork,
          MoveCategory.punch,
          MoveCategory.punch
        ],
        [
          MoveCategory.defense,
          MoveCategory.footwork,
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.defense
        ],

        // Very complex
        [
          MoveCategory.footwork,
          MoveCategory.punch,
          MoveCategory.defense,
          MoveCategory.punch,
          MoveCategory.punch,
          MoveCategory.footwork,
          MoveCategory.punch
        ],
      ];

  /// Returns a random move code from the specified category.
  ///
  /// Returns null if the category has no available moves.
  String? _randomMoveCodeFromCategory(MoveCategory category) {
    List<Move> moves;

    switch (category) {
      case MoveCategory.punch:
        moves = _repository.getAllPunches();
        break;
      case MoveCategory.defense:
        moves = _repository.getAllDefense();
        break;
      case MoveCategory.footwork:
        moves = _repository.getAllFootwork();
        break;
    }

    if (moves.isEmpty) {
      return null;
    }

    final randomMove = moves[_random.nextInt(moves.length)];
    return randomMove.code;
  }

  /// Ensures the generated combo is valid according to boxing rules.
  ///
  /// Applies sanity checks:
  /// - No more than 2 consecutive identical moves
  /// - At least one punch move
  /// - Not empty
  List<String> _ensureValidCombo(List<String> codes) {
    if (codes.isEmpty) {
      // Fallback to basic jab-cross if empty
      return ['1', '2'];
    }

    // Ensure at least one punch
    if (!_containsPunch(codes)) {
      // Insert a random punch at a random position
      final punches = _repository.getAllPunches();
      if (punches.isNotEmpty) {
        final punchCode = punches[_random.nextInt(punches.length)].code;
        final insertIndex = _random.nextInt(codes.length + 1);
        codes.insert(insertIndex, punchCode);
      }
    }

    // Remove excessive consecutive repeats (more than 2 in a row)
    codes = _limitConsecutiveRepeats(codes);

    return codes;
  }

  /// Checks if the combo contains at least one punch move.
  bool _containsPunch(List<String> codes) {
    final punchCodes = _repository.getAllPunches().map((m) => m.code).toSet();
    return codes.any((code) => punchCodes.contains(code));
  }

  /// Limits consecutive identical moves to a maximum of 2.
  ///
  /// Example: ['1', '1', '1', '2'] becomes ['1', '1', '2']
  List<String> _limitConsecutiveRepeats(List<String> codes) {
    if (codes.length <= 2) {
      return codes;
    }

    final result = <String>[];
    String? lastCode;
    int consecutiveCount = 0;

    for (final code in codes) {
      if (code == lastCode) {
        consecutiveCount++;
        // Allow up to 2 consecutive identical moves
        if (consecutiveCount < 2) {
          result.add(code);
        }
        // Skip if 2 or more consecutive
      } else {
        result.add(code);
        lastCode = code;
        consecutiveCount = 0;
      }
    }

    return result;
  }

  /// Checks if two combo code sequences are identical.
  bool _isIdenticalCombo(List<String> codes1, List<String> codes2) {
    if (codes1.length != codes2.length) {
      return false;
    }

    for (int i = 0; i < codes1.length; i++) {
      if (codes1[i] != codes2[i]) {
        return false;
      }
    }

    return true;
  }
}
