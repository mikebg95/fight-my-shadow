import 'dart:math';

import 'package:flutter/foundation.dart';
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

  /// Optional list of allowed move codes to filter generation.
  /// If null, all moves are allowed. If provided, only moves in this
  /// list will be used for combo generation.
  List<String>? _allowedMoveCodes;

  /// Creates a boxing combo generator with access to move data.
  BoxingComboGenerator(this._repository);

  /// Sets the allowed move codes for combo generation.
  /// Pass null to allow all moves. Pass an empty list to block all moves.
  void setAllowedMoveCodes(List<String>? codes) {
    _allowedMoveCodes = codes;
    if (kDebugMode) {
      print('[BoxingComboGenerator] setAllowedMoveCodes: ${codes?.length ?? 'null'} codes: $codes');
    }
  }

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

    if (kDebugMode) {
      print('[BoxingComboGenerator] generateCombo: $codes (allowed=${_allowedMoveCodes?.length ?? "all"})');
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
  /// Filters by allowed move codes if set. Returns null if the category
  /// has no available moves or all moves are filtered out.
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
      case MoveCategory.deception:
        moves = _repository.getMovesByCategory(MoveCategory.deception);
        break;
    }

    // Filter by allowed move codes if set
    if (_allowedMoveCodes != null) {
      moves = moves.where((move) => _allowedMoveCodes!.contains(move.code)).toList();
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
  ///
  /// IMPORTANT: When [_allowedMoveCodes] is set, all fallback insertions
  /// respect the filter to prevent disallowed moves from appearing.
  List<String> _ensureValidCombo(List<String> codes) {
    if (codes.isEmpty) {
      // Fallback: get allowed punches (or any allowed moves)
      final fallbackCodes = _getFallbackCodes();
      if (fallbackCodes.isNotEmpty) {
        return fallbackCodes;
      }
      // Ultimate fallback if no allowed moves at all (shouldn't happen)
      return ['1', '2'];
    }

    // Ensure at least one punch
    if (!_containsPunch(codes)) {
      // Insert a random allowed punch at a random position
      final allowedPunchCode = _getRandomAllowedPunchCode();
      if (allowedPunchCode != null) {
        final insertIndex = _random.nextInt(codes.length + 1);
        codes.insert(insertIndex, allowedPunchCode);
      }
    }

    // Remove excessive consecutive repeats (more than 2 in a row)
    codes = _limitConsecutiveRepeats(codes);

    return codes;
  }

  /// Gets a random punch code that respects [_allowedMoveCodes] filtering.
  /// Returns null if no allowed punches are available.
  String? _getRandomAllowedPunchCode() {
    var punches = _repository.getAllPunches();

    // Filter by allowed codes if set
    if (_allowedMoveCodes != null) {
      punches = punches.where((m) => _allowedMoveCodes!.contains(m.code)).toList();
    }

    if (punches.isEmpty) {
      return null;
    }

    return punches[_random.nextInt(punches.length)].code;
  }

  /// Gets fallback codes when combo generation produces an empty list.
  /// Respects [_allowedMoveCodes] filtering.
  /// Returns up to 2 punch codes, or any allowed codes if no punches available.
  List<String> _getFallbackCodes() {
    // Try to get allowed punches first
    var punches = _repository.getAllPunches();
    if (_allowedMoveCodes != null) {
      punches = punches.where((m) => _allowedMoveCodes!.contains(m.code)).toList();
    }

    if (punches.isNotEmpty) {
      // Return 1-2 random allowed punches
      if (punches.length == 1) {
        return [punches.first.code];
      }
      // Shuffle and take first 2
      final shuffled = List<Move>.from(punches)..shuffle(_random);
      return [shuffled[0].code, shuffled[1].code];
    }

    // No allowed punches - try any allowed move codes
    if (_allowedMoveCodes != null && _allowedMoveCodes!.isNotEmpty) {
      final shuffled = List<String>.from(_allowedMoveCodes!)..shuffle(_random);
      return shuffled.take(2).toList();
    }

    // No allowed codes at all - return empty (caller handles this)
    return [];
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

  /// Generates a combo for Add to Arsenal mode with weighted target move selection.
  ///
  /// This method:
  /// - Only uses moves from [allowedMoveCodes] (unlocked moves + target move)
  /// - Applies 6-10x weight to [targetMoveCode] so it appears 60-75% of the time
  /// - Follows same difficulty-based patterns as regular combo generation
  /// - Ensures valid combos according to boxing rules
  ///
  /// The weighting is implemented by including the target move multiple times
  /// in the selection pool when picking random moves from a category.
  Combo generateArsenalCombo({
    required Difficulty difficulty,
    required String targetMoveCode,
    required List<String> allowedMoveCodes,
    Combo? previousCombo,
  }) {
    // Pick a random pattern for this difficulty
    final pattern = _selectRandomPattern(difficulty);

    // Build the combo using the weighted selection
    final codes = <String>[];
    for (final category in pattern) {
      final code = _randomMoveCodeFromCategoryWeighted(
        category,
        targetMoveCode: targetMoveCode,
        allowedMoveCodes: allowedMoveCodes,
      );
      if (code != null) {
        codes.add(code);
      }
    }

    // Validate the generated combo
    var validatedCodes = _ensureValidCombo(codes);

    // If identical to previous combo, regenerate once
    if (previousCombo != null && _isIdenticalCombo(validatedCodes, previousCombo.moveCodes)) {
      final retryPattern = _selectRandomPattern(difficulty);
      final retryCodes = <String>[];
      for (final category in retryPattern) {
        final code = _randomMoveCodeFromCategoryWeighted(
          category,
          targetMoveCode: targetMoveCode,
          allowedMoveCodes: allowedMoveCodes,
        );
        if (code != null) {
          retryCodes.add(code);
        }
      }
      validatedCodes = _ensureValidCombo(retryCodes);
    }

    // GUARANTEE target move appears: if it's not in the combo, insert it
    if (!validatedCodes.contains(targetMoveCode)) {
      // Find the target move from repository to determine its category
      final targetMove = _repository.getMoveByCode(targetMoveCode);

      if (targetMove != null && targetMove.category == MoveCategory.punch) {
        // Replace a punch with the target, or add it if no punches
        final punchIndices = <int>[];
        for (int i = 0; i < validatedCodes.length; i++) {
          final move = _repository.getMoveByCode(validatedCodes[i]);
          if (move != null && move.category == MoveCategory.punch) {
            punchIndices.add(i);
          }
        }
        if (punchIndices.isNotEmpty) {
          // Replace a random punch
          final replaceIndex = punchIndices[_random.nextInt(punchIndices.length)];
          validatedCodes[replaceIndex] = targetMoveCode;
        } else {
          // No punches, add target at end (shouldn't happen after ensureValidCombo)
          validatedCodes.add(targetMoveCode);
        }
      } else {
        // For defense/footwork targets (or unknown moves), add at a random position
        final insertIndex = validatedCodes.isEmpty ? 0 : _random.nextInt(validatedCodes.length + 1);
        validatedCodes.insert(insertIndex, targetMoveCode);
      }
    }

    return Combo(
      moveCodes: validatedCodes,
      difficulty: difficulty,
    );
  }

  /// Returns a random move code from the specified category with weighting.
  ///
  /// Only selects from [allowedMoveCodes]. The [targetMoveCode] gets 6-10x
  /// weight compared to other moves in its category, ensuring it appears
  /// 60-75% of the time in generated combos.
  ///
  /// Returns null if no allowed moves exist in this category.
  String? _randomMoveCodeFromCategoryWeighted(
    MoveCategory category, {
    required String targetMoveCode,
    required List<String> allowedMoveCodes,
  }) {
    // Get all moves in this category
    List<Move> categoryMoves;
    switch (category) {
      case MoveCategory.punch:
        categoryMoves = _repository.getAllPunches();
        break;
      case MoveCategory.defense:
        categoryMoves = _repository.getAllDefense();
        break;
      case MoveCategory.footwork:
        categoryMoves = _repository.getAllFootwork();
        break;
      case MoveCategory.deception:
        categoryMoves = _repository.getMovesByCategory(MoveCategory.deception);
        break;
    }

    // Filter to only allowed moves
    final allowedInCategory = categoryMoves
        .where((move) => allowedMoveCodes.contains(move.code))
        .toList();

    if (allowedInCategory.isEmpty) {
      return null;
    }

    // Build weighted pool: add target move 6-10x
    final weightedPool = <String>[];
    final targetWeight = 6 + _random.nextInt(5); // 6-10x weight

    for (final move in allowedInCategory) {
      if (move.code == targetMoveCode) {
        // Add target move multiple times for weighting
        for (int i = 0; i < targetWeight; i++) {
          weightedPool.add(move.code);
        }
      } else {
        // Add other moves once
        weightedPool.add(move.code);
      }
    }

    // Select randomly from weighted pool
    return weightedPool[_random.nextInt(weightedPool.length)];
  }
}
