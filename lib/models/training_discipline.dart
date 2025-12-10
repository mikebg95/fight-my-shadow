/// Represents the different martial arts/combat sports disciplines supported by the app.
enum TrainingDiscipline {
  boxing,
  kickboxing,
  muayThai,
  kungFu,
}

/// Extension to get display-friendly labels and info for training disciplines.
extension TrainingDisciplineExtension on TrainingDiscipline {
  /// User-friendly display name
  String get label {
    switch (this) {
      case TrainingDiscipline.boxing:
        return 'Boxing';
      case TrainingDiscipline.kickboxing:
        return 'Kickboxing';
      case TrainingDiscipline.muayThai:
        return 'Muay Thai';
      case TrainingDiscipline.kungFu:
        return 'Kung Fu';
    }
  }

  /// Short description for the discipline
  String get description {
    switch (this) {
      case TrainingDiscipline.boxing:
        return 'The sweet science of punching';
      case TrainingDiscipline.kickboxing:
        return 'Powerful punches and kicks';
      case TrainingDiscipline.muayThai:
        return 'The art of eight limbs';
      case TrainingDiscipline.kungFu:
        return 'Traditional martial arts mastery';
    }
  }
}
