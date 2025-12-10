import 'package:fight_my_shadow/domain/combos/combo.dart';
import 'package:fight_my_shadow/main.dart';

/// Abstract interface for generating fighting combinations.
///
/// This is a domain-level contract that defines how combos should be generated.
/// Different implementations can provide different generation strategies
/// (random, rule-based, AI-driven, etc.) for different disciplines.
///
/// The generator is stateless - each call to [generateCombo] should produce
/// a new combo based on the provided parameters.
///
/// Example usage:
/// ```dart
/// final generator = BoxingComboGenerator(repository);
/// final combo = generator.generateCombo(
///   difficulty: Difficulty.intermediate,
///   previousCombo: lastCombo,
/// );
/// ```
abstract class ComboGenerator {
  /// Generates a new combo for the specified difficulty level.
  ///
  /// The [difficulty] parameter is required and determines the complexity,
  /// length, and types of moves included in the generated combo.
  ///
  /// The [previousCombo] parameter is optional. If provided, the generator
  /// may use it to create variety (e.g., avoiding repetition) or to create
  /// logical flow between consecutive combos.
  ///
  /// Returns a [Combo] instance containing a sequence of move codes.
  ///
  /// Example:
  /// ```dart
  /// // Generate a beginner combo
  /// final combo1 = generator.generateCombo(
  ///   difficulty: Difficulty.beginner,
  /// );
  ///
  /// // Generate the next combo, potentially avoiding moves from combo1
  /// final combo2 = generator.generateCombo(
  ///   difficulty: Difficulty.beginner,
  ///   previousCombo: combo1,
  /// );
  /// ```
  Combo generateCombo({
    required Difficulty difficulty,
    Combo? previousCombo,
  });
}
