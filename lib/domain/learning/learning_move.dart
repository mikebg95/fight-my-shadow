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
  /// Unique identifier (1-18) representing the unlock order.
  final int id;

  /// Phase index (1-6) representing the learning phase this move belongs to.
  ///
  /// Phases:
  /// - 1: Basics
  /// - 2: Basic angles
  /// - 3: Defense
  /// - 4: Intermediate punches
  /// - 5: Advanced footwork
  /// - 6: Extras
  final int phase;

  /// Order index within the phase (0-based).
  ///
  /// Used for UI grouping and display ordering within each phase.
  final int orderInPhase;

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
    required this.phase,
    required this.orderInPhase,
    required this.displayName,
    required this.description,
    required this.moveCodes,
  });

  /// Returns the phase name as a string.
  String get phaseName {
    switch (phase) {
      case 1:
        return 'Basics';
      case 2:
        return 'Basic angles';
      case 3:
        return 'Defense';
      case 4:
        return 'Intermediate punches';
      case 5:
        return 'Advanced footwork';
      case 6:
        return 'Extras';
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
      'LearningMove(id: $id, phase: $phase, name: "$displayName")';
}
