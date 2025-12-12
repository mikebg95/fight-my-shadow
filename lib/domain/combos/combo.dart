import 'package:fight_my_shadow/main.dart';

/// Represents a fighting combination - a sequence of moves.
///
/// A Combo consists of a list of move codes (e.g., "1", "2", "A", "N") that
/// represent a sequence of techniques to be executed in order.
///
/// This is an immutable value object used throughout the domain layer.
///
/// Example:
/// ```dart
/// const jab_cross = Combo(
///   moveCodes: ['1', '2'],
///   difficulty: Difficulty.beginner,
///   name: 'Jab-Cross',
///   description: 'The most fundamental boxing combination',
/// );
/// ```
class Combo {
  /// List of move codes representing the sequence of moves in this combo.
  ///
  /// Each code corresponds to a move's code field (e.g., "1" for jab, "2" for cross).
  /// The order matters - moves should be executed in sequence.
  final List<String> moveCodes;

  /// Optional difficulty level for this combination.
  ///
  /// Used to filter or select combos appropriate for the user's skill level.
  final Difficulty? difficulty;

  /// Optional human-readable name for this combo.
  ///
  /// Examples: "Jab-Cross", "Classic Hook Combo", "Defensive Drill"
  final String? name;

  /// Optional description explaining the combo, its purpose, or tips.
  ///
  /// Example: "A fundamental combination that sets up with a jab and follows with power."
  final String? description;

  /// Optional sequence ID to uniquely identify this combo instance.
  ///
  /// Used to distinguish between different instances of the same combo codes,
  /// particularly in drill mode where the same move repeats.
  /// If null, voice deduplication relies on move codes only.
  final int? sequenceId;

  /// Creates a new Combo.
  ///
  /// The [moveCodes] list is required and must not be empty in practice,
  /// though this is not enforced at compile time.
  const Combo({
    required this.moveCodes,
    this.difficulty,
    this.name,
    this.description,
    this.sequenceId,
  });

  /// Creates a copy of this combo with optional field replacements.
  Combo copyWith({
    List<String>? moveCodes,
    Difficulty? difficulty,
    String? name,
    String? description,
    int? sequenceId,
  }) {
    return Combo(
      moveCodes: moveCodes ?? this.moveCodes,
      difficulty: difficulty ?? this.difficulty,
      name: name ?? this.name,
      description: description ?? this.description,
      sequenceId: sequenceId ?? this.sequenceId,
    );
  }

  @override
  String toString() {
    final codesStr = moveCodes.join('-');
    final nameStr = name != null ? ' "$name"' : '';
    final diffStr = difficulty != null ? ' [${difficulty!.label}]' : '';
    return 'Combo($codesStr$nameStr$diffStr)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Combo) return false;

    // Two combos are equal if they have the same move sequence
    if (moveCodes.length != other.moveCodes.length) return false;
    for (int i = 0; i < moveCodes.length; i++) {
      if (moveCodes[i] != other.moveCodes[i]) return false;
    }

    return difficulty == other.difficulty &&
        name == other.name &&
        description == other.description &&
        sequenceId == other.sequenceId;
  }

  @override
  int get hashCode {
    int codesHash = 0;
    for (final code in moveCodes) {
      codesHash ^= code.hashCode;
    }
    return Object.hash(codesHash, difficulty, name, description, sequenceId);
  }
}
