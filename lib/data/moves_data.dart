import 'package:fight_my_shadow/models/move.dart';

/// The canonical list of all predefined moves in the app.
///
/// This serves as the single source of truth for the 21 core moves
/// used in kickboxing/Muay Thai combinations.
///
/// Structure:
/// - Moves 1-11: Hand techniques (punches)
/// - Moves 12-13: Guard manipulation (other)
/// - Moves 14-21: Kicks
///
/// Each move has:
/// - `id`: Unique identifier (1-21)
/// - `code`: String representation of the ID for combo notation
/// - `name`: Full descriptive name
/// - `category`: Classification (punch, kick, other)
final List<Move> allMoves = [
  // PUNCHES (1-11)
  const Move(
    id: 1,
    code: '1',
    name: 'Left straight (jab)',
    category: MoveCategory.punch,
  ),
  const Move(
    id: 2,
    code: '2',
    name: 'Right straight (cross)',
    category: MoveCategory.punch,
  ),
  const Move(
    id: 3,
    code: '3',
    name: 'Left hook',
    category: MoveCategory.punch,
  ),
  const Move(
    id: 4,
    code: '4',
    name: 'Right hook',
    category: MoveCategory.punch,
  ),
  const Move(
    id: 5,
    code: '5',
    name: 'Left uppercut',
    category: MoveCategory.punch,
  ),
  const Move(
    id: 6,
    code: '6',
    name: 'Right uppercut',
    category: MoveCategory.punch,
  ),
  const Move(
    id: 7,
    code: '7',
    name: 'Left body hook (liver shot)',
    category: MoveCategory.punch,
  ),
  const Move(
    id: 8,
    code: '8',
    name: 'Right body hook',
    category: MoveCategory.punch,
  ),
  const Move(
    id: 9,
    code: '9',
    name: 'Left straight to body (jab)',
    category: MoveCategory.punch,
  ),
  const Move(
    id: 10,
    code: '10',
    name: 'Right straight to body (cross)',
    category: MoveCategory.punch,
  ),
  const Move(
    id: 11,
    code: '11',
    name: 'Right overhand',
    category: MoveCategory.punch,
  ),

  // GUARD MANIPULATION (12-13)
  const Move(
    id: 12,
    code: '12',
    name: 'Pull down guard (left)',
    category: MoveCategory.other,
  ),
  const Move(
    id: 13,
    code: '13',
    name: 'Pull down guard (right)',
    category: MoveCategory.other,
  ),

  // KICKS (14-21)
  const Move(
    id: 14,
    code: '14',
    name: 'Left low kick (inside)',
    category: MoveCategory.kick,
  ),
  const Move(
    id: 15,
    code: '15',
    name: 'Right low kick',
    category: MoveCategory.kick,
  ),
  const Move(
    id: 16,
    code: '16',
    name: 'Left teep/push kick',
    category: MoveCategory.kick,
  ),
  const Move(
    id: 17,
    code: '17',
    name: 'Right push kick',
    category: MoveCategory.kick,
  ),
  const Move(
    id: 18,
    code: '18',
    name: 'Left body kick',
    category: MoveCategory.kick,
  ),
  const Move(
    id: 19,
    code: '19',
    name: 'Right body kick',
    category: MoveCategory.kick,
  ),
  const Move(
    id: 20,
    code: '20',
    name: 'Left head kick',
    category: MoveCategory.kick,
  ),
  const Move(
    id: 21,
    code: '21',
    name: 'Right head kick',
    category: MoveCategory.kick,
  ),
];

/// Get a move by its unique ID.
///
/// Returns the [Move] if found, or `null` if no move with that ID exists.
///
/// Example:
/// ```dart
/// final jab = getMoveById(1);  // Returns Move(id: 1, name: "Left straight (jab)", ...)
/// ```
Move? getMoveById(int id) {
  try {
    return allMoves.firstWhere((move) => move.id == id);
  } catch (e) {
    return null;
  }
}

/// Get a move by its code string.
///
/// Returns the [Move] if found, or `null` if no move with that code exists.
///
/// Example:
/// ```dart
/// final cross = getMoveByCode('2');  // Returns Move(id: 2, name: "Right straight (cross)", ...)
/// ```
Move? getMoveByCode(String code) {
  try {
    return allMoves.firstWhere((move) => move.code == code);
  } catch (e) {
    return null;
  }
}

/// Get all moves of a specific category.
///
/// Returns a list of all moves that match the given [category].
///
/// Example:
/// ```dart
/// final punches = getMovesByCategory(MoveCategory.punch);  // Returns moves 1-11
/// final kicks = getMovesByCategory(MoveCategory.kick);     // Returns moves 14-21
/// ```
List<Move> getMovesByCategory(MoveCategory category) {
  return allMoves.where((move) => move.category == category).toList();
}

/// Get all punches (moves 1-11).
///
/// Convenience method for retrieving all punch moves.
List<Move> getAllPunches() {
  return getMovesByCategory(MoveCategory.punch);
}

/// Get all kicks (moves 14-21).
///
/// Convenience method for retrieving all kick moves.
List<Move> getAllKicks() {
  return getMovesByCategory(MoveCategory.kick);
}

/// Get all moves in a specific ID range.
///
/// Useful for creating combinations with limited move sets.
///
/// Example:
/// ```dart
/// final basicMoves = getMovesInRange(1, 6);  // Jab, cross, hooks, uppercuts
/// ```
List<Move> getMovesInRange(int startId, int endId) {
  return allMoves
      .where((move) => move.id >= startId && move.id <= endId)
      .toList();
}

/// Total number of predefined moves.
int get totalMoves => allMoves.length;
