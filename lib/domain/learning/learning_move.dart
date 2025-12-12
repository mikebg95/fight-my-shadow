/// Represents a single step in the Story Mode learning progression.
///
/// A [LearningMove] is a conceptual learning unit that teaches the user
/// a specific technique or concept. Each learning move maps to one or more
/// underlying [Move] codes from the main move system.
///
/// Example:
/// - Learning move: "Jab" → maps to move code "1"
/// - Learning move: "Feints" → maps to move code "F"
///
/// Important: Feints (code "F") is a single move that acts as a modifier.
/// In combos, "F" can be placed before punches (e.g., "F1" = feint jab),
/// but F1/F2/F3 are not separate moves - they're notation for feint + punch.
///
/// This model is purely about curriculum definition and does not track
/// user progress or unlock status.
class LearningMove {
  /// Unique identifier (1-40) representing the unlock order.
  final int id;

  /// Level index (1-12) representing the learning level this move belongs to.
  ///
  /// Levels:
  /// - 1: Foundation Fists
  /// - 2: Rails & Shields
  /// - 3: Hook City
  /// - 4: Turn the Corner
  /// - 5: Uppercut Engine
  /// - 6: Slipstream
  /// - 7: Wave & Fade
  /// - 8: Shield Wall
  /// - 9: Deception Arts
  /// - 10: Footwork Fury
  /// - 11: Body Hunters
  /// - 12: Shadow Weapons
  final int level;

  /// Order index within the level (0-based).
  ///
  /// Used for UI grouping and display ordering within each level.
  final int orderInLevel;

  /// User-facing display name.
  ///
  /// Examples: "Jab", "Step forward", "Slip left", "Feints"
  final String displayName;

  /// Short description explaining what this learning move is and how to execute it.
  ///
  /// This is a brief coaching explanation suitable for first-time learners.
  final String description;

  /// List of underlying Move codes from the main move system.
  ///
  /// Most learning moves map to a single code (e.g., "1" for Jab).
  /// Feints maps to exactly ["F"].
  ///
  /// Later, the combo generator can use "F" as a modifier before punch codes.
  final List<String> moveCodes;

  const LearningMove({
    required this.id,
    required this.level,
    required this.orderInLevel,
    required this.displayName,
    required this.description,
    required this.moveCodes,
  });

  /// Returns the level name as a string.
  String get levelName {
    switch (level) {
      case 0:
        return 'The First Bell';
      case 1:
        return 'Foundation Fists';
      case 2:
        return 'Rails & Shields';
      case 3:
        return 'Hook City';
      case 4:
        return 'Turn the Corner';
      case 5:
        return 'Uppercut Engine';
      case 6:
        return 'Slipstream';
      case 7:
        return 'Wave & Fade';
      case 8:
        return 'Shield Wall';
      case 9:
        return 'Deception Arts';
      case 10:
        return 'Footwork Fury';
      case 11:
        return 'Body Hunters';
      case 12:
        return 'Shadow Weapons';
      default:
        return 'Unknown';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningMove &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LearningMove(id: $id, level: $level, name: "$displayName")';
}
