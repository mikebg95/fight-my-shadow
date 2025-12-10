// This file demonstrates and tests the combo generation system.
// It can be deleted - it's just for reference and testing.

import 'package:fight_my_shadow/domain/combos/boxing_combo_generator.dart';
import 'package:fight_my_shadow/domain/combos/combo.dart';
import 'package:fight_my_shadow/domain/combos/combo_generator.dart';
import 'package:fight_my_shadow/main.dart';
import 'package:fight_my_shadow/repositories/move_repository.dart';

/// Demonstrates basic usage of the combo system.
void exampleUsage() {
  // 1. Create a repository to access boxing moves
  final MoveRepository repository = InMemoryMoveRepository();

  // 2. Create a combo generator
  final ComboGenerator generator = BoxingComboGenerator(repository);

  // 3. Generate a combo for a beginner
  final Combo beginnerCombo = generator.generateCombo(
    difficulty: Difficulty.beginner,
  );
  print('Beginner combo: ${beginnerCombo.moveCodes.join("-")}');
  print('  Length: ${beginnerCombo.moveCodes.length}');
  print('  Difficulty: ${beginnerCombo.difficulty?.label}');

  // 4. Generate another combo, passing the previous one for variety
  final Combo nextCombo = generator.generateCombo(
    difficulty: Difficulty.intermediate,
    previousCombo: beginnerCombo,
  );
  print('\nIntermediate combo: ${nextCombo.moveCodes.join("-")}');
  print('  Length: ${nextCombo.moveCodes.length}');

  // 5. Generate an advanced combo
  final Combo advancedCombo = generator.generateCombo(
    difficulty: Difficulty.advanced,
  );
  print('\nAdvanced combo: ${advancedCombo.moveCodes.join("-")}');
  print('  Length: ${advancedCombo.moveCodes.length}');

  // 6. Create a custom combo manually
  const Combo customCombo = Combo(
    moveCodes: ['1', '2', '3', '4'],
    difficulty: Difficulty.advanced,
    name: 'Double Jab-Cross-Hook',
    description: 'Advanced combination with hooks',
  );
  print('\nCustom combo: $customCombo');
}

/// Tests the combo generator to verify it works correctly.
void testComboGeneration() {
  print('=== Testing Combo Generation ===\n');

  final repository = InMemoryMoveRepository();
  final generator = BoxingComboGenerator(repository);

  // Test beginner combos
  print('--- Beginner Combos (2-3 moves, mostly punches) ---');
  for (int i = 0; i < 5; i++) {
    final combo = generator.generateCombo(difficulty: Difficulty.beginner);
    print('${i + 1}. ${combo.moveCodes.join("-")} (${combo.moveCodes.length} moves)');
  }

  print('\n--- Intermediate Combos (3-5 moves, mixed) ---');
  for (int i = 0; i < 5; i++) {
    final combo = generator.generateCombo(difficulty: Difficulty.intermediate);
    print('${i + 1}. ${combo.moveCodes.join("-")} (${combo.moveCodes.length} moves)');
  }

  print('\n--- Advanced Combos (4-7 moves, complex) ---');
  for (int i = 0; i < 5; i++) {
    final combo = generator.generateCombo(difficulty: Difficulty.advanced);
    print('${i + 1}. ${combo.moveCodes.join("-")} (${combo.moveCodes.length} moves)');
  }

  // Test variety (should not always generate identical combos)
  print('\n--- Testing Variety (10 beginner combos) ---');
  final combos = <String>{};
  for (int i = 0; i < 10; i++) {
    final combo = generator.generateCombo(difficulty: Difficulty.beginner);
    combos.add(combo.moveCodes.join("-"));
  }
  print('Generated ${combos.length} unique combos out of 10');
  print('Unique combos: ${combos.join(", ")}');

  // Test previousCombo handling
  print('\n--- Testing Previous Combo Avoidance ---');
  final first = generator.generateCombo(difficulty: Difficulty.beginner);
  print('First combo: ${first.moveCodes.join("-")}');

  // Try to generate next combo 5 times and see if any match
  int matches = 0;
  for (int i = 0; i < 5; i++) {
    final next = generator.generateCombo(
      difficulty: Difficulty.beginner,
      previousCombo: first,
    );
    if (next.moveCodes.join("-") == first.moveCodes.join("-")) {
      matches++;
    }
    print('Next ${i + 1}: ${next.moveCodes.join("-")}');
  }
  print('Matches with previous: $matches/5 (should be low)');
}
