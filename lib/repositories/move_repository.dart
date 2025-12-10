import 'package:fight_my_shadow/models/move.dart';
import 'package:fight_my_shadow/data/moves_data.dart' as moves_data;

/// Abstract interface for accessing Move data.
///
/// Provides a clean, stable API for retrieving moves throughout the app.
/// Different implementations can provide data from various sources
/// (in-memory, JSON, database, network) without changing calling code.
abstract class MoveRepository {
  /// Returns all available moves.
  List<Move> getAllMoves();

  /// Gets a move by its unique ID.
  ///
  /// Returns the [Move] if found, or `null` if no move with that ID exists.
  ///
  /// Example:
  /// ```dart
  /// final jab = repository.getMoveById(1);
  /// ```
  Move? getMoveById(int id);

  /// Gets all moves of a specific category.
  ///
  /// Example:
  /// ```dart
  /// final punches = repository.getMovesByCategory(MoveCategory.punch);
  /// final kicks = repository.getMovesByCategory(MoveCategory.kick);
  /// ```
  List<Move> getMovesByCategory(MoveCategory category);

  /// Gets all punch moves (convenience method).
  ///
  /// Returns all moves with category [MoveCategory.punch].
  List<Move> getAllPunches();

  /// Gets all kick moves (convenience method).
  ///
  /// Returns all moves with category [MoveCategory.kick].
  List<Move> getAllKicks();

  /// Gets moves in a specific ID range.
  ///
  /// Useful for creating combinations with limited move sets.
  ///
  /// Example:
  /// ```dart
  /// final basicMoves = repository.getMovesInRange(1, 6);  // Basic punches
  /// ```
  List<Move> getMovesInRange(int startId, int endId);

  /// Gets the total number of available moves.
  int get totalMoves;
}

/// In-memory implementation of [MoveRepository].
///
/// Uses a predefined list of 21 moves stored in memory.
/// This is the current default implementation.
///
/// Usage:
/// ```dart
/// final repository = InMemoryMoveRepository();
/// final allMoves = repository.getAllMoves();
/// final jab = repository.getMoveById(1);
/// ```
class InMemoryMoveRepository implements MoveRepository {
  @override
  List<Move> getAllMoves() {
    // Return an unmodifiable list to prevent accidental modifications
    return List.unmodifiable(moves_data.allMoves);
  }

  @override
  Move? getMoveById(int id) {
    return moves_data.getMoveById(id);
  }

  @override
  List<Move> getMovesByCategory(MoveCategory category) {
    return moves_data.getMovesByCategory(category);
  }

  @override
  List<Move> getAllPunches() {
    return moves_data.getAllPunches();
  }

  @override
  List<Move> getAllKicks() {
    return moves_data.getAllKicks();
  }

  @override
  List<Move> getMovesInRange(int startId, int endId) {
    return moves_data.getMovesInRange(startId, endId);
  }

  @override
  int get totalMoves => moves_data.totalMoves;
}
