/// Represents user preferences for Training Sessions.
///
/// Tracks which unlocked moves should be included in combo generation.
/// By default, all unlocked moves are included.
class TrainingPreferences {
  /// Set of move codes that are included in Training Sessions.
  ///
  /// Only unlocked moves can be included. Locked moves (including
  /// READY_FOR_UNLOCK) are always excluded from Training.
  final Set<String> includedMoveCodes;

  const TrainingPreferences({
    required this.includedMoveCodes,
  });

  /// Creates default preferences with all provided unlocked moves included.
  factory TrainingPreferences.defaultWith(List<String> unlockedMoveCodes) {
    return TrainingPreferences(
      includedMoveCodes: Set<String>.from(unlockedMoveCodes),
    );
  }

  /// Creates an empty preferences object (no moves included).
  factory TrainingPreferences.empty() {
    return const TrainingPreferences(includedMoveCodes: {});
  }

  /// Checks if a move code is included in Training.
  bool isIncluded(String moveCode) {
    return includedMoveCodes.contains(moveCode);
  }

  /// Returns the count of included moves.
  int get includedCount => includedMoveCodes.length;

  /// Creates a copy with a move toggled (added or removed).
  TrainingPreferences toggleMove(String moveCode) {
    final newSet = Set<String>.from(includedMoveCodes);
    if (newSet.contains(moveCode)) {
      newSet.remove(moveCode);
    } else {
      newSet.add(moveCode);
    }
    return TrainingPreferences(includedMoveCodes: newSet);
  }

  /// Creates a copy with a move explicitly included.
  /// Used for auto-including newly unlocked moves.
  TrainingPreferences includeMove(String moveCode) {
    if (includedMoveCodes.contains(moveCode)) {
      return this; // Already included
    }
    final newSet = Set<String>.from(includedMoveCodes);
    newSet.add(moveCode);
    return TrainingPreferences(includedMoveCodes: newSet);
  }

  /// Creates a copy with multiple moves included.
  /// Used for migration/sync with newly unlocked moves.
  TrainingPreferences includeAllMoves(List<String> moveCodes) {
    final newSet = Set<String>.from(includedMoveCodes);
    newSet.addAll(moveCodes);
    return TrainingPreferences(includedMoveCodes: newSet);
  }

  /// Creates a copy with updated fields.
  TrainingPreferences copyWith({
    Set<String>? includedMoveCodes,
  }) {
    return TrainingPreferences(
      includedMoveCodes: includedMoveCodes ?? this.includedMoveCodes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingPreferences &&
          runtimeType == other.runtimeType &&
          includedMoveCodes.length == other.includedMoveCodes.length &&
          includedMoveCodes.every(other.includedMoveCodes.contains);

  @override
  int get hashCode => Object.hashAll(includedMoveCodes.toList()..sort());

  @override
  String toString() =>
      'TrainingPreferences(included: ${includedMoveCodes.length} moves)';

  /// Converts this preferences to a JSON map for persistence.
  Map<String, dynamic> toJson() {
    return {
      'includedMoveCodes': includedMoveCodes.toList(),
    };
  }

  /// Creates a TrainingPreferences from a JSON map.
  factory TrainingPreferences.fromJson(Map<String, dynamic> json) {
    final moveCodesList = (json['includedMoveCodes'] as List?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    return TrainingPreferences(
      includedMoveCodes: Set<String>.from(moveCodesList),
    );
  }
}
