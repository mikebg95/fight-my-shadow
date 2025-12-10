/// Represents the category/type of a fighting move
enum MoveCategory {
  punch,
  kick,
  other,
}

/// Extension to get display-friendly labels for move categories
extension MoveCategoryExtension on MoveCategory {
  String get label {
    switch (this) {
      case MoveCategory.punch:
        return 'Punch';
      case MoveCategory.kick:
        return 'Kick';
      case MoveCategory.other:
        return 'Other';
    }
  }
}

/// Represents a single fighting move (punch, kick, etc.)
///
/// This is an immutable value object that defines a move used in
/// kickboxing/Muay Thai combinations.
///
/// Example:
/// ```dart
/// const jab = Move(
///   id: 1,
///   code: '1',
///   name: 'Left straight (jab)',
///   category: MoveCategory.punch,
///   description: 'A quick, straight punch with the lead hand...',
/// );
/// ```
class Move {
  /// Unique stable identifier for this move (1-23)
  final int id;

  /// Short code used in numeric combinations (e.g., "1", "2", "F", "S")
  final String code;

  /// Full human-readable name (e.g., "Left straight (jab)")
  final String name;

  /// The category/type of this move
  final MoveCategory category;

  /// Detailed description explaining what the move is and how to execute it
  final String? description;

  /// Key coaching tips, cues, or common mistakes to avoid
  final List<String>? tips;

  /// Optional path to an asset image or animation (e.g., 'assets/moves/jab.gif')
  final String? assetPath;

  const Move({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    this.description,
    this.tips,
    this.assetPath,
  });

  /// Creates a copy of this move with the given fields replaced
  ///
  /// Useful for future extensibility when adding optional fields
  Move copyWith({
    int? id,
    String? code,
    String? name,
    MoveCategory? category,
    String? description,
    List<String>? tips,
    String? assetPath,
  }) {
    return Move(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      tips: tips ?? this.tips,
      assetPath: assetPath ?? this.assetPath,
    );
  }

  @override
  String toString() {
    return 'Move(id: $id, code: "$code", name: "$name", category: ${category.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Move && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
