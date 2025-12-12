/// Represents the training discipline for a move
enum Discipline {
  boxing,
  kickboxing,
  muayThai,
  kungFu,
}

/// Extension to get display-friendly labels for disciplines
extension DisciplineExtension on Discipline {
  String get label {
    switch (this) {
      case Discipline.boxing:
        return 'Boxing';
      case Discipline.kickboxing:
        return 'Kickboxing';
      case Discipline.muayThai:
        return 'Muay Thai';
      case Discipline.kungFu:
        return 'Kung Fu';
    }
  }
}

/// Represents the category/type of a fighting move
enum MoveCategory {
  punch,
  defense,
  footwork,
  deception,
}

/// Extension to get display-friendly labels for move categories
extension MoveCategoryExtension on MoveCategory {
  String get label {
    switch (this) {
      case MoveCategory.punch:
        return 'Punch';
      case MoveCategory.defense:
        return 'Defense';
      case MoveCategory.footwork:
        return 'Footwork';
      case MoveCategory.deception:
        return 'Deception';
    }
  }
}

/// Represents a single fighting move.
///
/// This is an immutable value object that defines a move used in
/// martial arts combinations.
///
/// Example:
/// ```dart
/// const jab = Move(
///   id: 1,
///   code: '1',
///   name: 'Jab',
///   category: MoveCategory.punch,
///   discipline: Discipline.boxing,
/// );
/// ```
class Move {
  /// Unique stable identifier for this move
  final int id;

  /// Short code used in combinations (e.g., "1", "2", "A", "N")
  /// This is the primary external label for the move
  final String code;

  /// Full human-readable name (e.g., "Jab", "Slip left")
  final String name;

  /// The category/type of this move
  final MoveCategory category;

  /// The training discipline this move belongs to
  final Discipline discipline;

  /// Optional detailed description explaining what the move is and how to execute it
  final String? description;

  /// Optional coaching tips, cues, or common mistakes to avoid
  final List<String>? tips;

  /// Optional path to an asset image or animation (e.g., 'assets/moves/jab.gif')
  final String? assetPath;

  const Move({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.discipline,
    this.description,
    this.tips,
    this.assetPath,
  });

  /// Creates a copy of this move with the given fields replaced
  Move copyWith({
    int? id,
    String? code,
    String? name,
    MoveCategory? category,
    Discipline? discipline,
    String? description,
    List<String>? tips,
    String? assetPath,
  }) {
    return Move(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      discipline: discipline ?? this.discipline,
      description: description ?? this.description,
      tips: tips ?? this.tips,
      assetPath: assetPath ?? this.assetPath,
    );
  }

  @override
  String toString() {
    return 'Move(id: $id, code: "$code", name: "$name", category: ${category.name}, discipline: ${discipline.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Move && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
