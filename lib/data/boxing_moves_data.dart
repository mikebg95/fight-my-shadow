import 'package:fight_my_shadow/models/move.dart';

/// The canonical list of all Boxing moves in the app.
///
/// This serves as the single source of truth for Boxing moves.
///
/// Structure:
/// - Moves 1-14: Punches (numeric codes 1-14)
/// - Moves 15-26: Defense (letter codes A-M, no F)
/// - Moves 27-37: Footwork (letter codes N-X)
///
/// Each move has:
/// - `id`: Unique identifier
/// - `code`: User-facing code for combinations (numbers or letters)
/// - `name`: Full descriptive name
/// - `category`: punch, defense, or footwork
/// - `discipline`: boxing
final List<Move> boxingMoves = [
  // PUNCHES (NUMBERS 1-14)
  const Move(
    id: 1,
    code: '1',
    name: 'Left straight',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 2,
    code: '2',
    name: 'Right straight',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 3,
    code: '3',
    name: 'Left hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 4,
    code: '4',
    name: 'Right hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 5,
    code: '5',
    name: 'Left uppercut',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 6,
    code: '6',
    name: 'Right uppercut',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 7,
    code: '7',
    name: 'Left body hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 8,
    code: '8',
    name: 'Right body hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 9,
    code: '9',
    name: 'Left straight to body',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 10,
    code: '10',
    name: 'Right straight to body',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 11,
    code: '11',
    name: 'Right overhand',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 12,
    code: '12',
    name: 'Check hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 13,
    code: '13',
    name: 'Left shovel hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 14,
    code: '14',
    name: 'Right shovel hook',
    category: MoveCategory.punch,
    discipline: Discipline.boxing,
  ),

  // DEFENSE (LETTERS A-M, no F)
  const Move(
    id: 15,
    code: 'A',
    name: 'Slip left',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 16,
    code: 'B',
    name: 'Slip right',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 17,
    code: 'C',
    name: 'Roll left',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 18,
    code: 'D',
    name: 'Roll right',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 19,
    code: 'E',
    name: 'Duck',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 20,
    code: 'G',
    name: 'Block straight left',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 21,
    code: 'H',
    name: 'Pull back',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 22,
    code: 'I',
    name: 'Block straight right',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 23,
    code: 'J',
    name: 'Block left hook',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 24,
    code: 'K',
    name: 'Block right hook',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 25,
    code: 'L',
    name: 'Catch jab',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 26,
    code: 'M',
    name: 'Parry',
    category: MoveCategory.defense,
    discipline: Discipline.boxing,
  ),

  // FOOTWORK (LETTERS N-X)
  const Move(
    id: 27,
    code: 'N',
    name: 'Step in',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 28,
    code: 'O',
    name: 'Step back',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 29,
    code: 'P',
    name: 'Step left',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 30,
    code: 'Q',
    name: 'Step right',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 31,
    code: 'R',
    name: 'Pivot left',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 32,
    code: 'S',
    name: 'Pivot right',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 33,
    code: 'T',
    name: 'Shuffle forward',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 34,
    code: 'U',
    name: 'Shuffle backward',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 35,
    code: 'V',
    name: 'Circle left',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 36,
    code: 'W',
    name: 'Circle right',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
  ),
  const Move(
    id: 37,
    code: 'X',
    name: 'Switch stance',
    category: MoveCategory.footwork,
    discipline: Discipline.boxing,
  ),
];

/// Get a move by its unique ID.
Move? getMoveById(int id) {
  try {
    return boxingMoves.firstWhere((move) => move.id == id);
  } catch (e) {
    return null;
  }
}

/// Get a move by its code string (works for both numbers and letters).
///
/// Example:
/// ```dart
/// final jab = getMoveByCode('1');     // Returns Move(id: 1, name: "Left straight")
/// final slipLeft = getMoveByCode('A'); // Returns Move(id: 15, name: "Slip left")
/// ```
Move? getMoveByCode(String code) {
  try {
    return boxingMoves.firstWhere((move) => move.code == code);
  } catch (e) {
    return null;
  }
}

/// Get all moves of a specific category.
///
/// Example:
/// ```dart
/// final punches = getMovesByCategory(MoveCategory.punch);    // Returns moves 1-14
/// final defense = getMovesByCategory(MoveCategory.defense);  // Returns moves A-M
/// final footwork = getMovesByCategory(MoveCategory.footwork); // Returns moves N-X
/// ```
List<Move> getMovesByCategory(MoveCategory category) {
  return boxingMoves.where((move) => move.category == category).toList();
}

/// Get all moves for a specific discipline.
List<Move> getMovesByDiscipline(Discipline discipline) {
  return boxingMoves.where((move) => move.discipline == discipline).toList();
}

/// Get all punches.
List<Move> getAllPunches() {
  return getMovesByCategory(MoveCategory.punch);
}

/// Get all defense moves.
List<Move> getAllDefense() {
  return getMovesByCategory(MoveCategory.defense);
}

/// Get all footwork moves.
List<Move> getAllFootwork() {
  return getMovesByCategory(MoveCategory.footwork);
}

/// Total number of Boxing moves.
int get totalMoves => boxingMoves.length;
